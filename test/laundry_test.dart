import 'package:bursa_app/models/current_session.dart';
import 'package:bursa_app/models/machine.dart';
import 'package:bursa_app/screens/laundry/laundry_format.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

Machine machineWith({CurrentSession? session, bool outOfOrder = false}) {
  return Machine(
    id: "id",
    name: "Pralka 1",
    place: "Pralnia",
    qrCode: "PR-01",
    priceGrosze: 500,
    outOfOrder: outOfOrder,
    currentSession: session,
  );
}

CurrentSession sessionFrom(DateTime start, {int minutes = 90, String userId = "u1"}) {
  return CurrentSession(
    sessionId: "s1",
    userId: userId,
    userName: "Jan",
    startedAt: start,
    durationMinutes: minutes,
  );
}

void main() {
  final start = DateTime(2026, 11, 10, 13, 0);

  group("Machine.statusAt", () {
    test("bez sesji pralka jest wolna", () {
      expect(machineWith().statusAt(start), MachineStatus.free);
    });

    test("w trakcie prania pralka jest zajęta", () {
      final machine = machineWith(session: sessionFrom(start));
      expect(machine.statusAt(start.add(const Duration(minutes: 30))), MachineStatus.busy);
    });

    test("po upływie czasu programu pralka jest wolna, nawet bez „Zakończ”", () {
      final machine = machineWith(session: sessionFrom(start));
      expect(machine.statusAt(start.add(const Duration(minutes: 91))), MachineStatus.free);
    });

    test("awaria ma pierwszeństwo przed wszystkim", () {
      final machine = machineWith(session: sessionFrom(start), outOfOrder: true);
      expect(machine.statusAt(start), MachineStatus.outOfOrder);
    });

    test("isUsedBy rozpoznaje własne pranie", () {
      final machine = machineWith(session: sessionFrom(start, userId: "me"));
      final now = start.add(const Duration(minutes: 5));
      expect(machine.isUsedBy("me", now), isTrue);
      expect(machine.isUsedBy("ktoś inny", now), isFalse);
    });
  });

  group("CurrentSession", () {
    test("liczy koniec, pozostały czas i postęp", () {
      final session = sessionFrom(start, minutes: 60);
      final now = start.add(const Duration(minutes: 15));
      expect(session.endsAt, DateTime(2026, 11, 10, 14, 0));
      expect(session.remainingAt(now), const Duration(minutes: 45));
      expect(session.progressAt(now), closeTo(0.25, 0.001));
    });

    test("fromMap czyta dane z Firestore", () {
      final machine = Machine.fromMap("abc", {
        "name": "Pralka 2",
        "place": "Piwnica",
        "qrCode": "PR-02",
        "priceGrosze": 500,
        "outOfOrder": false,
        "currentSession": {
          "sessionId": "s1",
          "userId": "u1",
          "userName": "Jan",
          "startedAt": Timestamp.fromDate(start),
          "durationMinutes": 75,
        },
      });
      expect(machine.currentSession!.endsAt, DateTime(2026, 11, 10, 14, 15));
    });
  });

  group("LaundryFormat", () {
    test("formatuje po polsku", () {
      expect(LaundryFormat.money(500), "5,00 zł");
      expect(LaundryFormat.money(1505), "15,05 zł");
      expect(LaundryFormat.time(DateTime(2026, 1, 1, 9, 5)), "09:05");
      expect(LaundryFormat.duration(75), "1:15 h");
      expect(LaundryFormat.shortDate(DateTime(2026, 10, 16)), "pt., 16 paź.");
      expect(LaundryFormat.monthYear(DateTime(2026, 10)), "październik 2026");
      expect(LaundryFormat.remaining(const Duration(minutes: 33, seconds: 10)), "34 min");
      expect(LaundryFormat.remaining(const Duration(minutes: 65)), "1 h 5 min");
    });
  });
}
