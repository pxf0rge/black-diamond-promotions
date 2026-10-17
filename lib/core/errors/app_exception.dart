class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

class StorageException extends AppException {
  const StorageException(super.message, {super.code});
}
