import 'package:bursa_app/screens/login_screen.dart';
import 'package:bursa_app/theme/app_theme.dart';
import 'package:material_ui/material_ui.dart';

void main() {
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
