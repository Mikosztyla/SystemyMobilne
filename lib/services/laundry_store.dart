import 'dart:async';

import 'package:bursa_app/models/laundry_session.dart';
import 'package:bursa_app/models/machine.dart';
import 'package:bursa_app/services/free_machine_watcher.dart';
import 'package:bursa_app/services/laundry_exception.dart';
import 'package:bursa_app/services/laundry_notifications.dart';
import 'package:bursa_app/services/laundry_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class LaundryStore extends ChangeNotifier {
  static const _clockInterval = Duration(seconds: 30);

  final LaundryRepository _repository;
  final FirebaseAuth _auth;
  final FreeMachineWatcher _freeMachineWatcher;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  final Set<String> _autoFinishing = {};
  Timer? _clock;
  Timer? _statusTimer;

  List<Machine> _machines = const [];
  List<LaundrySession> _mySessions = const [];
  FeeCollection? _nextFeeCollection;
  String _userName = "";
  bool _notifyLaundry = true;
  DateTime _now = DateTime.now();
  bool _isReady = false;
  String? _error;
  bool _disposed = false;

  LaundryStore({
    LaundryRepository? repository,
    FirebaseAuth? auth,
    FreeMachineWatcher? freeMachineWatcher,
  }) : _repository = repository ?? LaundryRepository(),
       _auth = auth ?? FirebaseAuth.instance,
       _freeMachineWatcher = freeMachineWatcher ?? FreeMachineWatcher();

  List<Machine> get machines => _machines;
  List<LaundrySession> get mySessions => _mySessions;
  FeeCollection? get nextFeeCollection => _nextFeeCollection;
  DateTime get now => _now;
  bool get isReady => _isReady;
  String? get error => _error;
  String? get uid => _auth.currentUser?.uid;
  bool get isWaitingForFreeMachine => _freeMachineWatcher.isWaiting;

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

  Machine? get nextToFree => FreeMachineWatcher.nextToFree(_machines, _now);

  void start() {
    final uid = this.uid;
    if (uid == null || _clock != null) return;

    _subscriptions.addAll([
      _repository.watchMachines().listen(_onMachines, onError: _onError),
      _repository.watchSessionsOf(uid).listen(_onSessions, onError: _onError),
      _repository.watchNextFeeCollection().listen(
        _onNextFeeCollection,
        onError: (Object e) => debugPrint("$e"),
      ),
      _repository.watchUserSettings(uid).listen(
        _onUserSettings,
        onError: (Object e) => debugPrint("$e"),
      ),
    ]);

    _clock = Timer.periodic(_clockInterval, (_) => _tick());

    _freeMachineWatcher.restore(_machines).then((restored) {
      if (restored && !_disposed) notifyListeners();
    });
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
          RegExp("(^|[^A-Z0-9])$qr(\$|[^A-Z0-9])").hasMatch(wanted);
    }).firstOrNull;
  }

  void notifyWhenMachineFree() {
    if (isWaitingForFreeMachine || !allMachinesBusy) return;
    _freeMachineWatcher.start(_machines);
    notifyListeners();
  }

  void cancelNotifyWhenMachineFree() {
    if (!isWaitingForFreeMachine) return;
    _freeMachineWatcher.cancel();
    notifyListeners();
  }

  Future<void> startWash(
    Machine machine,
    int durationMinutes, {
    bool replaceRunning = false,
  }) async {
    final uid = this.uid;
    if (uid == null) throw const LaundryException("Zaloguj się ponownie.");

    await _repository.startWash(
      machine: machine,
      userId: uid,
      userName: _userName.isNotEmpty
          ? _userName
          : (_auth.currentUser?.email ?? "Mieszkanka"),
      durationMinutes: durationMinutes,
      replaceRunning: replaceRunning,
    );
    cancelNotifyWhenMachineFree();
  }

  Future<void> finishWash(Machine machine, {DateTime? finishedAt}) async {
    final uid = this.uid;
    if (uid == null) throw const LaundryException("Zaloguj się ponownie.");

    await _repository.finishWash(
      machine: machine,
      userId: uid,
      finishedAt: finishedAt,
    );
  }

  void _tick() {
    _now = DateTime.now();
    _finishMyExpiredWashes();
    _scheduleStatusTimer();
    _freeMachineWatcher.update(_machines);
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

  void _onMachines(List<Machine> machines) {
    _machines = machines;
    _now = DateTime.now();
    _isReady = true;
    _error = null;
    _finishMyExpiredWashes();
    _scheduleStatusTimer();
    _syncNotifications();
    _freeMachineWatcher.update(_machines);
    notifyListeners();
  }

  void _onSessions(List<LaundrySession> sessions) {
    _mySessions = sessions;
    notifyListeners();
  }

  void _onNextFeeCollection(FeeCollection? next) {
    _nextFeeCollection = next;
    notifyListeners();
  }

  void _onUserSettings(LaundryUserSettings settings) {
    _userName = settings.name;
    if (settings.notifyLaundry != _notifyLaundry) {
      _notifyLaundry = settings.notifyLaundry;
      _syncNotifications();
    }
  }

  void _onError(Object error) {
    debugPrint("LaundryStore: $error");
    _error = "Nie udało się pobrać danych pralni.";
    notifyListeners();
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
