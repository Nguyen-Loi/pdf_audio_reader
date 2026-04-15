import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/features/audio_handler/audio_handler_provider.dart';
import 'package:pdf_audio_reader/features/pdf_library/presentation/providers/pdf_library_provider.dart';
import 'package:pdf_audio_reader/features/pdf_parser/presentation/providers/pdf_parser_provider.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/reader_content.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/reading_position.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/tts_config.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/language_detection_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/highlight_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/tts_controller.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/tts_config_provider.dart';

// ── Reader state ───────────────────────────────────────────────────────────

class ReaderState {
  final ReaderContent? content;
  final String? contentId;
  final String? title;
  final String detectedLocale;
  final ReadingPosition position;
  final ReaderMode renderMode;
  final bool isPlaying;
  final bool isLoading;
  final String? error;

  const ReaderState({
    this.content,
    this.contentId,
    this.title,
    this.detectedLocale = 'en-US',
    this.position = ReadingPosition.start,
    this.renderMode = ReaderMode.textOnly,
    this.isPlaying = false,
    this.isLoading = false,
    this.error,
  });

  ReaderState copyWith({
    ReaderContent? content,
    String? contentId,
    String? title,
    String? detectedLocale,
    ReadingPosition? position,
    ReaderMode? renderMode,
    bool? isPlaying,
    bool? isLoading,
    String? error,
  }) =>
      ReaderState(
        content: content ?? this.content,
        contentId: contentId ?? this.contentId,
        title: title ?? this.title,
        detectedLocale: detectedLocale ?? this.detectedLocale,
        position: position ?? this.position,
        renderMode: renderMode ?? this.renderMode,
        isPlaying: isPlaying ?? this.isPlaying,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  int get pageCount => content?.pageCount ?? 0;
}

// ── Reader notifier ────────────────────────────────────────────────────────

class ReaderNotifier extends StateNotifier<ReaderState> {
  final Ref _ref;
  StreamSubscription<dynamic>? _eventSub;

  ReaderNotifier(this._ref) : super(const ReaderState());

  Future<void> openPdf({
    required String pdfId,
    ReaderMode? initialReaderMode,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final handler = _ref.read(audioHandlerProvider);
    final ttsConfig = _ref.read(ttsConfigProvider);
    final baseConfig = initialReaderMode == null
        ? ttsConfig
        : ttsConfig.copyWith(readerMode: initialReaderMode);

    try {
      // Get PDF info from library
      final library = _ref.read(pdfLibraryProvider).valueOrNull ?? [];
      final docInfo = library.firstWhere((d) => d.id == pdfId,
          orElse: () => throw Exception('PDF not found'));

      // Parse text
      final parseResult = await _ref.read(
        parsedDocumentProvider((
          filePath: docInfo.filePath,
          pdfId: pdfId,
          title: docInfo.title,
        )).future,
      );

      // Update page count in Firestore if needed
      if (docInfo.pageCount != parseResult.pageCount) {
        final ds = _ref.read(pdfDatasourceProvider);
        await ds.updatePageCount(pdfId, parseResult.pageCount);
        await _ref.read(pdfLibraryProvider.notifier).updatePageCount(
              id: pdfId,
              pageCount: parseResult.pageCount,
            );
      }

      // Determine starting position
      final startPage = docInfo.lastPageIndex ?? 0;
      final startOffset = docInfo.lastCharOffset ?? 0;

      final content = ReaderContent.fromParsedDocument(parseResult);
      final detectedLocale = await _detectContentLocale(content);
      final effectiveConfig =
          await _ref.read(ttsControllerProvider).applyForLocale(
                detectedLocale: detectedLocale,
                baseConfig: baseConfig,
              );
      _syncSessionConfig(effectiveConfig);

      // Load into audio handler
      await handler.loadContent(
        pages: content.toPageTexts(),
        title: parseResult.title,
        contentId: pdfId,
        startPage: startPage,
        startOffset: startOffset,
      );

      // Wire highlight provider to current page
      _ref.read(highlightProvider.notifier).setPageData(
            pageIndex: startPage,
            pageText: content.pageText(startPage),
            elements: content.pageElements(startPage),
            renderMode: effectiveConfig.readerMode,
          );

      // Listen for page-complete events
      _eventSub?.cancel();
      _eventSub = handler.customEvent.listen((event) {
        if (event is Map && event['type'] == 'pageComplete') {
          _onPageComplete(event['pageIndex'] as int);
        }
      });

      state = state.copyWith(
        content: content,
        contentId: pdfId,
        title: parseResult.title,
        detectedLocale: detectedLocale,
        position: ReadingPosition(
          pageIndex: startPage,
          charOffset: startOffset,
        ),
        renderMode: effectiveConfig.readerMode,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> openPlainText({
    required String contentId,
    required String title,
    required String text,
    int startOffset = 0,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final handler = _ref.read(audioHandlerProvider);
    final ttsConfig = _ref.read(ttsConfigProvider);

    final content = ReaderContent.plainText(text);
    final detectedLocale = await _detectContentLocale(content);
    final effectiveConfig =
        await _ref.read(ttsControllerProvider).applyForLocale(
              detectedLocale: detectedLocale,
              baseConfig: ttsConfig,
            );
    _syncSessionConfig(effectiveConfig);

    await handler.loadContent(
      pages: content.toPageTexts(),
      title: title,
      contentId: contentId,
      startPage: 0,
      startOffset: startOffset,
    );

    _ref.read(highlightProvider.notifier).setPageData(
          pageIndex: 0,
          pageText: content.pageText(0),
          elements: const [],
          renderMode: effectiveConfig.readerMode,
        );

    state = state.copyWith(
      content: content,
      contentId: contentId,
      title: title,
      detectedLocale: detectedLocale,
      position: ReadingPosition(pageIndex: 0, charOffset: startOffset),
      renderMode: effectiveConfig.readerMode,
      isLoading: false,
    );
  }

  void _onPageComplete(int completedPage) {
    final content = state.content;
    if (content == null) return;
    final nextPage = completedPage + 1;
    if (nextPage < content.pageCount) {
      skipToPage(nextPage);
      playAt(nextPage, 0);
    }
  }

  Future<void> play() async {
    final position = state.position;
    await playAt(position.pageIndex, position.charOffset);
  }

  Future<void> playAt(int pageIndex, int charOffset) async {
    final content = state.content;
    if (content == null) return;
    if (pageIndex < 0 || pageIndex >= content.pageCount) return;

    final pageText = content.pageText(pageIndex);
    if (pageText.trim().isEmpty) return;

    final maxOffset = pageText.length > 0 ? pageText.length - 1 : 0;
    final safeOffset = charOffset.clamp(0, maxOffset);

    final handler = _ref.read(audioHandlerProvider);
    final baseConfig = _ref.read(ttsConfigProvider);

    final effectiveConfig = await _ref
        .read(ttsControllerProvider)
        .applyForLocale(
            detectedLocale: state.detectedLocale, baseConfig: baseConfig);

    await handler.playMediaItem(_buildMediaItem(
      contentId: state.contentId ?? 'reader_content',
      title: state.title ?? 'Document',
      pageIndex: pageIndex,
      charOffset: safeOffset,
      renderMode: effectiveConfig.readerMode,
    ));

    await handler.playSegment(
      pageIndex: pageIndex,
      charOffset: safeOffset,
      renderMode: effectiveConfig.readerMode,
    );

    _ref.read(highlightProvider.notifier).setPageData(
          pageIndex: pageIndex,
          pageText: pageText,
          elements: content.pageElements(pageIndex),
          renderMode: state.renderMode,
        );

    state = state.copyWith(
      position: ReadingPosition(pageIndex: pageIndex, charOffset: safeOffset),
      isPlaying: true,
    );
  }

  Future<void> pause() async {
    await _ref.read(audioHandlerProvider).pause();
    state = state.copyWith(isPlaying: false);
  }

  Future<void> stop() async {
    await _ref.read(audioHandlerProvider).stop();
    state = state.copyWith(isPlaying: false);
  }

  Future<void> skipToPage(int pageIndex) async {
    final content = state.content;
    if (content == null || pageIndex < 0 || pageIndex >= content.pageCount) {
      return;
    }

    _ref.read(highlightProvider.notifier).setPageData(
          pageIndex: pageIndex,
          pageText: content.pageText(pageIndex),
          elements: content.pageElements(pageIndex),
          renderMode: state.renderMode,
        );
    state = state.copyWith(
      position: ReadingPosition(pageIndex: pageIndex, charOffset: 0),
    );

    await _ref.read(audioHandlerProvider).skipToPage(pageIndex);
  }

  Future<void> applyConfig(TtsConfig config) async {
    final effectiveConfig = await _ref
        .read(ttsControllerProvider)
        .applyForLocale(
            detectedLocale: state.detectedLocale, baseConfig: config);
    _syncSessionConfig(effectiveConfig);
  }

  /// Persists current position to Firestore.
  Future<void> saveProgress() async {
    final contentId = state.contentId;
    if (contentId == null) return;
    final ds = _ref.read(pdfDatasourceProvider);
    final pageIndex = state.position.pageIndex;
    final charOffset = state.position.charOffset;

    await ds.saveReadingProgress(
      id: contentId,
      pageIndex: pageIndex,
      charOffset: charOffset,
    );
    await _ref.read(pdfLibraryProvider.notifier).updateReadingProgress(
          id: contentId,
          pageIndex: pageIndex,
          charOffset: charOffset,
        );
  }

  Future<String> _detectContentLocale(ReaderContent content) async {
    final detector = _ref.read(languageDetectionServiceProvider);
    final sample = _buildDocumentSample(content);
    return detector.detectLocale(sample, fallbackLocale: 'en-US');
  }

  String _buildDocumentSample(ReaderContent content) {
    if (!content.isPdf) {
      return _trimSample(content.rawText);
    }

    for (final pageText in content.toPageTexts()) {
      if (pageText.trim().isNotEmpty) {
        return _trimSample(pageText);
      }
    }

    return '';
  }

  String _trimSample(String text) {
    if (text.isEmpty) return '';
    final end = text.length > 500 ? 500 : text.length;
    return text.substring(0, end);
  }

  void _syncSessionConfig(TtsConfig effectiveConfig) {
    _ref
        .read(ttsConfigProvider.notifier)
        .setReaderMode(effectiveConfig.readerMode);
    _ref.read(ttsConfigProvider.notifier).setVoice(effectiveConfig.voice);
  }

  MediaItem _buildMediaItem({
    required String contentId,
    required String title,
    required int pageIndex,
    required int charOffset,
    required ReaderMode renderMode,
  }) {
    return MediaItem(
      id: '${contentId}_page_$pageIndex',
      title: title,
      album: 'Page ${pageIndex + 1} of ${state.pageCount}',
      artist: 'PDF Readcloud',
      extras: {
        'pageIndex': pageIndex,
        'contentId': contentId,
        'charOffset': charOffset,
        'renderMode': renderMode.name,
      },
    );
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }
}

final readerProvider = StateNotifierProvider<ReaderNotifier, ReaderState>(
  (ref) => ReaderNotifier(ref),
);
