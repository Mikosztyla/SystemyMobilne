import 'package:material_ui/material_ui.dart';

import 'color_pair.dart';

class AdminColors extends ThemeExtension<AdminColors> {
  final ColorPair residents;
  final ColorPair events;
  final ColorPair duties;
  final ColorPair laundry;

  const AdminColors({
    required this.residents,
    required this.events,
    required this.duties,
    required this.laundry,
  });

  static const light = AdminColors(
    residents: ColorPair(background: Color(0xFFF5E7B8), foreground: Color(0xFF6B5200)),
    events: ColorPair(background: Color(0xFFEBDDF0), foreground: Color(0xFF5D3870)),
    duties: ColorPair(background: Color(0xFFCDEDEC), foreground: Color(0xFF00676A)),
    laundry: ColorPair(background: Color(0xFFFBDDD0), foreground: Color(0xFF8A3B1E)),
  );

  @override
  AdminColors copyWith({
    ColorPair? residents,
    ColorPair? events,
    ColorPair? duties,
    ColorPair? laundry,
  }) {
    return AdminColors(
      residents: residents ?? this.residents,
      events: events ?? this.events,
      duties: duties ?? this.duties,
      laundry: laundry ?? this.laundry,
    );
  }

  @override
  AdminColors lerp(AdminColors? other, double t) {
    if (other is! AdminColors) return this;
    return AdminColors(
      residents: ColorPair.lerp(residents, other.residents, t),
      events: ColorPair.lerp(events, other.events, t),
      duties: ColorPair.lerp(duties, other.duties, t),
      laundry: ColorPair.lerp(laundry, other.laundry, t),
    );
  }
}