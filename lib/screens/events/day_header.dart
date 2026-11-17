import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../utils/date_utils.dart';

class DayHeader extends StatelessWidget {
  final DateTime date;

  const DayHeader({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Text(
      (isToday(date) ? "DZIŚ · " : "") +
          DateFormat("EEEE · d MMM", "pl").format(date).toUpperCase(),
      style: textTheme.headlineMedium?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: isToday(date)
            ? colorScheme.primary
            : colorScheme.onSurfaceVariant,
      ),
    );
  }
}
