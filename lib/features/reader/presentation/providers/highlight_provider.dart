import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/features/audio_handler/audio_handler_provider.dart';
import 'package:pdf_audio_reader/features/reader/data/models/tts_progress_model.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/highlight_state.dart';

/// Listens to [TtsAudioHandler.customEvent] and publishes [HighlightState].
class HighlightNotifier extends StateNotifier<HighlightState> {
  HighlightNotifier(Ref ref) : super(HighlightState.empty) {
    final handler = ref.read(audioHandlerProvider);
    _sub = handler.customEvent.listen((event) {
      if (event is TtsProgressModel) {
        _updateHighlight(event);
      } else if (event is Map && event['type'] == 'stop') {
        state = HighlightState.empty;
      }
    });
  }

  StreamSubscription<dynamic>? _sub;
  String _pageText = '';

  void setPageText(String text) {
    _pageText = text;
    state = HighlightState.empty;
  }

  void _updateHighlight(TtsProgressModel progress) {
    final sentenceBounds = _findSentenceBounds(progress.start);
    state = HighlightState(
      wordStart: progress.start,
      wordEnd: progress.end,
      currentWord: progress.word,
      sentenceStart: sentenceBounds.$1,
      sentenceEnd: sentenceBounds.$2,
    );
  }

  /// Finds start/end of the sentence containing [wordStart] by scanning for
  /// sentence-terminating punctuation (. ! ?) in the current page text.
  (int, int) _findSentenceBounds(int wordStart) {
    if (_pageText.isEmpty) return (0, 0);

    // Find sentence start — scan backwards for sentence-ending punctuation
    var sentStart = 0;
    for (var i = wordStart - 1; i >= 0; i--) {
      final ch = _pageText[i];
      if (ch == '.' || ch == '!' || ch == '?') {
        sentStart = i + 1;
        break;
      }
    }
    // Skip leading whitespace
    while (sentStart < wordStart && _pageText[sentStart] == ' ') {
      sentStart++;
    }

    // Find sentence end — scan forward
    var sentEnd = _pageText.length;
    for (var i = wordStart; i < _pageText.length; i++) {
      final ch = _pageText[i];
      if (ch == '.' || ch == '!' || ch == '?') {
        sentEnd = i + 1;
        break;
      }
    }

    return (sentStart, sentEnd);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final highlightProvider =
    StateNotifierProvider<HighlightNotifier, HighlightState>(
  (ref) => HighlightNotifier(ref),
);
