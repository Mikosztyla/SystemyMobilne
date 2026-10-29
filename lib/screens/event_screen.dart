import 'package:material_ui/material_ui.dart';

class EventScreen extends StatelessWidget{
  const EventScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wydarzenia"),
      ),
      body: const Center(child: Text("wydarzenia"),),
    );
  }

}