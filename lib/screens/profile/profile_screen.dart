import 'package:bursa_app/screens/login_screen.dart';
import 'package:bursa_app/screens/profile/admin_panel_button.dart';
import 'package:bursa_app/screens/profile/profile_header.dart';
import 'package:bursa_app/screens/profile/switch_tile.dart';
import 'package:bursa_app/widgets/settings_group.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  Map<String, bool> _notifications = Map();
  late final Future<AppUser> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: FutureBuilder(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text(
              "Loading",
            ); // TODO - co robimy w trakcie ładowania danych?
          }
          if (snapshot.hasError) {
            return Text(
              snapshot.error.toString(),
            ); // TODO - jakieś "nie udało się pobrać danych"
          }

          final user = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              ProfileHeader(user: user),
              SizedBox(height: 16),
              SettingsGroup(
                children: [
                  InfoTile(
                    icon: Icons.bed_rounded,
                    label: "Pokój",
                    value: "${user.roomNumber} · ${user.floor} piętro",
                  ),
                  InfoTile(
                    icon: Icons.mail_outline_rounded,
                    label: "E-mail",
                    value: user.email,
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
                    value: _notifications["notifyDuties"]!,
                    onChanged: (bool value) {
                      _onSwitchChanged(value, "notifyDuties");
                    },
                  ),
                  SwitchTile(
                    icon: Icons.local_laundry_service_outlined,
                    title: "Koniec prania",
                    subtitle: "Gdy minie czas programu",
                    value: _notifications["notifyLaundry"]!,
                    onChanged: (bool value) {
                      setState(() {
                        _onSwitchChanged(value, "notifyLaundry");
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
          );
        },
      ),
    );
  }

  Future<AppUser> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    AppUser user = AppUser.fromMap(
      doc.data()!,
      FirebaseAuth.instance.currentUser!.email!,
    );

    _notifications["notifyDuties"] = user.notifyDuties;
    _notifications["notifyLaundry"] = user.notifyLaundry;

    return user;
  }

  Future<void> _onSwitchChanged(bool value, String name) async {
    setState(() {
      _notifications[name] = value;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        name: value,
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _notifications[name] = !value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nie udało się zapisać ustawienia")),
      );
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }
}
