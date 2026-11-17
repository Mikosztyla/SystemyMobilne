import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../utils/date_utils.dart';

class WeekPanel extends StatelessWidget {
  final Function()? leftClick;
  final Function()? rightClick;
  final DateTime startDate;

  const WeekPanel({
    super.key,
    required this.leftClick,
    required this.rightClick,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final endDate = endOfWeek(startDate);
    final now = DateTime.now();
    return Row(
      children: [
        IconButton(
          onPressed: leftClick,
          icon: Icon(Icons.chevron_left_rounded),
          iconSize: 26,
        ),
        Expanded(
          child: Center(
            child: Column(
              children: [
                Text(
                  FormatWeek(startDate, endDate),
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (now.isAfter(startDate) && now.isBefore(endDate)) ...[
                  Text(
                    "ten tydzień",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        IconButton(
          onPressed: rightClick,
          icon: Icon(Icons.chevron_right_rounded),
          iconSize: 26,
        ),
      ],
    );
  }

  String FormatWeek(DateTime start, DateTime end) {
    if (start.month == end.month)
      return start.day.toString() + DateFormat("-d MMMM", "pl").format(end);
    return DateFormat("d MMMM", "pl").format(start) +
        DateFormat("-d MMMM", "pl").format(end);
  }
}
