import 'package:bursa_app/models/machine.dart';
import 'package:bursa_app/screens/laundry/fees_card.dart';
import 'package:bursa_app/screens/laundry/fees_history_screen.dart';
import 'package:bursa_app/screens/laundry/free_machine_alert_card.dart';
import 'package:bursa_app/screens/laundry/laundry_colors.dart';
import 'package:bursa_app/screens/laundry/laundry_format.dart';
import 'package:bursa_app/screens/laundry/machine_card.dart';
import 'package:bursa_app/screens/laundry/qr_scan_screen.dart';
import 'package:bursa_app/screens/laundry/sheets/my_wash_sheet.dart';
import 'package:bursa_app/services/laundry_store.dart';
import 'package:material_ui/material_ui.dart';

class LaundryScreen extends StatelessWidget {
  const LaundryScreen({super.key, required this.store});

  final LaundryStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pralnia')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          if (!store.isReady) {
            return Center(
              child: store.error != null
                  ? Text(store.error!)
                  : const CircularProgressIndicator(),
            );
          }

          final now = store.now;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              SizedBox(
                height: 64,
                child: FilledButton(
                  onPressed: () => _scan(context),
                  style: FilledButton.styleFrom(shape: const StadiumBorder()),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Skanuj pralkę',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'Pralki',
                trailing:
                    'Wolne: ${store.freeCount} z ${store.machines.length} · ${LaundryFormat.time(now)}',
              ),
              const SizedBox(height: 8),
              if (store.allMachinesBusy || store.isWaitingForFreeMachine) ...[
                FreeMachineAlertCard(store: store),
                const SizedBox(height: 10),
              ],
              if (store.machines.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Nie ma jeszcze żadnych pralek.'),
                ),
              for (final machine in store.machines) ...[
                MachineCard(
                  machine: machine,
                  now: now,
                  isMine: machine.isUsedBy(store.uid, now),
                  onTap: machine.isUsedBy(store.uid, now)
                      ? () => _openMyWash(context, machine)
                      : null,
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 14),
              _SectionHeader(
                title: 'Moje opłaty',
                trailing: LaundryFormat.monthYear(now),
              ),
              const SizedBox(height: 8),
              FeesCard(
                store: store,
                onOpenHistory: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FeesHistoryScreen(store: store),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _scan(BuildContext context) async {
    final message = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => QrScanScreen(store: store)),
    );
    if (message != null && context.mounted) _showMessage(context, message);
  }

  Future<void> _openMyWash(BuildContext context, Machine machine) async {
    final message = await showMyWashSheet(context, store: store, machine: machine);
    if (message != null && context.mounted) _showMessage(context, message);
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(fontSize: 13, color: LaundryColors.muted),
        ),
      ],
    );
  }
}
