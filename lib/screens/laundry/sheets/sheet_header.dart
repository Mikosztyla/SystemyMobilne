import 'package:bursa_app/screens/laundry/machine_icon.dart';
import 'package:material_ui/material_ui.dart';

class SheetHeader extends StatelessWidget {
  final String overline;
  final String title;
  final Color background;
  final Color foreground;
  final IconData icon;
  final Widget? trailing;

  const SheetHeader({
    super.key,
    required this.overline,
    required this.title,
    required this.background,
    required this.foreground,
    this.icon = Icons.local_laundry_service,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        MachineIcon(
          background: background,
          foreground: foreground,
          size: 56,
          icon: icon,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                overline,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}
