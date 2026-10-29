import 'package:bursa_app/screens/event_screen.dart';
import 'package:bursa_app/screens/home_shell.dart';
import 'package:bursa_app/screens/login_screen.dart';
import 'package:bursa_app/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BursaApp());
}

class BursaApp extends StatelessWidget {
  const BursaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bursa',
      theme: AppTheme.light(),
      home: const LoginScreen()
    );
  }
}
