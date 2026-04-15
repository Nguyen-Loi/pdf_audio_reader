import 'package:equatable/equatable.dart';
import 'dart:ui'; // For Rect
import 'package:pdf_audio_reader/features/reader/domain/entities/tts_config.dart';

class HighlightState extends Equatable {
  final int pageIndex;
  final int wordStart;
  final int wordEnd;
  final String currentWord;
  final ReaderMode renderMode;

  /// Sentence boundaries (detected from punctuation)
  final int sentenceStart;
  final int sentenceEnd;

  final Rect? currentBounds;

  const HighlightState({
    required this.pageIndex,
    required this.wordStart,
    required this.wordEnd,
    required this.currentWord,
    required this.renderMode,
    required this.sentenceStart,
    required this.sentenceEnd,
    this.currentBounds,
  });

  static const empty = HighlightState(
    pageIndex: 0,
    wordStart: 0,
    wordEnd: 0,
    currentWord: '',
    renderMode: ReaderMode.textOnly,
    sentenceStart: 0,
    sentenceEnd: 0,
    currentBounds: null,
  );

  HighlightState copyWith({
    int? pageIndex,
    int? wordStart,
    int? wordEnd,
    String? currentWord,
    ReaderMode? renderMode,
    int? sentenceStart,
    int? sentenceEnd,
    Rect? currentBounds,
  }) {
    return HighlightState(
      pageIndex: pageIndex ?? this.pageIndex,
      wordStart: wordStart ?? this.wordStart,
      wordEnd: wordEnd ?? this.wordEnd,
      currentWord: currentWord ?? this.currentWord,
      renderMode: renderMode ?? this.renderMode,
      sentenceStart: sentenceStart ?? this.sentenceStart,
      sentenceEnd: sentenceEnd ?? this.sentenceEnd,
      currentBounds: currentBounds ?? this.currentBounds,
    );
  }

  @override
  List<Object?> get props => [
        pageIndex,
        wordStart,
        wordEnd,
        currentWord,
        renderMode,
        sentenceStart,
        sentenceEnd,
        currentBounds,
      ];
}
