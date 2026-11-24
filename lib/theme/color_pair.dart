import 'package:material_ui/material_ui.dart';

class ColorPair {
  final Color background;
  final Color foreground;

  const ColorPair({required this.background, required this.foreground});

  static ColorPair lerp(ColorPair a, ColorPair b, double t) {
    return ColorPair(
      background: Color.lerp(a.background, b.background, t)!,
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
    );
  }
}