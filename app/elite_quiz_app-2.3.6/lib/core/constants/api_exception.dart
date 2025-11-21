final class ApiException implements Exception {
  const ApiException(this.error);

  final String error;

  @override
  String toString() => error;
}
