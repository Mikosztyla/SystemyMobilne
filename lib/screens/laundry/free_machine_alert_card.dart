import 'package:bursa_app/screens/laundry/laundry_colors.dart';
import 'package:bursa_app/services/laundry_store.dart';
import 'package:material_ui/material_ui.dart';

import 'laundry_format.dart';

class FreeMachineAlertCard extends StatelessWidget {
  const FreeMachineAlertCard({super.key, required this.store});

  final LaundryStore store;

  @override
  Widget build(BuildContext context) {
    final next = store.nextToFree;
    final endsAt = next?.currentSession?.endsAt;
    final waiting = store.isWaitingForFreeMachine;
    final hint = endsAt == null
        ? ''
        : ' Najbliższa zwolni się ok. ${LaundryFormat.time(endsAt)} (${next!.name}).';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LaundryColors.busyBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                waiting
                    ? Icons.notifications_active
                    : Icons.notifications_none,
                color: LaundryColors.busyFg,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      waiting
                          ? 'Powiadomimy Cię'
                          : 'Wszystkie pralki są zajęte',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: LaundryColors.busyFg,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      waiting
                          ? 'Dostaniesz powiadomienie, gdy tylko któraś pralka '
                                'się zwolni.$hint'
                          : hint.trim(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: LaundryColors.busyFg,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (waiting)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: store.cancelNotifyWhenMachineFree,
                style: TextButton.styleFrom(
                  foregroundColor: LaundryColors.busyFg,
                ),
                child: const Text('Nie powiadamiaj'),
              ),
            )
          else
            FilledButton(
              onPressed: store.notifyWhenMachineFree,
              style: FilledButton.styleFrom(
                backgroundColor: LaundryColors.busyFg,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_active_outlined, size: 20),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Powiadom mnie, gdy pralka się zwolni',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
