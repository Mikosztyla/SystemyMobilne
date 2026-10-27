import 'package:material_ui/material_ui.dart';
import 'package:bursa_app/screens/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _hidePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final keyboardOpen =
        MediaQuery.viewInsetsOf(context).bottom >
        0; //  TODO: jakoś ładniej by to zrobił

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 64),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.cottage_outlined,
                            size: 36,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "BursApp",
                          style: textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Napis pewnie jest jeszcze TODO. Zaloguj się kontem mieszkanki",
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 32),
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 20,
                                  color: colorScheme.onErrorContainer,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 32),
                        ],

                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          validator: validateEmail,
                          enabled: !_isLoading,
                          decoration: const InputDecoration(
                            labelText: "E-mail",
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          keyboardType: TextInputType.visiblePassword,
                          controller: _passwordController,
                          validator: validatePassword,
                          enabled: !_isLoading,
                          obscureText: _hidePassword,
                          decoration: InputDecoration(
                            labelText: "Hasło",
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _hidePassword = !_hidePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 32),
                        FilledButton(
                          onPressed: _isLoading ? null : _login,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: _isLoading
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text("Logowanie"),
                                  ],
                                )
                              : const Text("Zaloguj się"),
                        ),
                        // TODO: uncomment when we want to add 'forgot your password' logic
                        // SizedBox(height: 16),
                        // Center(
                        //   child: TextButton(
                        //     onPressed: () {},
                        //
                        //     child: Text(
                        //       "Nie pamiętasz hasła?",
                        //       style: TextStyle(
                        //         fontSize: 16,
                        //         fontWeight: FontWeight.w600,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!keyboardOpen) ...[
                Center(
                  child: Text(
                    "Nie masz konta? Konto zakłada siostra dyrektor - zgłoś się do biura (pok. 410)",
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (!keyboardOpen) SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _errorMessage = null;
    });
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // TODO: real logging logic
    await Future.delayed(const Duration(seconds: 2)); // mock logging

    // TODO: real logging status
    if (_passwordController.text != "admin") {
      // mock password check
      setState(() {
        _errorMessage = "Nieprawidłowy e-mail lub hasło";
      });
    }
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }
}
