import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/features/audio_handler/audio_handler_provider.dart';
import 'package:pdf_audio_reader/features/audio_handler/tts_audio_handler.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/tts_config.dart';

final ttsControllerProvider = Provider<TtsController>((ref) {
  final handler = ref.read(audioHandlerProvider);
  return TtsController(handler: handler);
});

class TtsController {
  final TtsAudioHandler handler;

  const TtsController({
    required this.handler,
  });

  Future<TtsConfig> applyForLocale({
    required String detectedLocale,
    required TtsConfig baseConfig,
  }) async {
    final resolvedLocale =
        detectedLocale.isNotEmpty ? detectedLocale : baseConfig.language;

    final resolvedVoice = _resolveVoiceForLocale(
      resolvedLocale,
      baseConfig.voice,
    );

    final updated = baseConfig.copyWith(
      voice: resolvedVoice,
    );

    await handler.applyConfig(updated);
    return updated;
  }

  Map<String, dynamic>? _resolveVoiceForLocale(
    String locale,
    Map<String, dynamic>? preferredVoice,
  ) {
    if (preferredVoice == null) return null;

    final voiceLocaleRaw = preferredVoice['locale']?.toString();
    if (voiceLocaleRaw == null || voiceLocaleRaw.isEmpty) {
      return preferredVoice;
    }

    final voiceLocale = voiceLocaleRaw.toLowerCase();
    final target = locale.toLowerCase();

    if (voiceLocale == target ||
        voiceLocale.startsWith(target.split('-').first)) {
      return preferredVoice;
    }

    return null;
  }
}
