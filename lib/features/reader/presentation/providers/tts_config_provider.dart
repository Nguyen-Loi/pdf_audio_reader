import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/tts_config.dart';

class TtsConfigNotifier extends StateNotifier<TtsConfig> {
  TtsConfigNotifier() : super(const TtsConfig());

  void setSpeed(double speed) => state = state.copyWith(speed: speed);
  void setPitch(double pitch) => state = state.copyWith(pitch: pitch);
  void setVolume(double volume) => state = state.copyWith(volume: volume);
  void setLanguage(String lang) => state = state.copyWith(language: lang);
  void setVoice(String? voice) => state = state.copyWith(voice: voice);
}

final ttsConfigProvider =
    StateNotifierProvider<TtsConfigNotifier, TtsConfig>(
  (_) => TtsConfigNotifier(),
);
