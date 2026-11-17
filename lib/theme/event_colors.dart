import 'package:material_ui/material_ui.dart';
import 'package:bursa_app/models/event.dart';

class EventColors {
  final Color background;
  final Color foreground;

  const EventColors({required this.background, required this.foreground});

  static EventColors lerp(EventColors a, EventColors b, double t) {
    return EventColors(
      background: Color.lerp(a.background, b.background, t)!,
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
    );
  }
}

class CategoryColors extends ThemeExtension<CategoryColors> {
  final EventColors meeting;
  final EventColors religious;
  final EventColors payment;
  final EventColors other;

  const CategoryColors({
    required this.meeting,
    required this.religious,
    required this.payment,
    required this.other,
  });

  static const light = CategoryColors(
    meeting: EventColors(background: Color(0xFFDFE3FA), foreground: Color(0xFF3B4F9E)),
    religious: EventColors(background: Color(0xFFF6E6C6), foreground: Color(0xFF7A5300)),
    payment: EventColors(background: Color(0xFFD9ECD3), foreground: Color(0xFF2F6427)),
    other: EventColors(background: Color(0xFFF6DDE7), foreground: Color(0xFF8E3A5E)),
  );

  EventColors forType(EventType type) => switch (type) {
    EventType.meeting => meeting,
    EventType.religious => religious,
    EventType.payment => payment,
    EventType.other => other,
  };

  @override
  CategoryColors copyWith({
    EventColors? meeting,
    EventColors? religious,
    EventColors? payment,
    EventColors? other,
  }) {
    return CategoryColors(
      meeting: meeting ?? this.meeting,
      religious: religious ?? this.religious,
      payment: payment ?? this.payment,
      other: other ?? this.other,
    );
  }

  @override
  CategoryColors lerp(CategoryColors? other, double t) {
    if (other is! CategoryColors) return this;
    return CategoryColors(
      meeting: EventColors.lerp(meeting, other.meeting, t),
      religious: EventColors.lerp(religious, other.religious, t),
      payment: EventColors.lerp(payment, other.payment, t),
      other: EventColors.lerp(this.other, other.other, t),
    );
  }
}