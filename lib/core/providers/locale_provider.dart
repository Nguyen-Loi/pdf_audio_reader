import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/core/localization/app_localizations.dart';
import 'package:pdf_audio_reader/core/providers/shared_preferences_provider.dart';

const _appLocaleKey = 'app_locale';

class AppLocaleNotifier extends StateNotifier<Locale> {
  final Ref ref;

  AppLocaleNotifier(this.ref) : super(_initialLocale()) {
    _loadFromPrefs();
  }

  static Locale _initialLocale() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return _isSupported(systemLocale)
        ? Locale(systemLocale.languageCode)
        : const Locale('en');
  }

  static bool _isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supported) => supported.languageCode == locale.languageCode);
  }

  void _loadFromPrefs() {
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getString(_appLocaleKey);
    if (saved != null && _isSupported(Locale(saved))) {
      state = Locale(saved);
    }
  }

  void setLocale(Locale locale) {
    final normalized = Locale(locale.languageCode);
    if (!_isSupported(normalized)) return;
    state = normalized;
    ref
        .read(sharedPreferencesProvider)
        .setString(_appLocaleKey, normalized.languageCode);
  }
}

final appLocaleProvider =
    StateNotifierProvider<AppLocaleNotifier, Locale>((ref) {
  return AppLocaleNotifier(ref);
});
