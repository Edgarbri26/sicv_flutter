// lib/core/exceptions/backend_exception.dart

class BackendException implements Exception {
  final String message;
  BackendException(this.message);

  @override
  String toString() => message;
}