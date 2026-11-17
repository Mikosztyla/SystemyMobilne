import 'package:material_ui/material_ui.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String trailing;

  const SectionHeader({super.key, required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          trailing,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
