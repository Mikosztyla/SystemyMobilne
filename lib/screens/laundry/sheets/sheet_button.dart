import 'package:material_ui/material_ui.dart';

class SheetButton extends StatelessWidget {
  const SheetButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(shape: const StadiumBorder()),
        child: loading
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon),
                  const SizedBox(width: 10),
                  Text(label),
                ],
              ),
      ),
    );
  }
}
