import 'package:bursa_app/models/machine.dart';
import 'package:bursa_app/screens/laundry/scanner/manual_code_dialog.dart';
import 'package:bursa_app/screens/laundry/scanner/scan_frame.dart';
import 'package:bursa_app/screens/laundry/scanner/scanner_bottom_panel.dart';
import 'package:bursa_app/screens/laundry/scanner/scanner_top_bar.dart';
import 'package:bursa_app/screens/laundry/scanner/unknown_code_dialog.dart';
import 'package:bursa_app/screens/laundry/sheets/busy_machine_sheet.dart';
import 'package:bursa_app/screens/laundry/sheets/my_wash_sheet.dart';
import 'package:bursa_app/screens/laundry/sheets/out_of_order_sheet.dart';
import 'package:bursa_app/screens/laundry/sheets/start_wash_sheet.dart';
import 'package:bursa_app/services/laundry_store.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanScreen extends StatefulWidget {
  final LaundryStore store;

  const QrScanScreen({super.key, required this.store});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          const ScanFrame(),
          SafeArea(
            child: Column(
              children: [
                ScannerTopBar(
                  controller: _controller,
                  onClose: () => Navigator.of(context).pop(),
                ),
                const Spacer(),
                ScannerBottomPanel(onManualEntry: _onManualEntry),
              ],
            ),
          ),
        ],
      ),
    );
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
      final code = await showManualCodeDialog(context);
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
      debugPrint("Nie udało się wznowić aparatu: $e");
    }
  }

  Future<String?> _resolve(String code) async {
    final machine = widget.store.machineByQrCode(code);
    if (machine == null) return _onUnknownCode(code);

    final store = widget.store;
    final now = DateTime.now();
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
        return _onBusyMachine(machine);
      case MachineStatus.free:
        return showStartWashSheet(context, store: store, machine: machine);
    }
  }

  Future<String?> _onUnknownCode(String code) async {
    debugPrint("Nieznany kod QR: \"$code\"");
    final enterManually = await showUnknownCodeDialog(context, code);
    if (enterManually != true || !mounted) return null;
    final manual = await showManualCodeDialog(context);
    if (manual == null || !mounted) return null;
    return _resolve(manual);
  }

  Future<String?> _onBusyMachine(Machine machine) async {
    final proceed = await showBusyMachineSheet(context, machine: machine);
    if (proceed != true || !mounted) return null;
    return showStartWashSheet(
      context,
      store: widget.store,
      machine: machine,
      replaceRunning: true,
    );
  }
}
