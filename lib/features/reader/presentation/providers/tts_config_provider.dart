import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/core/providers/shared_preferences_provider.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/tts_config.dart';

const _ttsConfigKey = 'tts_config';

class GlobalTtsConfigNotifier extends StateNotifier<TtsConfig> {
  final Ref ref;

  GlobalTtsConfigNotifier(this.ref) : super(const TtsConfig()) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final prefs = ref.read(sharedPreferencesProvider);
    final jsonStr = prefs.getString(_ttsConfigKey);
    if (jsonStr != null) {
      try {
        final json = jsonDecode(jsonStr);
        state = TtsConfig.fromJson(json);
      } catch (e) {
        // Fallback to default
      }
    }
  }

  void _saveToPrefs(TtsConfig ns) {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setString(_ttsConfigKey, jsonEncode(ns.toJson()));
  }

  void updateConfig(TtsConfig newConfig) {
    state = newConfig;
    _saveToPrefs(newConfig);
  }

  void setSpeed(double speed) => updateConfig(state.copyWith(speed: speed));
  void setPitch(double pitch) => updateConfig(state.copyWith(pitch: pitch));
  void setVolume(double volume) => updateConfig(state.copyWith(volume: volume));
  void setLanguage(String lang) => updateConfig(state.copyWith(language: lang));
  void setVoice(Map<String, dynamic>? voice) =>
      updateConfig(state.copyWith(voice: voice));
  void setReaderMode(ReaderMode mode) =>
      updateConfig(state.copyWith(readerMode: mode));
  void setScrollDirection(Axis direction) =>
      updateConfig(state.copyWith(scrollDirection: direction));
}

final globalTtsConfigProvider =
    StateNotifierProvider<GlobalTtsConfigNotifier, TtsConfig>((ref) {
  return GlobalTtsConfigNotifier(ref);
});

class SessionTtsConfigNotifier extends StateNotifier<TtsConfig> {
  SessionTtsConfigNotifier(super.initial);

  void setSpeed(double speed) => state = state.copyWith(speed: speed);
  void setPitch(double pitch) => state = state.copyWith(pitch: pitch);
  void setVolume(double volume) => state = state.copyWith(volume: volume);
  void setLanguage(String lang) => state = state.copyWith(language: lang);
  void setVoice(Map<String, dynamic>? voice) =>
      state = state.copyWith(voice: voice);
  void setReaderMode(ReaderMode mode) =>
      state = state.copyWith(readerMode: mode);
  void setScrollDirection(Axis direction) =>
      state = state.copyWith(scrollDirection: direction);
}

final ttsConfigProvider =
    StateNotifierProvider.autoDispose<SessionTtsConfigNotifier, TtsConfig>(
        (ref) {
  final global = ref.read(globalTtsConfigProvider);
  return SessionTtsConfigNotifier(global);
});
