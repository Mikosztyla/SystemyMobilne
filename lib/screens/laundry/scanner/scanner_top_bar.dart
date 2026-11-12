import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerTopBar extends StatelessWidget {
  final MobileScannerController controller;
  final VoidCallback onClose;

  const ScannerTopBar({
    super.key,
    required this.controller,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 56,
      child: Row(
        children: [
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          Expanded(
            child: Text(
              "Skanuj pralkę",
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
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
