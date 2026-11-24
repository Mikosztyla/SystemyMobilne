import 'package:bursa_app/models/event.dart';
import 'package:bursa_app/screens/utils/date_utils.dart';

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../theme/event_colors.dart';
import 'event_info_tile.dart';

class EventDetails extends StatelessWidget {
  final Event event;

  const EventDetails({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final eventColors = Theme.of(context)
        .extension<EventColors>()!
        .forType(event.type);

    final dateString =
        (isToday(event.start) ? "dziś, " : "") +
        DateFormat("EEEE d MMMM", "pl").format(event.start);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: eventColors.background,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: 32),
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 24),
            color: eventColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 8, right: 12),
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        event.type.icon,
                        size: 24,
                        color: eventColors.foreground,
                      ),
                      SizedBox(width: 6),
                      Text(
                        event.type.label,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: eventColors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  event.title,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                    color: eventColors.foreground,
                  ),
                ),
              ],
            ),
          ),
          EventInfoTile(
            title: dateString[0].toUpperCase() + dateString.substring(1),
            subtitle: "Data",
            icon: Icons.event_outlined,
          ),
          EventInfoTile(
            title: event.timeRange,
            subtitle: "Godzina",
            icon: Icons.schedule_outlined,
          ),
          EventInfoTile(
            title: event.place,
            subtitle: "Miejsce",
            icon: Icons.location_on_outlined,
          ),
          if (event.organizer != null) ...[
            EventInfoTile(
              title: event.organizer!,
              subtitle: "Organizator",
              icon: Icons.person_outline_rounded,
            ),
          ],
          if (event.description.isNotEmpty) ...[
            Divider(height: 1, indent: 12, endIndent: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Opis",
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    event.description,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

