import 'package:material_ui/material_ui.dart';

class ScanFrame extends StatelessWidget {
  const ScanFrame({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
            SizedBox(
              width: 260,
              child: Text(
                "Nakieruj aparat na kod QR naklejony na pralce",
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
