import 'package:bursa_app/models/laundry_session.dart';

abstract final class LaundryFees {
  static List<LaundrySession> inMonth(
    Iterable<LaundrySession> sessions,
    DateTime month,
  ) {
    return sessions
        .where(
          (s) =>
              s.startedAt.year == month.year &&
              s.startedAt.month == month.month,
        )
        .toList();
  }

  static int totalGrosze(Iterable<LaundrySession> sessions) {
    return sessions.fold(0, (total, s) => total + s.costGrosze);
  }

  static Map<DateTime, List<LaundrySession>> byMonth(
    Iterable<LaundrySession> sessions,
  ) {
    final result = <DateTime, List<LaundrySession>>{};
    for (final s in sessions) {
      final key = DateTime(s.startedAt.year, s.startedAt.month);
      result.putIfAbsent(key, () => []).add(s);
    }
    return result;
  }
}
