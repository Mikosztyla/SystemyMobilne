import 'package:bursa_app/models/machine.dart';
import 'package:bursa_app/screens/laundry/laundry_colors.dart';
import 'package:bursa_app/screens/laundry/laundry_format.dart';
import 'package:bursa_app/screens/laundry/sheets/laundry_sheet.dart';
import 'package:bursa_app/screens/laundry/sheets/sheet_button.dart';
import 'package:bursa_app/screens/laundry/sheets/sheet_header.dart';
import 'package:bursa_app/screens/laundry/sheets/sheet_info_tile.dart';
import 'package:bursa_app/screens/laundry/status_chip.dart';
import 'package:bursa_app/services/laundry_exception.dart';
import 'package:bursa_app/services/laundry_store.dart';
import 'package:material_ui/material_ui.dart';

Future<String?> showMyWashSheet(
  BuildContext context, {
  required LaundryStore store,
  required Machine machine,
}) {
  return showLaundrySheet<String>(
    context,
    MyWashSheet(store: store, machineId: machine.id),
  );
}

class MyWashSheet extends StatefulWidget {
  const MyWashSheet({super.key, required this.store, required this.machineId});

  final LaundryStore store;
  final String machineId;

  @override
  State<MyWashSheet> createState() => _MyWashSheetState();
}

class _MyWashSheetState extends State<MyWashSheet> {
  bool _saving = false;
  String? _error;

  Future<void> _finish(Machine machine) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.store.finishWash(machine);
      if (!mounted) return;
      Navigator.of(context).pop('${machine.name} jest wolna. Dziękujemy!');
    } on LaundryException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final store = widget.store;
        final machine = store.machines
            .where((m) => m.id == widget.machineId)
            .firstOrNull;
        final session = machine?.currentSession;
        final now = store.now;

        if (machine == null || session == null || session.userId != store.uid) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text('To pranie zostało już zakończone.'),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetHeader(
              overline: 'Twoje pranie',
              title: machine.name,
              background: LaundryColors.busyBg,
              foreground: LaundryColors.busyFg,
              trailing: StatusChip(
                status: machine.statusAt(now),
                busyUntil: session.endsAt,
                short: true,
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: session.progressAt(now),
                minHeight: 6,
                backgroundColor: LaundryColors.busyBg,
                color: LaundryColors.busyFg,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              machine.isBusyAt(now)
                  ? 'zostało ${LaundryFormat.remaining(session.remainingAt(now))}'
                  : 'pranie się skończyło – możesz je odebrać',
              style: const TextStyle(color: LaundryColors.muted),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SheetInfoTile(
                  icon: Icons.play_circle_outline,
                  label: 'Start',
                  value: LaundryFormat.time(session.startedAt),
                ),
                const SizedBox(width: 8),
                SheetInfoTile(
                  icon: Icons.schedule,
                  label: 'Koniec',
                  value: LaundryFormat.time(session.endsAt),
                ),
                const SizedBox(width: 8),
                SheetInfoTile(
                  icon: Icons.payments_outlined,
                  label: 'Koszt',
                  value: LaundryFormat.money(machine.priceGrosze),
                ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 20),
            SheetButton(
              icon: Icons.check,
              label: 'Zakończ pranie',
              loading: _saving,
              onPressed: () => _finish(machine),
            ),
            const SizedBox(height: 8),
            const Text(
              'Naciśnij po wyjęciu prania – pralka stanie się wolna dla innych.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: LaundryColors.muted),
            ),
          ],
        );
      },
    );
  }
}
