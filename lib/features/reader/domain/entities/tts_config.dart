import 'package:equatable/equatable.dart';

enum ReaderMode { textOnly, originalPdf }

class TtsConfig extends Equatable {
  final double speed;   // 0.5 – 3.0
  final double pitch;   // 0.5 – 2.0
  final double volume;  // 0.0 – 1.0
  final String language;
  final Map<String, dynamic>? voice; // Store the complex map from flutterTts.getVoices
  final ReaderMode readerMode;

  const TtsConfig({
    this.speed = 1.0,
    this.pitch = 1.0,
    this.volume = 1.0,
    this.language = 'en-US',
    this.voice,
    this.readerMode = ReaderMode.textOnly,
  });

  TtsConfig copyWith({
    double? speed,
    double? pitch,
    double? volume,
    String? language,
    Map<String, dynamic>? voice,
    ReaderMode? readerMode,
  }) =>
      TtsConfig(
        speed: speed ?? this.speed,
        pitch: pitch ?? this.pitch,
        volume: volume ?? this.volume,
        language: language ?? this.language,
        voice: voice ?? this.voice,
        readerMode: readerMode ?? this.readerMode,
      );

  @override
  List<Object?> get props => [speed, pitch, volume, language, voice, readerMode];
}
