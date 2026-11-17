import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentSession {
  final String sessionId;
  final String userId;
  final String userName;
  final DateTime startedAt;
  final int durationMinutes;

  const CurrentSession({
    required this.sessionId,
    required this.userId,
    required this.userName,
    required this.startedAt,
    required this.durationMinutes,
  });

  factory CurrentSession.fromMap(Map<String, dynamic> data) {
    return CurrentSession(
      sessionId: data[CurrentSessionFields.sessionId] as String,
      userId: data[CurrentSessionFields.userId] as String,
      userName: data[CurrentSessionFields.userName] as String,
      startedAt: (data[CurrentSessionFields.startedAt] as Timestamp).toDate(),
      durationMinutes: (data[CurrentSessionFields.durationMinutes] as num)
          .toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
    CurrentSessionFields.sessionId: sessionId,
    CurrentSessionFields.userId: userId,
    CurrentSessionFields.userName: userName,
    CurrentSessionFields.startedAt: Timestamp.fromDate(startedAt),
    CurrentSessionFields.durationMinutes: durationMinutes,
  };

  DateTime get endsAt => startedAt.add(Duration(minutes: durationMinutes));

  Duration remainingAt(DateTime now) {
    final left = endsAt.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  double progressAt(DateTime now) {
    final total = durationMinutes * 60;
    if (total <= 0) return 1;
    final elapsed = now.difference(startedAt).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0).toDouble();
  }
}

abstract final class CurrentSessionFields {
  static const sessionId = "sessionId";
  static const userId = "userId";
  static const userName = "userName";
  static const startedAt = "startedAt";
  static const durationMinutes = "durationMinutes";
}
