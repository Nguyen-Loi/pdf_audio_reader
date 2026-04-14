import 'package:equatable/equatable.dart';

/// Sealed class hierarchy for domain-layer failures.
sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// Auth
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class SignInCancelledFailure extends Failure {
  const SignInCancelledFailure() : super('Sign-in was cancelled.');
}

// PDF
class PdfImportFailure extends Failure {
  const PdfImportFailure(super.message);
}

class PdfParseFailure extends Failure {
  const PdfParseFailure(super.message);
}

class PdfEmptyTextFailure extends Failure {
  const PdfEmptyTextFailure()
      : super(
          'No readable text found in this PDF. '
          'It may be a scanned image. Please import a text-based PDF.',
        );
}

// Storage / Firestore
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// TTS
class TtsFailure extends Failure {
  const TtsFailure(super.message);
}

// IAP
class IapFailure extends Failure {
  const IapFailure(super.message);
}

// Generic
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
