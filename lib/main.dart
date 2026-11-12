import 'package:bursa_app/screens/home_shell.dart';
import 'package:bursa_app/screens/login_screen.dart';
import 'package:bursa_app/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final user = await FirebaseAuth.instance.authStateChanges().first;
  runApp(BursaApp(isLoggedIn: user != null));
}

class BursaApp extends StatelessWidget {
  const BursaApp({super.key, this.isLoggedIn = false});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Bursa",
      theme: AppTheme.light(),
      home: isLoggedIn ? const HomeShell() : const LoginScreen(),
    );
  }
}
