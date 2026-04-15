import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf_audio_reader/core/localization/app_localizations.dart';
import 'package:pdf_audio_reader/core/router/route_names.dart';
import 'package:pdf_audio_reader/features/auth/presentation/pages/login_page.dart';
import 'package:pdf_audio_reader/features/auth/presentation/pages/splash_page.dart';
import 'package:pdf_audio_reader/features/auth/presentation/providers/auth_provider.dart';
import 'package:pdf_audio_reader/features/pdf_library/presentation/pages/library_page.dart';
import 'package:pdf_audio_reader/features/reader/presentation/pages/reader_page.dart';
import 'package:pdf_audio_reader/features/settings/presentation/pages/settings_page.dart';
import 'package:pdf_audio_reader/features/subscription/presentation/pages/paywall_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = _AuthListenable(ref);

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoggedIn = authState.valueOrNull != null;
      final isSplash = state.matchedLocation == RouteNames.splash;
      final isLogin = state.matchedLocation == RouteNames.login;

      if (isSplash) return null; // Splash handles its own redirect

      if (!isLoggedIn && !isLogin) return RouteNames.login;
      if (isLoggedIn && isLogin) return RouteNames.library;
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashPage(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: RouteNames.library,
        builder: (_, __) => const LibraryPage(),
      ),
      GoRoute(
        path: RouteNames.reader,
        builder: (context, state) {
          final extra = state.extra as ReaderPageParams;

          return ReaderPage(params: extra);
        },
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (_, __) => const SettingsPage(),
      ),
      GoRoute(
        path: RouteNames.paywall,
        builder: (_, __) => const PaywallPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text(context.l10n.pageNotFoundMessage(state.error.toString())),
      ),
    ),
  );
});

/// Bridges Riverpod auth state to GoRouter's [Listenable] refresh.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}
