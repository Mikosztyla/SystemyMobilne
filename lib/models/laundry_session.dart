import 'package:cloud_firestore/cloud_firestore.dart';

class LaundrySession {
  final String id;
  final String machineId;
  final String machineName;
  final String userId;
  final String userName;
  final DateTime startedAt;
  final int durationMinutes;
  final DateTime? finishedAt;
  final int costGrosze;

  const LaundrySession({
    required this.id,
    required this.machineId,
    required this.machineName,
    required this.userId,
    required this.userName,
    required this.startedAt,
    required this.durationMinutes,
    required this.costGrosze,
    this.finishedAt,
  });

  factory LaundrySession.fromMap(String id, Map<String, dynamic> data) {
    return LaundrySession(
      id: id,
      machineId: data[LaundrySessionFields.machineId] as String,
      machineName: data[LaundrySessionFields.machineName] as String? ?? "",
      userId: data[LaundrySessionFields.userId] as String,
      userName: data[LaundrySessionFields.userName] as String? ?? "",
      startedAt: (data[LaundrySessionFields.startedAt] as Timestamp).toDate(),
      durationMinutes: (data[LaundrySessionFields.durationMinutes] as num)
          .toInt(),
      costGrosze: (data[LaundrySessionFields.costGrosze] as num).toInt(),
      finishedAt: (data[LaundrySessionFields.finishedAt] as Timestamp?)
          ?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    LaundrySessionFields.machineId: machineId,
    LaundrySessionFields.machineName: machineName,
    LaundrySessionFields.userId: userId,
    LaundrySessionFields.userName: userName,
    LaundrySessionFields.startedAt: Timestamp.fromDate(startedAt),
    LaundrySessionFields.durationMinutes: durationMinutes,
    LaundrySessionFields.costGrosze: costGrosze,
    if (finishedAt != null)
      LaundrySessionFields.finishedAt: Timestamp.fromDate(finishedAt!),
  };
}

abstract final class LaundrySessionFields {
  static const machineId = "machineId";
  static const machineName = "machineName";
  static const userId = "userId";
  static const userName = "userName";
  static const startedAt = "startedAt";
  static const durationMinutes = "durationMinutes";
  static const finishedAt = "finishedAt";
  static const costGrosze = "costGrosze";
}
