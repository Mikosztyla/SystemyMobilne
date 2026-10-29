String? validateEmail(String? value) {
  if (value == null || value.isEmpty) {
    return "Podaj adres e-mail";
  }
  if (!value.contains("@")) {
    return "Nieprawidłowy adres e-mail";
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return "Podaj hasło";
  }
  return null;
}
