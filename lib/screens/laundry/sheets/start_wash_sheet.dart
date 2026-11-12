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
  const StartWashSheet({
    super.key,
    required this.store,
    required this.machine,
    this.replaceRunning = false,
  });

  final LaundryStore store;
  final Machine machine;
  final bool replaceRunning;

  @override
  State<StartWashSheet> createState() => _StartWashSheetState();
}

class _StartWashSheetState extends State<StartWashSheet> {
  static const _presets = [30, 45, 60, 90, 120];
  static const _minMinutes = 5;
  static const _maxMinutes = 300;

  int _minutes = 60;
  bool _confirming = false;
  bool _saving = false;
  String? _error;

  void _change(int delta) {
    setState(() {
      _minutes = (_minutes + delta).clamp(_minMinutes, _maxMinutes).toInt();
    });
  }

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
        '${widget.machine.name}: pranie potrwa do ${LaundryFormat.time(end)}.',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SheetHeader(
          overline: 'Kod ${widget.machine.qrCode} rozpoznany',
          title: widget.machine.name,
          background: LaundryColors.freeBg,
          foreground: LaundryColors.freeFg,
          trailing: _confirming
              ? const StatusChip(status: MachineStatus.free)
              : null,
        ),
        const SizedBox(height: 20),
        ...(_confirming ? _confirmStep(context) : _durationStep(context)),
      ],
    );
  }

  List<Widget> _durationStep(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final end = DateTime.now().add(Duration(minutes: _minutes));
    return [
      const Text(
        'Ile trwa Twój program?',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 4),
      const Text(
        'Sprawdź czas na wyświetlaczu pralki po wybraniu programu.',
        style: TextStyle(color: LaundryColors.muted),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: LaundryColors.fees,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _TimeStepper(
                  value: '${_minutes ~/ 60}',
                  label: 'godz.',
                  onUp: () => _change(60),
                  onDown: () => _change(-60),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    ':',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
                  ),
                ),
                _TimeStepper(
                  value: (_minutes % 60).toString().padLeft(2, '0'),
                  label: 'min',
                  onUp: () => _change(5),
                  onDown: () => _change(-5),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'koniec ok. ${LaundryFormat.time(end)}',
              style: const TextStyle(color: LaundryColors.muted),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          for (final preset in _presets)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: OutlinedButton(
                  onPressed: () => setState(() => _minutes = preset),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: preset == _minutes
                        ? colorScheme.primaryContainer
                        : null,
                  ),
                  child: Text(LaundryFormat.duration(preset).replaceAll(' h', '')),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 24),
      SheetButton(
        icon: Icons.arrow_forward,
        label: 'Dalej',
        onPressed: () => setState(() => _confirming = true),
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Anuluj'),
      ),
    ];
  }

  List<Widget> _confirmStep(BuildContext context) {
    final end = DateTime.now().add(Duration(minutes: _minutes));
    return [
      Row(
        children: [
          SheetInfoTile(
            icon: Icons.timer_outlined,
            label: 'Czas programu',
            value: LaundryFormat.duration(_minutes),
          ),
          const SizedBox(width: 8),
          SheetInfoTile(
            icon: Icons.schedule,
            label: 'Koniec ok.',
            value: LaundryFormat.time(end),
          ),
          const SizedBox(width: 8),
          SheetInfoTile(
            icon: Icons.payments_outlined,
            label: 'Koszt',
            value: LaundryFormat.money(widget.machine.priceGrosze),
          ),
        ],
      ),
      const SizedBox(height: 16),
      const Text(
        'Kwota zostanie doliczona do Twoich opłat. Powiadomimy Cię '
        '5 minut przed końcem prania i w chwili, gdy się skończy.',
        style: TextStyle(fontSize: 14),
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
        icon: Icons.play_arrow_rounded,
        label: 'Rozpocznij pranie',
        loading: _saving,
        onPressed: _start,
      ),
      const SizedBox(height: 8),
      TextButton(
        onPressed: _saving ? null : () => setState(() => _confirming = false),
        child: const Text('Zmień czas programu'),
      ),
    ];
  }
}

class _TimeStepper extends StatelessWidget {
  const _TimeStepper({
    required this.value,
    required this.label,
    required this.onUp,
    required this.onDown,
  });

  final String value;
  final String label;
  final VoidCallback onUp;
  final VoidCallback onDown;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      child: Column(
        children: [
          IconButton.filledTonal(
            onPressed: onUp,
            icon: const Icon(Icons.keyboard_arrow_up),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w700),
          ),
          IconButton.filledTonal(
            onPressed: onDown,
            icon: const Icon(Icons.keyboard_arrow_down),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: LaundryColors.muted),
          ),
        ],
      ),
    );
  }
}
