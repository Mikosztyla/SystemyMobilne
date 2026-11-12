import 'package:bursa_app/models/current_session.dart';
import 'package:bursa_app/models/machine.dart';
import 'package:bursa_app/screens/laundry/laundry_format.dart';
import 'package:bursa_app/screens/laundry/sheets/laundry_sheet.dart';
import 'package:bursa_app/screens/laundry/sheets/sheet_button.dart';
import 'package:bursa_app/screens/laundry/sheets/sheet_header.dart';
import 'package:bursa_app/screens/laundry/sheets/sheet_info_tile.dart';
import 'package:bursa_app/screens/laundry/status_chip.dart';
import 'package:bursa_app/screens/laundry/wash_progress_bar.dart';
import 'package:bursa_app/services/laundry_exception.dart';
import 'package:bursa_app/services/laundry_store.dart';
import 'package:bursa_app/theme/status_colors.dart';
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
  final LaundryStore store;
  final String machineId;

  const MyWashSheet({super.key, required this.store, required this.machineId});

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
      Navigator.of(context).pop("${machine.name} jest wolna. Dziękujemy!");
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

        if (machine == null || session == null || session.userId != store.uid) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text("To pranie zostało już zakończone."),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context, machine, session),
            const SizedBox(height: 20),
            ..._buildProgress(context, machine, session),
            const SizedBox(height: 16),
            _buildDetails(machine, session),
            ..._buildActions(context, machine),
          ],
        );
      },
    );
  }

  Widget _buildHeader(
    BuildContext context,
    Machine machine,
    CurrentSession session,
  ) {
    final statusColors = StatusColors.of(context);

    return SheetHeader(
      overline: "Twoje pranie",
      title: machine.name,
      background: statusColors.busy,
      foreground: statusColors.onBusy,
      trailing: StatusChip(
        status: machine.statusAt(widget.store.now),
        busyUntil: session.endsAt,
        short: true,
      ),
    );
  }

  List<Widget> _buildProgress(
    BuildContext context,
    Machine machine,
    CurrentSession session,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final now = widget.store.now;

    return [
      WashProgressBar(value: session.progressAt(now)),
      const SizedBox(height: 8),
      Text(
        machine.isBusyAt(now)
            ? "zostało ${LaundryFormat.remaining(session.remainingAt(now))}"
            : "pranie się skończyło – możesz je odebrać",
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    ];
  }

  Widget _buildDetails(Machine machine, CurrentSession session) {
    return Row(
      children: [
        SheetInfoTile(
          icon: Icons.play_circle_outline,
          label: "Start",
          value: LaundryFormat.time(session.startedAt),
        ),
        const SizedBox(width: 8),
        SheetInfoTile(
          icon: Icons.schedule,
          label: "Koniec",
          value: LaundryFormat.time(session.endsAt),
        ),
        const SizedBox(width: 8),
        SheetInfoTile(
          icon: Icons.payments_outlined,
          label: "Koszt",
          value: LaundryFormat.money(machine.priceGrosze),
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context, Machine machine) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return [
      if (_error != null) ...[
        const SizedBox(height: 12),
        Text(
          _error!,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
        ),
      ],
      const SizedBox(height: 20),
      SheetButton(
        icon: Icons.check,
        label: "Zakończ pranie",
        loading: _saving,
        onPressed: () => _finish(machine),
      ),
      const SizedBox(height: 8),
      Text(
        "Naciśnij po wyjęciu prania – pralka stanie się wolna dla innych.",
        textAlign: TextAlign.center,
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    ];
  }
}
