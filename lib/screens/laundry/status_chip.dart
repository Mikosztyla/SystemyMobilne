import 'package:bursa_app/models/machine.dart';
import 'package:bursa_app/screens/laundry/laundry_format.dart';
import 'package:bursa_app/screens/laundry/machine_status_colors.dart';
import 'package:material_ui/material_ui.dart';

class StatusChip extends StatelessWidget {
  final MachineStatus status;
  final DateTime? busyUntil;
  final bool short;

  const StatusChip({
    super.key,
    required this.status,
    this.busyUntil,
    this.short = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final (background, foreground) = status.colors(context);
    final until = busyUntil == null ? "" : LaundryFormat.time(busyUntil!);
    final (IconData icon, String label) = switch (status) {
      MachineStatus.free => (Icons.check_circle, "Wolna"),
      MachineStatus.busy => (
        Icons.hourglass_top,
        short ? "do $until" : "Zajęta do $until",
      ),
      MachineStatus.outOfOrder => (Icons.build, "Awaria"),
    };

    return Container(
      height: 30,
      padding: const EdgeInsets.fromLTRB(7, 0, 10, 0),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
