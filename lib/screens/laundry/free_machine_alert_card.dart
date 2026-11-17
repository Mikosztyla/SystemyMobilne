import 'package:bursa_app/screens/laundry/laundry_format.dart';
import 'package:bursa_app/services/laundry_store.dart';
import 'package:bursa_app/theme/status_colors.dart';
import 'package:material_ui/material_ui.dart';

class FreeMachineAlertCard extends StatelessWidget {
  final LaundryStore store;

  const FreeMachineAlertCard({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final statusColors = StatusColors.of(context);
    final waiting = store.isWaitingForFreeMachine;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColors.busy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMessage(context, waiting),
          const SizedBox(height: 12),
          if (waiting)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: store.cancelNotifyWhenMachineFree,
                style: TextButton.styleFrom(
                  foregroundColor: statusColors.onBusy,
                ),
                child: const Text("Nie powiadamiaj"),
              ),
            )
          else
            _NotifyButton(onPressed: store.notifyWhenMachineFree),
        ],
      ),
    );
  }

  Widget _buildMessage(BuildContext context, bool waiting) {
    final textTheme = Theme.of(context).textTheme;
    final statusColors = StatusColors.of(context);
    final hint = _nextFreeHint();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          waiting ? Icons.notifications_active : Icons.notifications_none,
          color: statusColors.onBusy,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                waiting ? "Powiadomimy Cię" : "Wszystkie pralki są zajęte",
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: statusColors.onBusy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                waiting
                    ? "Dostaniesz powiadomienie, gdy tylko któraś pralka się zwolni. $hint"
                          .trim()
                    : hint,
                style: textTheme.bodyMedium?.copyWith(
                  color: statusColors.onBusy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _nextFreeHint() {
    final next = store.nextToFree;
    final endsAt = next?.currentSession?.endsAt;
    if (next == null || endsAt == null) return "";
    return "Najbliższa zwolni się ok. ${LaundryFormat.time(endsAt)} (${next.name}).";
  }
}

class _NotifyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _NotifyButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final statusColors = StatusColors.of(context);

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: statusColors.onBusy,
        foregroundColor: statusColors.busy,
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
              "Powiadom mnie, gdy pralka się zwolni",
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
