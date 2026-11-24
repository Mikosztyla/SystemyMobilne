import 'package:material_ui/material_ui.dart';

class AdminDutiesScreen extends StatelessWidget {
  const AdminDutiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Zarządzaj dyżurami")),
      body: const Center(child: Text("dyżury")),
    );
  }
}
