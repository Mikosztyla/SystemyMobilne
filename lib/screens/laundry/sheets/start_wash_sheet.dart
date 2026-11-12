import 'package:bursa_app/models/machine.dart';
import 'package:bursa_app/screens/laundry/laundry_format.dart';
import 'package:bursa_app/screens/laundry/sheets/duration_picker.dart';
import 'package:bursa_app/screens/laundry/sheets/laundry_sheet.dart';
import 'package:bursa_app/screens/laundry/sheets/sheet_button.dart';
import 'package:bursa_app/screens/laundry/sheets/sheet_header.dart';
import 'package:bursa_app/screens/laundry/sheets/sheet_info_tile.dart';
import 'package:bursa_app/screens/laundry/status_chip.dart';
import 'package:bursa_app/services/laundry_exception.dart';
import 'package:bursa_app/services/laundry_store.dart';
import 'package:bursa_app/theme/status_colors.dart';
import 'package:material_ui/material_ui.dart';

Future<String?> showStartWashSheet(
  BuildContext context, {
  required LaundryStore store,
  required Machine machine,
  bool replaceRunning = false,
}) {
  return showLaundrySheet<String>(
    context,
    StartWashSheet(
      store: store,
      machine: machine,
      replaceRunning: replaceRunning,
    ),
  );
}

class StartWashSheet extends StatefulWidget {
  final LaundryStore store;
  final Machine machine;
  final bool replaceRunning;

  const StartWashSheet({
    super.key,
    required this.store,
    required this.machine,
    this.replaceRunning = false,
  });

  @override
  State<StartWashSheet> createState() => _StartWashSheetState();
}

class _StartWashSheetState extends State<StartWashSheet> {
  int _minutes = 60;
  bool _confirming = false;
  bool _saving = false;
  String? _error;

  Future<void> _start() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.store.startWash(
        widget.machine,
        _minutes,
        replaceRunning: widget.replaceRunning,
      );
      if (!mounted) return;
      final end = DateTime.now().add(Duration(minutes: _minutes));
      Navigator.of(context).pop(
        "${widget.machine.name}: pranie potrwa do ${LaundryFormat.time(end)}.",
      );
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
    final statusColors = StatusColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetHeader(
          overline: "Kod ${widget.machine.qrCode} rozpoznany",
          title: widget.machine.name,
          background: statusColors.free,
          foreground: statusColors.onFree,
          trailing: _confirming
              ? const StatusChip(status: MachineStatus.free)
              : null,
        ),
        const SizedBox(height: 20),
        ...(_confirming ? _buildConfirmStep(context) : _buildDurationStep(context)),
      ],
    );
  }

  List<Widget> _buildDurationStep(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return [
      Text(
        "Ile trwa Twój program?",
        style: textTheme.titleMedium?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        "Sprawdź czas na wyświetlaczu pralki po wybraniu programu.",
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 16),
      DurationPicker(
        minutes: _minutes,
        onChanged: (minutes) => setState(() => _minutes = minutes),
      ),
      const SizedBox(height: 24),
      SheetButton(
        icon: Icons.arrow_forward,
        label: "Dalej",
        onPressed: () => setState(() => _confirming = true),
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text("Anuluj"),
      ),
    ];
  }

  List<Widget> _buildConfirmStep(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final end = DateTime.now().add(Duration(minutes: _minutes));

    return [
      Row(
        children: [
          SheetInfoTile(
            icon: Icons.timer_outlined,
            label: "Czas programu",
            value: LaundryFormat.duration(_minutes),
          ),
          const SizedBox(width: 8),
          SheetInfoTile(
            icon: Icons.schedule,
            label: "Koniec ok.",
            value: LaundryFormat.time(end),
          ),
          const SizedBox(width: 8),
          SheetInfoTile(
            icon: Icons.payments_outlined,
            label: "Koszt",
            value: LaundryFormat.money(widget.machine.priceGrosze),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Text(
        "Kwota zostanie doliczona do Twoich opłat. Powiadomimy Cię "
        "5 minut przed końcem prania i w chwili, gdy się skończy.",
        style: textTheme.bodyMedium,
      ),
      if (_error != null) ...[
        const SizedBox(height: 12),
        Text(
          _error!,
          style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
        ),
      ],
      const SizedBox(height: 20),
      SheetButton(
        icon: Icons.play_arrow_rounded,
        label: "Rozpocznij pranie",
        loading: _saving,
        onPressed: _start,
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: _saving ? null : () => setState(() => _confirming = false),
        child: const Text("Zmień czas programu"),
      ),
    ];
  }
}
