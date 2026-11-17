import 'package:material_ui/material_ui.dart';

class MachineIcon extends StatelessWidget {
  final Color background;
  final Color foreground;
  final double size;
  final IconData icon;

  const MachineIcon({
    super.key,
    required this.background,
    required this.foreground,
    this.size = 44,
    this.icon = Icons.local_laundry_service,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: Icon(icon, color: foreground, size: size * 0.55),
    );
  }
}
