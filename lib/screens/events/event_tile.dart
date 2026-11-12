import 'package:material_ui/material_ui.dart';

import '../../models/event.dart';
import '../../theme/event_colors.dart';
import '../utils/date_utils.dart';

class EventTile extends StatelessWidget {
  final Event event;

  const EventTile({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final dimmed =
        event.isPast && !event.start.isBefore(startOfWeek(DateTime.now()));
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final eventColors = dimmed
        ? EventColors(
            background: colorScheme.surfaceContainerHighest,
            foreground: colorScheme.onSurfaceVariant,
          )
        : Theme.of(context).extension<CategoryColors>()!.forType(event.type);

    return Opacity(
      opacity: dimmed ? 0.6 : 1,
      child: Material(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {}, // TODO
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: eventColors.background,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    event.type.icon,
                    size: 30,
                    color: eventColors.foreground,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.type.label,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: eventColors.foreground,
                        ),
                      ),
                      Text(
                        event.title,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        "${event.timeRange} · ${event.place}",
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Icon(Icons.chevron_right_rounded, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
