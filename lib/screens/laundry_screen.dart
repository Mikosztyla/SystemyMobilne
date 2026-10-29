import 'package:material_ui/material_ui.dart';

class LaundryScreen extends StatelessWidget{
  const LaundryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pralnia"),
      ),
      body: const Center(child: Text("pralnia"),),
    );
  }

}