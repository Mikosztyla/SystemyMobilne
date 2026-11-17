import 'package:bursa_app/models/app_user.dart';
import 'package:bursa_app/models/current_session.dart';
import 'package:bursa_app/models/firestore_collections.dart';
import 'package:bursa_app/models/laundry_session.dart';
import 'package:bursa_app/models/machine.dart';
import 'package:bursa_app/services/laundry_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

typedef FeeCollection = ({DateTime start, DateTime? end});

typedef LaundryUserSettings = ({String name, bool notifyLaundry});

class LaundryRepository {
  final FirebaseFirestore _db;

  LaundryRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _machines =>
      _db.collection(FirestoreCollections.machines);

  CollectionReference<Map<String, dynamic>> get _sessions =>
      _db.collection(FirestoreCollections.laundrySessions);

  Stream<List<Machine>> watchMachines() {
    return _machines.snapshots().map((snapshot) {
      final machines = <Machine>[];
      for (final doc in snapshot.docs) {
        try {
          machines.add(Machine.fromMap(doc.id, doc.data()));
        } catch (e) {
          debugPrint("Pominięto pralkę ${doc.id} – złe dane: $e");
        }
      }
      machines.sort((a, b) => a.name.compareTo(b.name));
      return machines;
    });
  }

  Stream<List<LaundrySession>> watchSessionsOf(String uid) {
    return _sessions
        .where(LaundrySessionFields.userId, isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final sessions = <LaundrySession>[];
          for (final doc in snapshot.docs) {
            try {
              sessions.add(LaundrySession.fromMap(doc.id, doc.data()));
            } catch (e) {
              debugPrint("Pominięto pranie ${doc.id} – złe dane: $e");
            }
          }
          sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
          return sessions;
        });
  }

  Stream<FeeCollection?> watchNextFeeCollection() {
    return _db
        .collection(FirestoreCollections.events)
        .where("type", isEqualTo: "feeCollection")
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          FeeCollection? next;
          for (final doc in snapshot.docs) {
            final start = (doc.data()["startAt"] as Timestamp?)?.toDate();
            if (start == null || start.isBefore(today)) continue;
            if (next == null || start.isBefore(next.start)) {
              next = (
                start: start,
                end: (doc.data()["endAt"] as Timestamp?)?.toDate(),
              );
            }
          }
          return next;
        });
  }

  Stream<LaundryUserSettings> watchUserSettings(String uid) {
    return _db
        .collection(FirestoreCollections.users)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          final data = snapshot.data();
          final name = [data?[UserFields.name], data?[UserFields.surname]]
              .whereType<String>()
              .where((part) => part.isNotEmpty)
              .join(" ");
          return (
            name: name,
            notifyLaundry: data?[UserFields.notifyLaundry] as bool? ?? true,
          );
        });
  }

  Future<void> startWash({
    required Machine machine,
    required String userId,
    required String userName,
    required int durationMinutes,
    required bool replaceRunning,
  }) async {
    final machineRef = _machines.doc(machine.id);
    final sessionRef = _sessions.doc();

    try {
      await _db.runTransaction((tx) async {
        final snapshot = await tx.get(machineRef);
        final data = snapshot.data();
        if (data == null) {
          throw const LaundryException("Tej pralki nie ma już w systemie.");
        }
        final fresh = Machine.fromMap(snapshot.id, data);
        final startedAt = DateTime.now();
        if (fresh.outOfOrder) {
          throw const LaundryException("Ta pralka ma awarię.");
        }
        if (fresh.isBusyAt(startedAt) && !replaceRunning) {
          throw const LaundryException(
            "Ktoś właśnie zaczął pranie na tej pralce.",
          );
        }

        final session = LaundrySession(
          id: sessionRef.id,
          machineId: fresh.id,
          machineName: fresh.name,
          userId: userId,
          userName: userName,
          startedAt: startedAt,
          durationMinutes: durationMinutes,
          costGrosze: fresh.priceGrosze,
        );
        final current = CurrentSession(
          sessionId: sessionRef.id,
          userId: userId,
          userName: userName,
          startedAt: startedAt,
          durationMinutes: durationMinutes,
        );

        tx.set(sessionRef, session.toMap());
        tx.update(machineRef, {MachineFields.currentSession: current.toMap()});
      });
    } on LaundryException {
      rethrow;
    } catch (e) {
      debugPrint("startWash: $e");
      throw const LaundryException(
        "Nie udało się rozpocząć prania. Sprawdź internet i spróbuj ponownie.",
      );
    }
  }

  Future<void> finishWash({
    required Machine machine,
    required String userId,
    DateTime? finishedAt,
  }) async {
    final machineRef = _machines.doc(machine.id);
    final expectedSessionId = machine.currentSession?.sessionId;

    try {
      await _db.runTransaction((tx) async {
        final snapshot = await tx.get(machineRef);
        final data = snapshot.data();
        if (data == null) return;
        final current = Machine.fromMap(snapshot.id, data).currentSession;
        if (current == null || current.userId != userId) return;
        if (current.sessionId != expectedSessionId) return;

        tx.update(_sessions.doc(current.sessionId), {
          LaundrySessionFields.finishedAt: finishedAt == null
              ? Timestamp.now()
              : Timestamp.fromDate(finishedAt),
        });
        tx.update(machineRef, {MachineFields.currentSession: null});
      });
    } catch (e) {
      debugPrint("finishWash: $e");
      throw const LaundryException(
        "Nie udało się zakończyć prania. Spróbuj ponownie.",
      );
    }
  }
}
