import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

enum ReaderMode { textOnly, originalPdf }

class TtsConfig extends Equatable {
  final double speed;   // 0.5 – 3.0
  final double pitch;   // 0.5 – 2.0
  final double volume;  // 0.0 – 1.0
  final String language;
  final Map<String, dynamic>? voice; // Store the complex map from flutterTts.getVoices
  final ReaderMode readerMode;
  final Axis scrollDirection; // Horizontal or Vertical scrolling

  const TtsConfig({
    this.speed = 1.0,
    this.pitch = 1.0,
    this.volume = 1.0,
    this.language = 'en-US',
    this.voice,
    this.readerMode = ReaderMode.textOnly,
    this.scrollDirection = Axis.vertical,
  });

  TtsConfig copyWith({
    double? speed,
    double? pitch,
    double? volume,
    String? language,
    Map<String, dynamic>? voice,
    ReaderMode? readerMode,
    Axis? scrollDirection,
  }) =>
      TtsConfig(
        speed: speed ?? this.speed,
        pitch: pitch ?? this.pitch,
        volume: volume ?? this.volume,
        language: language ?? this.language,
        voice: voice ?? this.voice,
        readerMode: readerMode ?? this.readerMode,
        scrollDirection: scrollDirection ?? this.scrollDirection,
      );

  factory TtsConfig.fromJson(Map<String, dynamic> json) {
    return TtsConfig(
      speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
      pitch: (json['pitch'] as num?)?.toDouble() ?? 1.0,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      language: json['language'] as String? ?? 'en-US',
      voice: json['voice'] as Map<String, dynamic>?,
      readerMode: ReaderMode.values.firstWhere(
        (e) => e.name == json['readerMode'],
        orElse: () => ReaderMode.textOnly,
      ),
      scrollDirection: Axis.values.firstWhere(
        (e) => e.name == json['scrollDirection'],
        orElse: () => Axis.vertical,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'speed': speed,
      'pitch': pitch,
      'volume': volume,
      'language': language,
      'voice': voice,
      'readerMode': readerMode.name,
      'scrollDirection': scrollDirection.name,
    };
  }

  @override
  List<Object?> get props => [speed, pitch, volume, language, voice, readerMode, scrollDirection];
}
