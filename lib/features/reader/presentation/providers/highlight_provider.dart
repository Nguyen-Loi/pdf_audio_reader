import 'dart:async';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/features/audio_handler/audio_handler_provider.dart';
import 'package:pdf_audio_reader/features/reader/data/models/tts_progress_model.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/reader_content.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/highlight_state.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/tts_config.dart';

/// Listens to [TtsAudioHandler.customEvent] and publishes [HighlightState].
class HighlightNotifier extends StateNotifier<HighlightState> {
  HighlightNotifier(Ref ref) : super(HighlightState.empty) {
    final handler = ref.read(audioHandlerProvider);
    _sub = handler.customEvent.listen((event) {
      if (event is TtsProgressModel) {
        _updateHighlight(event);
      } else if (event is Map && event['type'] == 'stop') {
        state = HighlightState.empty.copyWith(
          pageIndex: _pageIndex,
          renderMode: state.renderMode,
        );
      }
    });
  }

  StreamSubscription<dynamic>? _sub;
  String _pageText = '';
  List<TextElement> _elements = const [];
  int _pageIndex = 0;

  void setPageData({
    required int pageIndex,
    required String pageText,
    required List<TextElement> elements,
    required ReaderMode renderMode,
  }) {
    _pageIndex = pageIndex;
    _pageText = pageText;
    _elements = elements;
    state = HighlightState.empty.copyWith(
      pageIndex: pageIndex,
      renderMode: renderMode,
    );
  }

  void _updateHighlight(TtsProgressModel progress) {
    if (_pageText.isEmpty) return;
    if (progress.pageIndex != _pageIndex) return;

    final sentenceBounds = _findSentenceBounds(progress.startOffset);

    // Calculate bounding box using a binary search or iteration
    Rect? currentBounds;
    if (progress.renderMode == ReaderMode.originalPdf && _elements.isNotEmpty) {
      for (final element in _elements) {
        if (progress.startOffset >= element.charStart &&
            progress.startOffset <= element.charEnd) {
          currentBounds = element.bounds;
          break;
        }
      }
    }

    state = HighlightState(
      pageIndex: progress.pageIndex,
      wordStart: progress.startOffset,
      wordEnd: progress.endOffset,
      currentWord: progress.word,
      renderMode: progress.renderMode,
      sentenceStart: sentenceBounds.$1,
      sentenceEnd: sentenceBounds.$2,
      currentBounds: currentBounds,
    );
  }

  /// Finds start/end of the sentence containing [wordStart] by scanning for
  /// sentence-terminating punctuation (. ! ?) in the current page text.
  (int, int) _findSentenceBounds(int wordStart) {
    if (_pageText.isEmpty) return (0, 0);
    final String pageText = _pageText;

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
