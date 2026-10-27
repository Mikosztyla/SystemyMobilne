import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Color(0xFF5B4B8A),
      brightness: Brightness.light,
      surface: Color(0xFFFCF8F3),
      primaryContainer: Color(0xFFE7DEFF),
      secondaryContainer: Color(0xFFEFE6DA),
    );

    final base = ThemeData(
      colorScheme: colorScheme,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    return base.copyWith(
      textTheme: GoogleFonts.figtreeTextTheme(base.textTheme),
    );
  }

  // TODO: add dark theme
}
