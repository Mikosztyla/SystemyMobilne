import 'package:bursa_app/models/machine.dart';
import 'package:bursa_app/screens/laundry/sheets/busy_machine_sheet.dart';
import 'package:bursa_app/screens/laundry/sheets/my_wash_sheet.dart';
import 'package:bursa_app/screens/laundry/sheets/out_of_order_sheet.dart';
import 'package:bursa_app/screens/laundry/sheets/start_wash_sheet.dart';
import 'package:bursa_app/services/laundry_store.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key, required this.store});

  final LaundryStore store;

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  bool _handling = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final code = capture.barcodes
        .map((barcode) => barcode.rawValue)
        .whereType<String>()
        .firstOrNull;
    if (code != null) _handle(() => _resolve(code));
  }

  void _onManualEntry() {
    _handle(() async {
      final code = await _askForCode();
      return code == null ? null : _resolve(code);
    });
  }

  Future<void> _handle(Future<String?> Function() action) async {
    if (_handling) return;
    _handling = true;
    await _controller.stop();
    if (!mounted) return;

    final message = await action();
    if (!mounted) return;
    if (message != null) {
      Navigator.of(context).pop(message);
      return;
    }

    _handling = false;
    try {
      await _controller.start();
    } catch (e) {
      debugPrint('Nie udało się wznowić aparatu: $e');
    }
  }

  Future<String?> _resolve(String code) async {
    final store = widget.store;
    final machine = store.machineByQrCode(code);
    final now = DateTime.now();

    if (machine == null) {
      debugPrint('Nieznany kod QR: "$code"');
      final enterManually = await _showUnknownCode(code);
      if (enterManually != true || !mounted) return null;
      final manual = await _askForCode();
      return manual == null ? null : _resolve(manual);
    }

    switch (machine.statusAt(now)) {
      case MachineStatus.outOfOrder:
        await showOutOfOrderSheet(
          context,
          machine: machine,
          alternative: store.firstFreeMachine,
        );
        return null;
      case MachineStatus.busy:
        if (machine.isUsedBy(store.uid, now)) {
          return showMyWashSheet(context, store: store, machine: machine);
        }
        final proceed = await showBusyMachineSheet(context, machine: machine);
        if (proceed != true || !mounted) return null;
        return showStartWashSheet(
          context,
          store: store,
          machine: machine,
          replaceRunning: true,
        );
      case MachineStatus.free:
        return showStartWashSheet(context, store: store, machine: machine);
    }
  }

  Future<bool?> _showUnknownCode(String code) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.qr_code_2, color: Theme.of(context).colorScheme.error),
        title: const Text('Nie rozpoznano kodu'),
        content: Text(
          'Odczytano: „${code.trim()}”\n\n'
          'Ten kod QR nie należy do żadnej pralki w bursie. Zeskanuj naklejkę '
          'z przodu pralki albo wpisz kod ręcznie (np. PR-02).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Wpisz ręcznie'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Spróbuj ponownie'),
          ),
        ],
      ),
    );
  }

  Future<String?> _askForCode() async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const _ManualCodeDialog(),
    );
    final trimmed = code?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          const _ScanFrame(),
          SafeArea(
            child: Column(
              children: [
                _TopBar(
                  controller: _controller,
                  onClose: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Kod jest też wydrukowany pod naklejką, np. PR-02',
                                style: TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _onManualEntry,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: colorScheme.primary,
                            shape: const StadiumBorder(),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.keyboard),
                              SizedBox(width: 10),
                              Text('Wpisz kod ręcznie'),
                            ],
                          ),
                        ),
                      ),
                    ],
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller, required this.onClose});

  final MobileScannerController controller;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Skanuj pralkę',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: controller,
            builder: (context, state, _) {
              if (state.torchState == TorchState.unavailable) {
                return const SizedBox(width: 48);
              }
              final isOn = state.torchState == TorchState.on;
              return IconButton(
                onPressed: controller.toggleTorch,
                icon: Icon(
                  isOn ? Icons.flashlight_off : Icons.flashlight_on,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 4),
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 260,
              child: Text(
                'Nakieruj aparat na kod QR naklejony na pralce',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualCodeDialog extends StatefulWidget {
  const _ManualCodeDialog();

  @override
  State<_ManualCodeDialog> createState() => _ManualCodeDialogState();
}

class _ManualCodeDialogState extends State<_ManualCodeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Kod pralki'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(hintText: 'np. PR-02'),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Anuluj'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
