import 'package:material_ui/material_ui.dart';

class DutiesScreen extends StatelessWidget {
  const DutiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dyżury")),
      body: const Center(child: Text("dyżury")),
    );
  }
}
