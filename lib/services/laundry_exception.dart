class LaundryException implements Exception {
  const LaundryException(this.message);

  final String message;

  @override
  String toString() => message;
}
