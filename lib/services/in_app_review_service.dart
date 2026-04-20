import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';

import 'package:pdf_audio_reader/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:pdf_audio_reader/features/settings/domain/repositories/settings_repository.dart';

final inAppReviewServiceProvider = Provider<InAppReviewService>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  return InAppReviewService(settings);
});

class InAppReviewService {
  final InAppReview _review = InAppReview.instance;
  final SettingsRepository _settings;
  final int _threshold;

  InAppReviewService(this._settings, {int threshold = 4})
      : _threshold = threshold;

  Future<bool> maybeShowReview() async {
    final hasShown = await _settings.getHasShownReview();
    if (hasShown) return false;

    final count = await _settings.getImportCount();
    if (count < _threshold) return false;

    if (await _review.isAvailable()) {
      await _review.requestReview();
      await _settings.setHasShownReview(true);
      return true;
    }
    return false;
  }

  // Debug helper – not exposed in production builds
  @visibleForTesting
  Future<void> reset() async {
    await _settings.setHasShownReview(false);
    await _settings.setImportCount(0);
  }
}
