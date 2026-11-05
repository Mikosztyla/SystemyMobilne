import 'package:bursa_app/screens/login_screen.dart';
import 'package:bursa_app/screens/profile/admin_panel_button.dart';
import 'package:bursa_app/screens/profile/profile_header.dart';
import 'package:bursa_app/screens/profile/switch_tile.dart';
import 'package:bursa_app/widgets/settings_group.dart';
import 'package:material_ui/material_ui.dart';
import 'package:bursa_app/models/app_user.dart';

import 'constants.dart';
import 'info_tile.dart';



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _dutiesNotification = true;
  bool _laundryNotification = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          ProfileHeader(user: mockUser),
          SizedBox(height: 16),
          SettingsGroup(
            children: [
              InfoTile(
                icon: Icons.bed_rounded,
                label: "Pokój",
                value: "${mockUser.roomNumber} · ${mockUser.floor} piętro",
              ),
              InfoTile(
                icon: Icons.mail_outline_rounded,
                label: "E-mail",
                value: mockUser.email,
              ),
            ],
          ),
          SizedBox(height: 16),
          AdminPanelButton(), //TODO on click
          SizedBox(height: 16),
          Text(
            "POWIADOMIENIA I WYGLĄD",
            style: textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8),
          SettingsGroup(
            children: [
              SwitchTile(
                icon: Icons.cleaning_services_outlined,
                title: "Przypomnienia o dyżurach",
                subtitle: "Twój dyżur na ten tydzień",
                value: _dutiesNotification,
                onChanged: (bool value) {
                  setState(() {
                    _dutiesNotification = value;
                  });
                },
              ),
              SwitchTile(
                icon: Icons.local_laundry_service_outlined,
                title: "Koniec prania",
                subtitle: "Gdy minie czas programu",
                value: _laundryNotification,
                onChanged: (bool value) {
                  setState(() {
                    _laundryNotification = value;
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.dark_mode_outlined, size: iconSize),
                subtitle: Text(
                  "Zgodny z systemem",
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                title: Text(
                  "Motyw",
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: Icon(Icons.chevron_right_rounded, size: iconSize),
                onTap: () {}, //TODO
              ),
            ],
          ),
          SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _logout,
            icon: Icon(Icons.logout_outlined, size: iconSize),
            label: Text(
              "Wyloguj się",
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.error,
                fontSize: 16,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.outlineVariant),
              minimumSize: Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }

  void _logout() {
    // TODO - logout Firebase (async, mounted i wgl pewnie kręcące się kółko)

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }
}
