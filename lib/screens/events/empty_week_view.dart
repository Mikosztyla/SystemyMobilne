import 'package:material_ui/material_ui.dart';

class EmptyWeekView extends StatelessWidget {
  const EmptyWeekView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_available_outlined,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Spokojny tydzień",
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
                fontSize: 24,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "W tym tygodniu nic się nie dzieje. Gdy coś zostanie zaplanowane, zobaczysz to tutaj.",
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
