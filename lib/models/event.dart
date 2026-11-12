import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:material_ui/material_ui.dart';

import '../screens/utils/date_utils.dart';

class Event {
  final String id;
  final String title;
  final String place;
  final DateTime start;
  final DateTime? end;
  final String description;
  final EventType type;

  const Event({
    required this.id,
    required this.title,
    required this.place,
    required this.start,
    this.end,
    required this.description,
    required this.type,
  });

  factory Event.fromMap(Map<String, dynamic> data, String id) {
    return Event(
      id: id,
      title: data[EventFields.title] as String,
      place: data[EventFields.place] as String,
      start: (data[EventFields.start] as Timestamp).toDate(),
      end: (data[EventFields.end] as Timestamp?)?.toDate(),
      description: data[EventFields.description] as String? ?? "",
      type:
      EventType.values.asNameMap()[data[EventFields.type]] ??
          EventType.other,
    );
  }

  String get timeRange {
    final startText = timeFormat.format(start);
    if (end == null) return startText;
    return '$startText–${timeFormat.format(end!)}';
  }


  bool get isPast {
    final now = DateTime.now();
    if (end == null) return now.isAfter(DateTime(start.year, start.month, start.day + 1)); // start day finished
    return now.isAfter(end!); // now > end
  }

}
abstract final class EventFields {
  static const title = "title";
  static const place = "place";
  static const start = "startAt";
  static const end = "endAt";
  static const description = "description";
  static const type = "type";
}

enum EventType {
  meeting("Spotkanie", Icons.groups_outlined),
  religious("Wydarzenie religijne", Icons.church_outlined),
  payment("Zbiórka opłat", Icons.payments_outlined),
  other("Inne", Icons.celebration_outlined);

  const EventType(this.label, this.icon);

  final String label;
  final IconData icon;
}
