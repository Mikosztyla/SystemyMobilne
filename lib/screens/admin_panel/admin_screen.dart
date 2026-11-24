import 'package:bursa_app/screens/admin_panel/admin_nav_card.dart';
import 'package:bursa_app/screens/admin_panel/duties/admin_duties_screen.dart';
import 'package:bursa_app/screens/admin_panel/events/admin_events_screen.dart';
import 'package:bursa_app/screens/admin_panel/laundry/admin_laundry_screen.dart';
import 'package:bursa_app/screens/admin_panel/residents/admin_residents_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/admin_colors.dart';

class AdminScreen extends StatelessWidget {

  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminColors = Theme.of(context).extension<AdminColors>()!;

    return Scaffold(
      appBar: AppBar(title: const Text("Panel administratora")),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          AdminNavCard(
            icon: Icons.group_outlined,
            title: "Mieszkańcy",
            subtitle: "Dodawaj i usuwaj osoby, przypisuj pokoje",
            action: () => _pushNewScreen(context, const AdminResidentsScreen()),
            backgroundColor: adminColors.residents.background,
            iconColor: adminColors.residents.foreground,
          ),
          SizedBox(height: 12),
          AdminNavCard(
            icon: Icons.edit_calendar_outlined,
            title: "Wydarzenia",
            subtitle: "Zaplanuj najważniejsze momenty w życiu bursy",
            action: () => _pushNewScreen(context, const AdminEventsScreen()),
            backgroundColor: adminColors.events.background,
            iconColor: adminColors.events.foreground,
          ),
          SizedBox(height: 12),
          AdminNavCard(
            icon: Icons.cleaning_services_outlined,
            title: "Dyżury",
            subtitle: "Przydzielaj dyżury na kolejne tygodnie",
            action: () => _pushNewScreen(context, const AdminDutiesScreen()),
            backgroundColor: adminColors.duties.background,
            iconColor: adminColors.duties.foreground,
          ),
          SizedBox(height: 12),
          AdminNavCard(
            icon: Icons.local_laundry_service_outlined,
            title: "Pralnia",
            subtitle: "Dodawaj i zgłaszaj awarie pralek",
            action: () => _pushNewScreen(context, const AdminLaundryScreen()),
            backgroundColor: adminColors.laundry.background,
            iconColor: adminColors.laundry.foreground,
          ),
        ],
      ),
    );
  }

  void _pushNewScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}
