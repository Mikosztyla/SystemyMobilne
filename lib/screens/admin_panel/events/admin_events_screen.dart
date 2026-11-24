import 'package:material_ui/material_ui.dart';

class AdminEventsScreen extends StatelessWidget {
  const AdminEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Zarządzaj wydarzeniami")),
      body: const Center(child: Text("wydarzenia")),
    );
  }
}