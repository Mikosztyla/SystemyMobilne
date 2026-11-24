import 'package:material_ui/material_ui.dart';

class AdminLaundryScreen extends StatelessWidget {
  const AdminLaundryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Zarządzaj pralkami")),
      body: const Center(child: Text("pralki")),
    );
  }
}