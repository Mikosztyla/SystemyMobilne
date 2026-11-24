import 'package:material_ui/material_ui.dart';

class AdminResidentsScreen extends StatelessWidget {
  const AdminResidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Zarządzaj mieszkańcami")),
      body: const Center(child: Text("mieszkańcy")),
    );
  }
}