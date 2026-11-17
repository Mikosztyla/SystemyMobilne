import 'package:material_ui/material_ui.dart';


class EventInfoTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;

  const EventInfoTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      leading: icon == null
          ? null
          : Icon(icon, size: 32, color: colorScheme.primary),
      title: Text(
        title,
        style: textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
          fontSize: 16,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
        subtitle!,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
      ),
    );
  }
}