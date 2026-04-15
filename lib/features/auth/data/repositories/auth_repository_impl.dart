import 'package:fpdart/fpdart.dart';
import 'package:pdf_audio_reader/core/errors/exceptions.dart';
import 'package:pdf_audio_reader/core/errors/failures.dart';
import 'package:pdf_audio_reader/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:pdf_audio_reader/features/auth/domain/entities/app_user.dart';
import 'package:pdf_audio_reader/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource _datasource;

  const AuthRepositoryImpl(this._datasource);

  @override
  Stream<AppUser?> get authStateChanges => _datasource.authStateChanges;

  @override
  AppUser? get currentUser => _datasource.currentUser;

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      final user = await _datasource.signInWithGoogle();
      return Right(user);
    } on AuthException catch (e) {
      if (e.message.contains('cancelled')) {
        return const Left(SignInCancelledFailure());
      }
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _datasource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
