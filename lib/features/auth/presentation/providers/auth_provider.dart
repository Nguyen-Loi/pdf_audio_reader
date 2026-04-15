import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:pdf_audio_reader/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pdf_audio_reader/features/auth/domain/entities/app_user.dart';
import 'package:pdf_audio_reader/features/auth/domain/repositories/auth_repository.dart';

// ── Dependency providers ───────────────────────────────────────────────────

final authDatasourceProvider = Provider<FirebaseAuthDatasource>(
  (ref) => FirebaseAuthDatasource(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.read(authDatasourceProvider)),
);

// ── Auth state stream ──────────────────────────────────────────────────────

/// Streams the current authenticated user (null = logged out).
final authStateProvider = StreamProvider<AppUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges,
);

/// Convenience: the currently signed-in user or null.
final currentUserProvider = Provider<AppUser?>(
  (ref) => ref.watch(authStateProvider).valueOrNull,
);

final isLoggedInProvider = Provider<bool>(
  (ref) => ref.watch(currentUserProvider) != null,
);

// ── Auth actions notifier ──────────────────────────────────────────────────

class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String?> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).signInWithGoogle();
    return result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
        return failure.message;
      },
      (_) {
        state = const AsyncData(null);
        return null;
      },
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, void>(AuthNotifier.new);

class AuthService {
  const AuthService(this.ref);

  final Ref ref;

  bool get isLoggedIn => ref.read(isLoggedInProvider);

  Future<String?> signInWithGoogle() {
    return ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  Future<void> signOut() {
    return ref.read(authNotifierProvider.notifier).signOut();
  }
}

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref),
);
