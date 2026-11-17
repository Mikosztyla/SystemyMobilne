import 'package:bursa_app/models/machine.dart';
import 'package:bursa_app/screens/laundry/laundry_format.dart';
import 'package:bursa_app/screens/laundry/machine_icon.dart';
import 'package:bursa_app/screens/laundry/machine_status_colors.dart';
import 'package:bursa_app/screens/laundry/status_chip.dart';
import 'package:bursa_app/screens/laundry/wash_progress_bar.dart';
import 'package:material_ui/material_ui.dart';

class MachineCard extends StatelessWidget {
  final Machine machine;
  final DateTime now;
  final bool isMine;
  final VoidCallback? onTap;

  const MachineCard({
    super.key,
    required this.machine,
    required this.now,
    required this.isMine,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = machine.statusAt(now);
    final session = machine.currentSession;

    return Material(
      color: colorScheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isMine
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            children: [
              _buildHeader(context, status),
              if (status == MachineStatus.busy && session != null) ...[
                const SizedBox(height: 10),
                WashProgressBar(value: session.progressAt(now)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MachineStatus status) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final (background, foreground) = status.colors(context);

    return Row(
      children: [
        MachineIcon(background: background, foreground: foreground),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    machine.name,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isMine) const _MineBadge(),
                ],
              ),
              Text(
                _subtitle(status),
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        StatusChip(status: status, busyUntil: machine.currentSession?.endsAt),
      ],
    );
  }

  String _subtitle(MachineStatus status) {
    return switch (status) {
      MachineStatus.free =>
        "${LaundryFormat.money(machine.priceGrosze)} za pranie",
      MachineStatus.busy =>
        "${isMine ? "zostało" : "zostało ok."} ${LaundryFormat.remaining(machine.currentSession!.remainingAt(now))}",
      MachineStatus.outOfOrder => "wyłączona z użytku",
    };
  }
}

class _MineBadge extends StatelessWidget {
  const _MineBadge();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        "TWOJE PRANIE",
        style: textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }
}
