import 'package:flutter/services.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';

class LanguageDetectionService {
  final LanguageIdentifier _identifier;

  LanguageDetectionService({double confidenceThreshold = 0.6})
      : _identifier =
            LanguageIdentifier(confidenceThreshold: confidenceThreshold);

  Future<String> detectLocale(
    String text, {
    String fallbackLocale = 'en-US',
  }) async {
    if (text.trim().isEmpty) return fallbackLocale;

    try {
      final language = await _identifier.identifyLanguage(text);
      if (language == 'und') return fallbackLocale;

      if (language.startsWith('vi')) return 'vi-VN';
      if (language.startsWith('en')) return 'en-US';
    } on MissingPluginException {
      return fallbackLocale;
    } on PlatformException {
      return fallbackLocale;
    } catch (_) {
      return fallbackLocale;
    }

    return fallbackLocale;
  }

  void dispose() => _identifier.close();
}
