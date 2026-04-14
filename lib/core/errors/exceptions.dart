/// Custom exception types thrown by data-layer datasources.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => 'AuthException: $message';
}

class PdfImportException implements Exception {
  final String message;
  const PdfImportException(this.message);
  @override
  String toString() => 'PdfImportException: $message';
}

class PdfParseException implements Exception {
  final String message;
  const PdfParseException(this.message);
  @override
  String toString() => 'PdfParseException: $message';
}

class StorageException implements Exception {
  final String message;
  const StorageException(this.message);
  @override
  String toString() => 'StorageException: $message';
}

class TtsException implements Exception {
  final String message;
  const TtsException(this.message);
  @override
  String toString() => 'TtsException: $message';
}

class IapException implements Exception {
  final String message;
  const IapException(this.message);
  @override
  String toString() => 'IapException: $message';
}
