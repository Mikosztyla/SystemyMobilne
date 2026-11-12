import 'dart:async';

import 'package:bursa_app/models/current_session.dart';
import 'package:bursa_app/models/laundry_session.dart';
import 'package:bursa_app/models/machine.dart';
import 'package:bursa_app/services/laundry_exception.dart';
import 'package:bursa_app/services/laundry_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

typedef FeeCollection = ({DateTime start, DateTime? end});

class LaundryStore extends ChangeNotifier {
  LaundryStore({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  static const _clockInterval = Duration(seconds: 30);

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  Timer? _clock;
  Timer? _statusTimer;
  final Set<String> _autoFinishing = {};

  List<Machine> _machines = const [];
  List<LaundrySession> _mySessions = const [];
  FeeCollection? _nextFeeCollection;
  String _userName = '';
  bool _notifyLaundry = true;
  DateTime _now = DateTime.now();
  bool _isReady = false;
  String? _error;
  bool _waitingForFree = false;
  DateTime? _freeAlertAt;
  bool _disposed = false;

  List<Machine> get machines => _machines;
  bool get isWaitingForFreeMachine => _waitingForFree;
  List<LaundrySession> get mySessions => _mySessions;
  FeeCollection? get nextFeeCollection => _nextFeeCollection;
  DateTime get now => _now;
  bool get isReady => _isReady;
  String? get error => _error;
  String? get uid => _auth.currentUser?.uid;

  void start() {
    final uid = this.uid;
    if (uid == null || _clock != null) return;

    _subscriptions.add(
      _db
          .collection(MachineFields.collection)
          .snapshots()
          .listen(_onMachines, onError: _onError),
    );
    _subscriptions.add(
      _db
          .collection(LaundrySessionFields.collection)
          .where(LaundrySessionFields.userId, isEqualTo: uid)
          .snapshots()
          .listen(_onSessions, onError: _onError),
    );
    _subscriptions.add(
      _db
          .collection('events')
          .where('type', isEqualTo: 'feeCollection')
          .snapshots()
          .listen(_onFeeEvents, onError: (Object e) => debugPrint('$e')),
    );
    _subscriptions.add(
      _db
          .collection('users')
          .doc(uid)
          .snapshots()
          .listen(_onUser, onError: (Object e) => debugPrint('$e')),
    );

    _clock = Timer.periodic(_clockInterval, (_) => _tick());

    LaundryNotifications.instance.hasPendingFreeMachineAlert().then((pending) {
      if (_disposed || !pending || _waitingForFree) return;
      _waitingForFree = true;
      _syncFreeMachineAlert();
      notifyListeners();
    });
  }

  void _tick() {
    _now = DateTime.now();
    _finishMyExpiredWashes();
    _scheduleStatusTimer();
    _syncFreeMachineAlert();
    notifyListeners();
  }

  void _scheduleStatusTimer() {
    _statusTimer?.cancel();
    final now = DateTime.now();
    DateTime? next;
    for (final machine in _machines) {
      final endsAt = machine.currentSession?.endsAt;
      if (endsAt == null || !endsAt.isAfter(now)) continue;
      if (next == null || endsAt.isBefore(next)) next = endsAt;
    }
    if (next == null) return;
    _statusTimer = Timer(
      next.difference(now) + const Duration(seconds: 1),
      _tick,
    );
  }

  void _finishMyExpiredWashes() {
    final uid = this.uid;
    if (uid == null) return;
    for (final machine in _machines) {
      final session = machine.currentSession;
      if (session == null || session.userId != uid) continue;
      if (machine.isBusyAt(_now)) continue;
      if (!_autoFinishing.add(session.sessionId)) continue;
      finishWash(machine, finishedAt: session.endsAt).catchError((Object e) {
        _autoFinishing.remove(session.sessionId);
      });
    }
  }

  void _syncNotifications() {
    final uid = this.uid;
    final washes = <String, WashReminder>{
      for (final machine in _machines)
        if (machine.currentSession case final session?
            when session.userId == uid && machine.isBusyAt(DateTime.now()))
          session.sessionId: (machineName: machine.name, endsAt: session.endsAt),
    };
    LaundryNotifications.instance.sync(washes, enabled: _notifyLaundry);
  }

  void _syncFreeMachineAlert() {
    if (!_waitingForFree) return;
    final now = DateTime.now();
    final notifications = LaundryNotifications.instance;

    final free = _machines
        .where((m) => m.statusAt(now) == MachineStatus.free)
        .firstOrNull;
    if (free != null) {
      _waitingForFree = false;
      final alertAt = _freeAlertAt;
      _freeAlertAt = null;
      if (alertAt != null && !now.isBefore(alertAt)) return;
      notifications.showFreeMachineNow(free.name);
      return;
    }

    final next = nextToFree;
    final endsAt = next?.currentSession?.endsAt;
    if (next == null || endsAt == null) {
      if (_freeAlertAt != null) notifications.cancelFreeMachineAlert();
      _freeAlertAt = null;
      return;
    }
    if (endsAt == _freeAlertAt) return;
    _freeAlertAt = endsAt;
    notifications.scheduleFreeMachineAlert(machineName: next.name, at: endsAt);
  }

  int get freeCount =>
      _machines.where((m) => m.statusAt(_now) == MachineStatus.free).length;

  Machine? get firstFreeMachine => _machines
      .where((m) => m.statusAt(_now) == MachineStatus.free)
      .firstOrNull;

  bool get hasMyRunningWash => _machines.any((m) => m.isUsedBy(uid, _now));

  bool get allMachinesBusy =>
      freeCount == 0 &&
      !hasMyRunningWash &&
      _machines.any((m) => m.statusAt(_now) == MachineStatus.busy);

  Machine? get nextToFree {
    Machine? best;
    for (final machine in _machines) {
      if (machine.statusAt(_now) != MachineStatus.busy) continue;
      final endsAt = machine.currentSession!.endsAt;
      if (best == null || endsAt.isBefore(best.currentSession!.endsAt)) {
        best = machine;
      }
    }
    return best;
  }

  Machine? machineByQrCode(String code) {
    final wanted = code.trim().toUpperCase();
    final exact = _machines
        .where((m) => m.qrCode.trim().toUpperCase() == wanted)
        .firstOrNull;
    if (exact != null) return exact;
    return _machines.where((m) {
      final qr = RegExp.escape(m.qrCode.trim().toUpperCase());
      return qr.isNotEmpty &&
          RegExp('(^|[^A-Z0-9])$qr(\$|[^A-Z0-9])').hasMatch(wanted);
    }).firstOrNull;
  }

  List<LaundrySession> sessionsInMonth(DateTime month) => _mySessions
      .where(
        (s) => s.startedAt.year == month.year && s.startedAt.month == month.month,
      )
      .toList();

  int totalGrosze(Iterable<LaundrySession> sessions) =>
      sessions.fold(0, (total, s) => total + s.costGrosze);

  Map<DateTime, List<LaundrySession>> get sessionsByMonth {
    final result = <DateTime, List<LaundrySession>>{};
    for (final s in _mySessions) {
      final key = DateTime(s.startedAt.year, s.startedAt.month);
      result.putIfAbsent(key, () => []).add(s);
    }
    return result;
  }

  void notifyWhenMachineFree() {
    if (_waitingForFree || !allMachinesBusy) return;
    _waitingForFree = true;
    _syncFreeMachineAlert();
    notifyListeners();
  }

  void cancelNotifyWhenMachineFree() {
    if (!_waitingForFree) return;
    _waitingForFree = false;
    _freeAlertAt = null;
    LaundryNotifications.instance.cancelFreeMachineAlert();
    notifyListeners();
  }

  Future<void> startWash(
    Machine machine,
    int durationMinutes, {
    bool replaceRunning = false,
  }) async {
    final uid = this.uid;
    if (uid == null) throw const LaundryException('Zaloguj się ponownie.');
    if (_userName.isEmpty) {
      _userName = _auth.currentUser?.email ?? 'Mieszkanka';
    }

    final machineRef = _db.collection(MachineFields.collection).doc(machine.id);
    final sessionRef = _db.collection(LaundrySessionFields.collection).doc();

    try {
      await _db.runTransaction((tx) async {
        final snapshot = await tx.get(machineRef);
        final data = snapshot.data();
        if (data == null) {
          throw const LaundryException('Tej pralki nie ma już w systemie.');
        }
        final fresh = Machine.fromMap(snapshot.id, data);
        final startedAt = DateTime.now();
        if (fresh.outOfOrder) {
          throw const LaundryException('Ta pralka ma awarię.');
        }
        if (fresh.isBusyAt(startedAt) && !replaceRunning) {
          throw const LaundryException(
            'Ktoś właśnie zaczął pranie na tej pralce.',
          );
        }

        final session = LaundrySession(
          id: sessionRef.id,
          machineId: fresh.id,
          machineName: fresh.name,
          userId: uid,
          userName: _userName,
          startedAt: startedAt,
          durationMinutes: durationMinutes,
          costGrosze: fresh.priceGrosze,
        );
        final current = CurrentSession(
          sessionId: sessionRef.id,
          userId: uid,
          userName: _userName,
          startedAt: startedAt,
          durationMinutes: durationMinutes,
        );

        tx.set(sessionRef, session.toMap());
        tx.update(machineRef, {MachineFields.currentSession: current.toMap()});
      });
      cancelNotifyWhenMachineFree();
    } on LaundryException {
      rethrow;
    } catch (e) {
      debugPrint('startWash: $e');
      throw const LaundryException(
        'Nie udało się rozpocząć prania. Sprawdź internet i spróbuj ponownie.',
      );
    }
  }

  Future<void> finishWash(Machine machine, {DateTime? finishedAt}) async {
    final uid = this.uid;
    if (uid == null) throw const LaundryException('Zaloguj się ponownie.');
    final machineRef = _db.collection(MachineFields.collection).doc(machine.id);
    final expectedSessionId = machine.currentSession?.sessionId;

    try {
      await _db.runTransaction((tx) async {
        final snapshot = await tx.get(machineRef);
        final data = snapshot.data();
        if (data == null) return;
        final current = Machine.fromMap(snapshot.id, data).currentSession;
        if (current == null || current.userId != uid) return;
        if (current.sessionId != expectedSessionId) return;

        final sessionRef = _db
            .collection(LaundrySessionFields.collection)
            .doc(current.sessionId);
        tx.update(sessionRef, {
          LaundrySessionFields.finishedAt: finishedAt == null
              ? Timestamp.now()
              : Timestamp.fromDate(finishedAt),
        });
        tx.update(machineRef, {MachineFields.currentSession: null});
      });
    } catch (e) {
      debugPrint('finishWash: $e');
      throw const LaundryException(
        'Nie udało się zakończyć prania. Spróbuj ponownie.',
      );
    }
  }

  void _onMachines(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final list = <Machine>[];
    for (final doc in snapshot.docs) {
      try {
        list.add(Machine.fromMap(doc.id, doc.data()));
      } catch (e) {
        debugPrint('Pominięto pralkę ${doc.id} – złe dane: $e');
      }
    }
    list.sort((a, b) => a.name.compareTo(b.name));
    _machines = list;
    _now = DateTime.now();
    _isReady = true;
    _error = null;
    _finishMyExpiredWashes();
    _scheduleStatusTimer();
    _syncNotifications();
    _syncFreeMachineAlert();
    notifyListeners();
  }

  void _onSessions(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final list = <LaundrySession>[];
    for (final doc in snapshot.docs) {
      try {
        list.add(LaundrySession.fromMap(doc.id, doc.data()));
      } catch (e) {
        debugPrint('Pominięto pranie ${doc.id} – złe dane: $e');
      }
    }
    list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    _mySessions = list;
    notifyListeners();
  }

  void _onFeeEvents(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final today = DateTime(_now.year, _now.month, _now.day);
    FeeCollection? next;
    for (final doc in snapshot.docs) {
      final start = (doc.data()['startAt'] as Timestamp?)?.toDate();
      if (start == null || start.isBefore(today)) continue;
      if (next == null || start.isBefore(next.start)) {
        next = (
          start: start,
          end: (doc.data()['endAt'] as Timestamp?)?.toDate(),
        );
      }
    }
    _nextFeeCollection = next;
    notifyListeners();
  }

  void _onError(Object error) {
    debugPrint('LaundryStore: $error');
    _error = 'Nie udało się pobrać danych pralni.';
    notifyListeners();
  }

  void _onUser(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    final name = [data?['name'], data?['surname']]
        .whereType<String>()
        .where((part) => part.isNotEmpty)
        .join(' ');
    _userName = name.isNotEmpty
        ? name
        : (_auth.currentUser?.email ?? 'Mieszkanka');

    final notify = data?['notifyLaundry'] as bool? ?? true;
    if (notify != _notifyLaundry) {
      _notifyLaundry = notify;
      _syncNotifications();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _clock?.cancel();
    _statusTimer?.cancel();
    LaundryNotifications.instance.cancelAll();
    super.dispose();
  }
}
