import 'dart:async';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/features/audio_handler/audio_handler_provider.dart';
import 'package:pdf_audio_reader/features/pdf_parser/domain/entities/parsed_page.dart';
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
  ParsedPage? _activePage;

  void setParsedPage(ParsedPage page) {
    _activePage = page;
    state = HighlightState.empty;
  }

  void _updateHighlight(TtsProgressModel progress) {
    if (_activePage == null) return;
    
    final sentenceBounds = _findSentenceBounds(progress.start);

    // Calculate bounding box using a binary search or iteration
    Rect? currentBounds;
    for (final coord in _activePage!.wordCoordinates) {
      if (progress.start >= coord.charStart && progress.start <= coord.charEnd) {
        currentBounds = coord.bounds;
        break;
      }
    }

    state = HighlightState(
      wordStart: progress.start,
      wordEnd: progress.end,
      currentWord: progress.word,
      sentenceStart: sentenceBounds.$1,
      sentenceEnd: sentenceBounds.$2,
      currentBounds: currentBounds,
    );
  }

  /// Finds start/end of the sentence containing [wordStart] by scanning for
  /// sentence-terminating punctuation (. ! ?) in the current page text.
  (int, int) _findSentenceBounds(int wordStart) {
    if (_activePage == null || _activePage!.text.isEmpty) return (0, 0);
    final String pageText = _activePage!.text;

    // Find sentence start — scan backwards for sentence-ending punctuation
    var sentStart = 0;
    for (var i = wordStart - 1; i >= 0; i--) {
      final ch = pageText[i];
      if (ch == '.' || ch == '!' || ch == '?') {
        sentStart = i + 1;
        break;
      }
    }
    // Skip leading whitespace
    while (sentStart < wordStart && pageText[sentStart] == ' ') {
      sentStart++;
    }

    // Find sentence end — scan forward
    var sentEnd = pageText.length;
    for (var i = wordStart; i < pageText.length; i++) {
      final ch = pageText[i];
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
