import 'package:material_ui/material_ui.dart';

Future<bool?> showUnknownCodeDialog(BuildContext context, String code) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: Icon(Icons.qr_code_2, color: Theme.of(context).colorScheme.error),
      title: const Text("Nie rozpoznano kodu"),
      content: Text(
        "Odczytano: „${code.trim()}”\n\n"
        "Ten kod QR nie należy do żadnej pralki w bursie. Zeskanuj naklejkę "
        "z przodu pralki albo wpisz kod ręcznie (np. PR-02).",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("Wpisz ręcznie"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Spróbuj ponownie"),
        ),
      ],
    ),
  );
}
