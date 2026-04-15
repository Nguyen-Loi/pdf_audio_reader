import 'package:fpdart/fpdart.dart';
import 'package:pdf_audio_reader/core/errors/failures.dart';
import 'package:pdf_audio_reader/features/auth/domain/entities/app_user.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;
  Future<Either<Failure, AppUser>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
}
