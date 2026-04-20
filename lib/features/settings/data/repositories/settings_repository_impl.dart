import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdf_audio_reader/core/providers/shared_preferences_provider.dart';
import 'package:pdf_audio_reader/features/settings/domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsRepositoryImpl(prefs);
});

class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences _prefs;

  SettingsRepositoryImpl(this._prefs);

  static const _importCountKey = 'importCount';
  static const _hasShownReviewKey = 'hasShownReview';

  @override
  Future<int> getImportCount() async {
    return _prefs.getInt(_importCountKey) ?? 0;
  }

  @override
  Future<void> setImportCount(int count) async {
    await _prefs.setInt(_importCountKey, count);
  }

  @override
  Future<int> incrementImportCount() async {
    final count = await getImportCount();
    final newCount = count + 1;
    await setImportCount(newCount);
    return newCount;
  }

  @override
  Future<bool> getHasShownReview() async {
    return _prefs.getBool(_hasShownReviewKey) ?? false;
  }

  @override
  Future<void> setHasShownReview(bool shown) async {
    await _prefs.setBool(_hasShownReviewKey, shown);
  }
}
