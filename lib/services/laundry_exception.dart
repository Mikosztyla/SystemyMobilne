class LaundryException implements Exception {
  final String message;

  const LaundryException(this.message);

  @override
  String toString() => message;
}
