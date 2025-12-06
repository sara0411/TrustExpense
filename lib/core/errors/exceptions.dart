/// Base exception class for the application
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  AppException({
    required this.message,
    this.code,
    this.originalError,
  });
  
  @override
  String toString() => message;
}

/// Firebase-related exceptions
class FirebaseException extends AppException {
  FirebaseException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Authentication exceptions
class AppAuthException extends AppException {
  AppAuthException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Network-related exceptions
class NetworkException extends AppException {
  NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// OCR processing exceptions
class OCRException extends AppException {
  OCRException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Classification exceptions
class ClassificationException extends AppException {
  ClassificationException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Blockchain exceptions
class BlockchainException extends AppException {
  BlockchainException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Storage exceptions
class AppStorageException extends AppException {
  AppStorageException({
    required super.message,
    super.code,
    super.originalError,
  });
}
