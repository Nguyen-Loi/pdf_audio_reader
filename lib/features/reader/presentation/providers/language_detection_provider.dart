import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/features/reader/services/language_detection_service.dart';

final languageDetectionServiceProvider =
    Provider<LanguageDetectionService>((ref) {
  final service = LanguageDetectionService();
  ref.onDispose(service.dispose);
  return service;
});
