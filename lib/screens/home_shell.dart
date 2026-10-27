import 'package:bursa_app/screens/duties_screen.dart';
import 'package:bursa_app/screens/event_screen.dart';
import 'package:bursa_app/screens/laundry_screen.dart';
import 'package:bursa_app/screens/profile_screen.dart';
import 'package:material_ui/material_ui.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentPageIdx = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int idx) {
          setState(() {
            _currentPageIdx = idx;
          });
        },
        backgroundColor: colorScheme.surfaceContainer,
        selectedIndex: _currentPageIdx,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            label: "Wydarzenia",
          ),
          NavigationDestination(
            icon: Icon(Icons.cleaning_services_outlined),
            label: "Dyżury",
          ),
          NavigationDestination(
            icon: Icon(Icons.local_laundry_service_outlined),
            label: "Pralnia",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            label: "Profil",
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentPageIdx,
        children: [
          EventScreen(),
          DutiesScreen(),
          LaundryScreen(),
          ProfileScreen(),
        ],
      ),
    );
  }
}
