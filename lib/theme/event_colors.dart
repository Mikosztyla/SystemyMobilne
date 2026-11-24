import 'package:material_ui/material_ui.dart';
import 'package:bursa_app/models/event.dart';

import 'color_pair.dart';



class EventColors extends ThemeExtension<EventColors> {
  final ColorPair meeting;
  final ColorPair religious;
  final ColorPair payment;
  final ColorPair other;

  const EventColors({
    required this.meeting,
    required this.religious,
    required this.payment,
    required this.other,
  });

  static const light = EventColors(
    meeting: ColorPair(background: Color(0xFFDFE3FA), foreground: Color(0xFF3B4F9E)),
    religious: ColorPair(background: Color(0xFFF6E6C6), foreground: Color(0xFF7A5300)),
    payment: ColorPair(background: Color(0xFFD9ECD3), foreground: Color(0xFF2F6427)),
    other: ColorPair(background: Color(0xFFF6DDE7), foreground: Color(0xFF8E3A5E)),
  );

  ColorPair forType(EventType type) => switch (type) {
    EventType.meeting => meeting,
    EventType.religious => religious,
    EventType.payment => payment,
    EventType.other => other,
  };

  @override
  EventColors copyWith({
    ColorPair? meeting,
    ColorPair? religious,
    ColorPair? payment,
    ColorPair? other,
  }) {
    return EventColors(
      meeting: meeting ?? this.meeting,
      religious: religious ?? this.religious,
      payment: payment ?? this.payment,
      other: other ?? this.other,
    );
  }

  @override
  EventColors lerp(EventColors? other, double t) {
    if (other is! EventColors) return this;
    return EventColors(
      meeting: ColorPair.lerp(meeting, other.meeting, t),
      religious: ColorPair.lerp(religious, other.religious, t),
      payment: ColorPair.lerp(payment, other.payment, t),
      other: ColorPair.lerp(this.other, other.other, t),
    );
  }
}