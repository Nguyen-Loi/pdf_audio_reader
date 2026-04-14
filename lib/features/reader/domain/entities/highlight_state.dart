import 'package:equatable/equatable.dart';
import 'dart:ui'; // For Rect

class HighlightState extends Equatable {
  final int wordStart;
  final int wordEnd;
  final String currentWord;

  /// Sentence boundaries (detected from punctuation)
  final int sentenceStart;
  final int sentenceEnd;

  final Rect? currentBounds;

  const HighlightState({
    required this.wordStart,
    required this.wordEnd,
    required this.currentWord,
    required this.sentenceStart,
    required this.sentenceEnd,
    this.currentBounds,
  });

  static const empty = HighlightState(
    wordStart: 0,
    wordEnd: 0,
    currentWord: '',
    sentenceStart: 0,
    sentenceEnd: 0,
    currentBounds: null,
  );

  @override
  List<Object?> get props => [
        wordStart,
        wordEnd,
        currentWord,
        sentenceStart,
        sentenceEnd,
        currentBounds,
      ];
}
