import 'package:bursa_app/models/machine.dart';
import 'package:bursa_app/screens/laundry/laundry_colors.dart';
import 'package:bursa_app/screens/laundry/machine_icon.dart';
import 'package:bursa_app/screens/laundry/status_chip.dart';
import 'package:material_ui/material_ui.dart';

import 'laundry_format.dart';

class MachineCard extends StatelessWidget {
  const MachineCard({
    super.key,
    required this.machine,
    required this.now,
    required this.isMine,
    this.onTap,
  });

  final Machine machine;
  final DateTime now;
  final bool isMine;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final status = machine.statusAt(now);
    final session = machine.currentSession;
    final (background, foreground) = LaundryColors.forStatus(status);

    final subtitle = switch (status) {
      MachineStatus.free => '${LaundryFormat.money(machine.priceGrosze)} za pranie',
      MachineStatus.busy =>
        '${isMine ? 'zostało' : 'zostało ok.'} ${LaundryFormat.remaining(session!.remainingAt(now))}',
      MachineStatus.outOfOrder => 'wyłączona z użytku',
    };

    return Material(
      color: LaundryColors.card,
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
              Row(
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (isMine) const _MineBadge(),
                          ],
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: LaundryColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusChip(status: status, busyUntil: session?.endsAt),
                ],
              ),
              if (status == MachineStatus.busy) ...[
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: session!.progressAt(now),
                    minHeight: 6,
                    backgroundColor: LaundryColors.busyBg,
                    color: LaundryColors.busyFg,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MineBadge extends StatelessWidget {
  const _MineBadge();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'TWOJE PRANIE',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }
}
