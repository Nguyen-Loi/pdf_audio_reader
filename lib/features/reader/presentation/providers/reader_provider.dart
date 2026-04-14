import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/features/audio_handler/audio_handler_provider.dart';
import 'package:pdf_audio_reader/features/pdf_library/presentation/providers/pdf_library_provider.dart';
import 'package:pdf_audio_reader/features/pdf_parser/domain/entities/parsed_document.dart';
import 'package:pdf_audio_reader/features/pdf_parser/presentation/providers/pdf_parser_provider.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/reading_position.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/tts_config.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/highlight_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/tts_config_provider.dart';

// ── Reader state ───────────────────────────────────────────────────────────

class ReaderState {
  final ParsedDocument? document;
  final ReadingPosition position;
  final bool isPlaying;
  final bool isLoading;
  final String? error;

  const ReaderState({
    this.document,
    this.position = ReadingPosition.start,
    this.isPlaying = false,
    this.isLoading = false,
    this.error,
  });

  ReaderState copyWith({
    ParsedDocument? document,
    ReadingPosition? position,
    bool? isPlaying,
    bool? isLoading,
    String? error,
  }) =>
      ReaderState(
        document: document ?? this.document,
        position: position ?? this.position,
        isPlaying: isPlaying ?? this.isPlaying,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

// ── Reader notifier ────────────────────────────────────────────────────────

class ReaderNotifier extends StateNotifier<ReaderState> {
  final Ref _ref;
  StreamSubscription<dynamic>? _eventSub;

  ReaderNotifier(this._ref) : super(const ReaderState());

  Future<void> openPdf({required String pdfId}) async {
    state = state.copyWith(isLoading: true, error: null);
    final handler = _ref.read(audioHandlerProvider);

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
      }

      // Determine starting position
      final startPage = docInfo.lastPageIndex ?? 0;
      final startOffset = docInfo.lastCharOffset ?? 0;

      // Load into audio handler
      await handler.loadDocument(
        pages: parseResult.pages.map((p) => p.text).toList(),
        title: parseResult.title,
        pdfId: pdfId,
        startPage: startPage,
        startOffset: startOffset,
      );

      // Wire highlight provider to current page
      _ref.read(highlightProvider.notifier).setParsedPage(parseResult.pages[startPage]);

      // Listen for page-complete events
      _eventSub?.cancel();
      _eventSub = handler.customEvent.listen((event) {
        if (event is Map && event['type'] == 'pageComplete') {
          _onPageComplete(event['pageIndex'] as int, parseResult);
        }
      });

      state = state.copyWith(
        document: parseResult,
        position: ReadingPosition(
          pageIndex: startPage,
          charOffset: startOffset,
        ),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _onPageComplete(int completedPage, ParsedDocument doc) {
    final nextPage = completedPage + 1;
    if (nextPage < doc.pages.length) {
      skipToPage(nextPage);
      _ref.read(audioHandlerProvider).play();
    }
  }

  Future<void> play() async {
    await _ref.read(audioHandlerProvider).play();
    state = state.copyWith(isPlaying: true);
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
    final doc = state.document;
    if (doc == null || pageIndex < 0 || pageIndex >= doc.pageCount) return;
    await _ref.read(audioHandlerProvider).skipToPage(pageIndex);
    _ref.read(highlightProvider.notifier)
        .setParsedPage(doc.pages[pageIndex]);
    state = state.copyWith(
      position: ReadingPosition(pageIndex: pageIndex, charOffset: 0),
    );
  }

  Future<void> applyConfig(TtsConfig config) async {
    await _ref.read(audioHandlerProvider).applyConfig(config);
    _ref.read(ttsConfigProvider.notifier).setSpeed(config.speed);
  }

  /// Persists current position to Firestore.
  Future<void> saveProgress() async {
    final doc = state.document;
    if (doc == null) return;
    final handler = _ref.read(audioHandlerProvider);
    final ds = _ref.read(pdfDatasourceProvider);
    await ds.saveReadingProgress(
      id: doc.pdfId,
      pageIndex: handler.currentPageIndex,
      charOffset: 0, // offset tracked by handler
    );
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }
}

final readerProvider =
    StateNotifierProvider<ReaderNotifier, ReaderState>(
  (ref) => ReaderNotifier(ref),
);
