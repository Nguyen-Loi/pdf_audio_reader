import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/features/audio_handler/tts_audio_handler.dart';

/// Holds the singleton [TtsAudioHandler] after [AudioService.init] completes.
final audioHandlerProvider = Provider<TtsAudioHandler>((ref) {
  throw UnimplementedError(
    'audioHandlerProvider must be overridden in ProviderScope '
    'after AudioService.init() completes.',
  );
});
