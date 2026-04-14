import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pdf_audio_reader/core/utils/logger.dart';
import 'package:pdf_audio_reader/features/reader/data/models/tts_progress_model.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/tts_config.dart';

/// Adapts [FlutterTts] into an [audio_service] [BaseAudioHandler].
///
/// Key responsibilities:
/// - Owns the [FlutterTts] instance
/// - Bridges word-boundary events → `customEvent` stream (consumed by UI)
/// - Handles Android pause/resume offset workaround via `_globalOffset`
/// - Responds to OS media-button events (lock screen, notification)
class TtsAudioHandler extends BaseAudioHandler {
  final FlutterTts _tts = FlutterTts();

  // ── State ──────────────────────────────────────────────────────────────
  List<String> _pages = [];
  int _currentPageIndex = 0;
  bool _isPaused = false;
  bool _isPlaying = false;

  /// Cumulative offset from original page text start (Android resume fix).
  int _globalOffset = 0;

  /// Last known word start offset — used to rewind on Android resume.
  int _pauseCharOffset = 0;

  TtsConfig _config = const TtsConfig();

  // ── Constructor ────────────────────────────────────────────────────────

  TtsAudioHandler() {
    _initTts();
  }

  Future<void> _initTts() async {
    // iOS: share audio session, use playback category
    if (Platform.isIOS) {
      await _tts.setSharedInstance(true);
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
      );
    }

    await _applyConfig(_config);

    // ① Word-boundary → customEvent (with Android offset adjustment)
    _tts.setProgressHandler((String text, int start, int end, String word) {
      final adjustedStart = start + _globalOffset;
      final adjustedEnd = end + _globalOffset;
      _pauseCharOffset = adjustedStart;

      customEvent.add(TtsProgressModel(
        start: adjustedStart,
        end: adjustedEnd,
        word: word,
      ));
    });

    // ② Completion → notify reader to advance page
    _tts.setCompletionHandler(() {
      _isPlaying = false;
      _isPaused = false;
      customEvent.add({'type': 'pageComplete', 'pageIndex': _currentPageIndex});
      _broadcastStopped();
    });

    // ③ TTS started
    _tts.setStartHandler(() {
      _isPlaying = true;
      _isPaused = false;
      _broadcastPlaying();
    });

    // ④ Pause / Continue (iOS native)
    _tts.setPauseHandler(() => _broadcastPaused());
    _tts.setContinueHandler(() => _broadcastPlaying());

    // ⑤ Error
    _tts.setErrorHandler((msg) {
      AppLogger.e('TTS error: $msg');
      _broadcastStopped();
    });
  }

  // ── Public API — called by reader_provider ─────────────────────────────

  /// Load pages from a [ParsedDocument] and optionally start from a position.
  Future<void> loadDocument({
    required List<String> pages,
    required String title,
    required String pdfId,
    int startPage = 0,
    int startOffset = 0,
  }) async {
    _pages = pages;
    _currentPageIndex = startPage;
    _pauseCharOffset = startOffset;
    _globalOffset = startOffset;

    queue.add(_buildQueue(pdfId, title));
    mediaItem.add(_buildMediaItem(pdfId, title, startPage));
  }

  Future<void> applyConfig(TtsConfig config) async {
    _config = config;
    await _applyConfig(config);
  }

  // ── BaseAudioHandler overrides ─────────────────────────────────────────

  @override
  Future<void> play() async {
    if (_pages.isEmpty) return;

    final pageText = _pages[_currentPageIndex];

    if (_isPaused && Platform.isAndroid) {
      // Android: resume by speaking remaining substring
      _globalOffset = _pauseCharOffset;
      final remaining = pageText.length > _pauseCharOffset
          ? pageText.substring(_pauseCharOffset)
          : pageText;
      await _tts.speak(remaining);
    } else if (!_isPlaying) {
      // Fresh start / new page
      _globalOffset = 0;
      await _tts.speak(pageText);
    } else {
      // iOS: native continue — continueHandler is a VoidCallback
      _tts.continueHandler?.call();
    }

    _isPaused = false;
    _broadcastPlaying();
  }

  @override
  Future<void> pause() async {
    if (Platform.isAndroid) {
      // Android has no native pause — stop and record offset
      await _tts.stop();
      _isPaused = true;
      _isPlaying = false;
    } else {
      await _tts.pause();
      _isPaused = true;
    }
    _broadcastPaused();
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
    _isPlaying = false;
    _isPaused = false;
    _globalOffset = 0;
    _pauseCharOffset = 0;
    customEvent.add({'type': 'stop'});
    _broadcastStopped();
  }

  @override
  Future<void> skipToNext() async {
    if (_currentPageIndex < _pages.length - 1) {
      await _tts.stop();
      _currentPageIndex++;
      _resetOffsets();
      mediaItem.add(
        _buildMediaItem('', mediaItem.value?.album ?? '', _currentPageIndex),
      );
      if (_isPlaying || !_isPaused) {
        _globalOffset = 0;
        await _tts.speak(_pages[_currentPageIndex]);
      }
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_currentPageIndex > 0) {
      await _tts.stop();
      _currentPageIndex--;
      _resetOffsets();
      mediaItem.add(
        _buildMediaItem('', mediaItem.value?.album ?? '', _currentPageIndex),
      );
      if (_isPlaying || !_isPaused) {
        _globalOffset = 0;
        await _tts.speak(_pages[_currentPageIndex]);
      }
    }
  }

  /// Called by [reader_provider] to jump to a specific page.
  Future<void> skipToPage(int pageIndex) async {
    if (pageIndex < 0 || pageIndex >= _pages.length) return;
    await _tts.stop();
    _currentPageIndex = pageIndex;
    _resetOffsets();
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  void _resetOffsets() {
    _globalOffset = 0;
    _pauseCharOffset = 0;
    _isPlaying = false;
    _isPaused = false;
  }

  Future<void> _applyConfig(TtsConfig config) async {
    await _tts.setLanguage(config.language);
    await _tts.setSpeechRate(config.speed);
    await _tts.setVolume(config.volume);
    await _tts.setPitch(config.pitch);
    if (config.voice != null) {
      await _tts.setVoice({'name': config.voice!, 'locale': config.language});
    }
  }

  void _broadcastPlaying() {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.pause,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      playing: true,
      processingState: AudioProcessingState.ready,
    ));
  }

  void _broadcastPaused() {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.play,
        MediaControl.skipToNext,
        MediaControl.stop,
      ],
      playing: false,
      processingState: AudioProcessingState.ready,
    ));
  }

  void _broadcastStopped() {
    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.play],
      playing: false,
      processingState: AudioProcessingState.idle,
    ));
  }

  List<MediaItem> _buildQueue(String pdfId, String title) =>
      _pages.asMap().entries.map((e) {
        return MediaItem(
          id: '${pdfId}_page_${e.key}',
          title: title,
          album: 'Page ${e.key + 1} of ${_pages.length}',
          artist: 'PDF Readcloud',
          extras: {'pageIndex': e.key, 'pdfId': pdfId},
        );
      }).toList();

  MediaItem _buildMediaItem(String pdfId, String title, int pageIndex) =>
      MediaItem(
        id: '${pdfId}_page_$pageIndex',
        title: title,
        album: 'Page ${pageIndex + 1} of ${_pages.length}',
        artist: 'PDF Readcloud',
        extras: {'pageIndex': pageIndex, 'pdfId': pdfId},
      );

  // Getters for provider
  int get currentPageIndex => _currentPageIndex;
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;

  Future<List<dynamic>> getAvailableVoices() async =>
      await _tts.getVoices as List;

  Future<List<dynamic>> getAvailableLanguages() async =>
      await _tts.getLanguages as List;
}
