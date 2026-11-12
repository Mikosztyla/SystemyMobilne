import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bursa_app/theme/status_colors.dart';

class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Color(0xFF5B4B8A),
      brightness: Brightness.light,
      surface: Color(0xFFFCF8F3),
      primaryContainer: Color(0xFFE7DEFF),
      secondaryContainer: Color(0xFFEFE6DA),
      onSecondaryContainer: Color(0xFF3A2F22),
      surfaceContainer: Color(0xFFF2ECE5),
      surfaceContainerLow: Color(0xFFF7F2EC),
    );

    final base = ThemeData(
      colorScheme: colorScheme,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(fontSize: 12, fontWeight: FontWeight.w700);
          }
          return const TextStyle(fontSize: 12, fontWeight: FontWeight.w500);
        }),
        indicatorColor: colorScheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.onPrimaryContainer);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
      ),
    );

    final textTheme = GoogleFonts.figtreeTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      extensions: const [StatusColors.light],
      appBarTheme: AppBarTheme(
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // TODO: add dark theme
}
