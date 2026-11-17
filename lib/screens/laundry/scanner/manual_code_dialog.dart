import 'package:material_ui/material_ui.dart';

Future<String?> showManualCodeDialog(BuildContext context) async {
  final code = await showDialog<String>(
    context: context,
    builder: (_) => const ManualCodeDialog(),
  );
  final trimmed = code?.trim();
  return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
}

class ManualCodeDialog extends StatefulWidget {
  const ManualCodeDialog({super.key});

  @override
  State<ManualCodeDialog> createState() => _ManualCodeDialogState();
}

class _ManualCodeDialogState extends State<ManualCodeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Kod pralki"),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(hintText: "np. PR-02"),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Anuluj"),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text("OK"),
        ),
      ],
    );
  }
}
