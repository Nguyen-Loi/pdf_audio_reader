import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/text_search_models.dart';
import 'package:pdf_audio_reader/features/reader/services/text_search_service.dart';

enum SearchSourceType { none, plainText, pdf }

class SearchController extends ChangeNotifier {
  SearchController({
    TextSearchService? service,
    this.debounceDuration = const Duration(milliseconds: 300),
  }) : _service = service ?? const TextSearchService();

  final TextSearchService _service;
  final Duration debounceDuration;

  List<TextMatch> _matches = const [];
  int _currentIndex = -1;
  String _query = '';

  SearchSourceType _sourceType = SearchSourceType.none;
  String _plainText = '';
  String _normalizedPlainText = '';
  List<PdfPageText> _pdfPages = const [];
  List<_NormalizedPdfPage> _normalizedPdfPages = const [];

  int _sourceVersion = 0;
  int _lastComputedSourceVersion = -1;
  String _lastComputedNormalizedQuery = '';

  Timer? _debounce;

  List<TextMatch> get matches => _matches;
  int get currentIndex => _currentIndex;
  String get query => _query;
  SearchSourceType get sourceType => _sourceType;

  TextMatch? get currentMatch {
    if (_currentIndex < 0 || _currentIndex >= _matches.length) return null;
    return _matches[_currentIndex];
  }

  bool get hasMatches => _matches.isNotEmpty;

  void setPlainTextSource(String text, {String initialQuery = ''}) {
    _sourceType = SearchSourceType.plainText;
    _plainText = text;
    _normalizedPlainText = _service.normalizeText(text);
    _pdfPages = const [];
    _normalizedPdfPages = const [];
    _invalidateSourceCache();
    updateQuery(initialQuery, immediate: true);
  }

  void setPdfSource(List<PdfPageText> pages, {String initialQuery = ''}) {
    _sourceType = SearchSourceType.pdf;
    _pdfPages = List<PdfPageText>.unmodifiable(pages);
    _normalizedPdfPages = _pdfPages
        .map(
          (page) => _NormalizedPdfPage(
            pageIndex: page.pageIndex,
            originalText: page.text,
            normalizedText: _service.normalizeText(page.text),
          ),
        )
        .toList(growable: false);
    _plainText = '';
    _normalizedPlainText = '';
    _invalidateSourceCache();
    updateQuery(initialQuery, immediate: true);
  }

  void clear() {
    _debounce?.cancel();
    _sourceType = SearchSourceType.none;
    _plainText = '';
    _normalizedPlainText = '';
    _pdfPages = const [];
    _normalizedPdfPages = const [];
    _query = '';
    _matches = const [];
    _currentIndex = -1;
    _sourceVersion++;
    _lastComputedSourceVersion = -1;
    _lastComputedNormalizedQuery = '';
    notifyListeners();
  }

  void updateQuery(String query, {bool immediate = false}) {
    _query = query;
    _debounce?.cancel();

    if (immediate) {
      _runSearch();
      return;
    }

    _debounce = Timer(debounceDuration, _runSearch);
  }

  TextMatch? next() {
    if (_matches.isEmpty) return null;
    _currentIndex = (_currentIndex + 1) % _matches.length;
    notifyListeners();
    return _matches[_currentIndex];
  }

  TextMatch? previous() {
    if (_matches.isEmpty) return null;
    _currentIndex = (_currentIndex - 1 + _matches.length) % _matches.length;
    notifyListeners();
    return _matches[_currentIndex];
  }

  TextMatch? nextMatch() => next();

  TextMatch? previousMatch() => previous();

  void setCurrentIndex(int index) {
    if (index < 0 || index >= _matches.length) return;
    _currentIndex = index;
    notifyListeners();
  }

  void _runSearch() {
    final normalizedQuery = _service.normalizeQuery(_query);

    if (_sourceType == SearchSourceType.none || normalizedQuery.isEmpty) {
      _lastComputedNormalizedQuery = normalizedQuery;
      _lastComputedSourceVersion = _sourceVersion;
      _matches = const [];
      _currentIndex = -1;
      notifyListeners();
      return;
    }

    final canReuseCached = _lastComputedSourceVersion == _sourceVersion &&
        _lastComputedNormalizedQuery == normalizedQuery;

    if (canReuseCached) {
      notifyListeners();
      return;
    }

    final results = switch (_sourceType) {
      SearchSourceType.plainText => _searchInPlainText(normalizedQuery),
      SearchSourceType.pdf => _searchInPdf(normalizedQuery),
      SearchSourceType.none => const <TextMatch>[],
    };

    _matches = List<TextMatch>.unmodifiable(results);
    _currentIndex = _matches.isEmpty ? -1 : 0;
    _lastComputedNormalizedQuery = normalizedQuery;
    _lastComputedSourceVersion = _sourceVersion;
    notifyListeners();
  }

  List<TextMatch> _searchInPlainText(String normalizedQuery) {
    if (_plainText.isEmpty ||
        normalizedQuery.length > _normalizedPlainText.length) {
      return const [];
    }

    return _collectMatches(
      normalizedText: _normalizedPlainText,
      originalText: _plainText,
      normalizedQuery: normalizedQuery,
      pageIndex: 0,
    );
  }

  List<TextMatch> _searchInPdf(String normalizedQuery) {
    if (_normalizedPdfPages.isEmpty) return const [];

    final results = <TextMatch>[];
    for (final page in _normalizedPdfPages) {
      if (page.normalizedText.isEmpty ||
          normalizedQuery.length > page.normalizedText.length) {
        continue;
      }

      results.addAll(
        _collectMatches(
          normalizedText: page.normalizedText,
          originalText: page.originalText,
          normalizedQuery: normalizedQuery,
          pageIndex: page.pageIndex,
        ),
      );
    }

    return results;
  }

  List<TextMatch> _collectMatches({
    required String normalizedText,
    required String originalText,
    required String normalizedQuery,
    required int pageIndex,
  }) {
    final results = <TextMatch>[];
    var searchStart = 0;

    while (searchStart < normalizedText.length) {
      final matchStart = normalizedText.indexOf(normalizedQuery, searchStart);
      if (matchStart == -1) break;

      final matchEnd = matchStart + normalizedQuery.length;
      results.add(
        TextMatch(
          pageIndex: pageIndex,
          start: matchStart,
          end: matchEnd,
          matchedText: originalText.substring(matchStart, matchEnd),
        ),
      );

      searchStart = matchStart + 1;
    }

    return results;
  }

  void _invalidateSourceCache() {
    _sourceVersion++;
    _lastComputedSourceVersion = -1;
    _lastComputedNormalizedQuery = '';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

class _NormalizedPdfPage {
  final int pageIndex;
  final String originalText;
  final String normalizedText;

  const _NormalizedPdfPage({
    required this.pageIndex,
    required this.originalText,
    required this.normalizedText,
  });
}
