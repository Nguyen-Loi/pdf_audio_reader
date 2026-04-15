import 'package:pdf_audio_reader/features/reader/domain/entities/text_search_models.dart';

class TextSearchService {
  const TextSearchService({this.removeVietnameseAccents = true});

  final bool removeVietnameseAccents;

  List<TextMatch> searchInPlainText(String text, String query) {
    if (text.isEmpty) return const [];

    final normalizedQuery = _normalizeQuery(query);
    if (normalizedQuery.isEmpty) return const [];

    final normalizedText = _normalizeText(text);
    if (normalizedQuery.length > normalizedText.length) return const [];

    return _collectMatches(
      normalizedText: normalizedText,
      originalText: text,
      normalizedQuery: normalizedQuery,
      pageIndex: 0,
    );
  }

  List<TextMatch> searchInPdf(List<PdfPageText> pages, String query) {
    if (pages.isEmpty) return const [];

    final normalizedQuery = _normalizeQuery(query);
    if (normalizedQuery.isEmpty) return const [];

    final matches = <TextMatch>[];
    for (final page in pages) {
      if (page.text.isEmpty) continue;

      final normalizedText = _normalizeText(page.text);
      if (normalizedQuery.length > normalizedText.length) continue;

      matches.addAll(
        _collectMatches(
          normalizedText: normalizedText,
          originalText: page.text,
          normalizedQuery: normalizedQuery,
          pageIndex: page.pageIndex,
        ),
      );
    }

    return matches;
  }

  String normalizeQuery(String query) => _normalizeQuery(query);

  String normalizeText(String text) => _normalizeText(text);

  String _normalizeQuery(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '';
    return _normalizeText(trimmed);
  }

  String _normalizeText(String input) {
    final lower = input.toLowerCase();
    if (!removeVietnameseAccents || lower.isEmpty) return lower;

    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_vietnameseMap[char] ?? char);
    }
    return buffer.toString();
  }

  List<TextMatch> _collectMatches({
    required String normalizedText,
    required String originalText,
    required String normalizedQuery,
    required int pageIndex,
  }) {
    final matches = <TextMatch>[];
    var searchStart = 0;

    while (searchStart < normalizedText.length) {
      final matchStart = normalizedText.indexOf(normalizedQuery, searchStart);
      if (matchStart == -1) break;

      final matchEnd = matchStart + normalizedQuery.length;
      matches.add(
        TextMatch(
          pageIndex: pageIndex,
          start: matchStart,
          end: matchEnd,
          matchedText: originalText.substring(matchStart, matchEnd),
        ),
      );

      searchStart = matchStart + 1;
    }

    return matches;
  }

  static const Map<String, String> _vietnameseMap = {
    'a': 'a',
    'à': 'a',
    'á': 'a',
    'ả': 'a',
    'ã': 'a',
    'ạ': 'a',
    'ă': 'a',
    'ằ': 'a',
    'ắ': 'a',
    'ẳ': 'a',
    'ẵ': 'a',
    'ặ': 'a',
    'â': 'a',
    'ầ': 'a',
    'ấ': 'a',
    'ẩ': 'a',
    'ẫ': 'a',
    'ậ': 'a',
    'e': 'e',
    'è': 'e',
    'é': 'e',
    'ẻ': 'e',
    'ẽ': 'e',
    'ẹ': 'e',
    'ê': 'e',
    'ề': 'e',
    'ế': 'e',
    'ể': 'e',
    'ễ': 'e',
    'ệ': 'e',
    'i': 'i',
    'ì': 'i',
    'í': 'i',
    'ỉ': 'i',
    'ĩ': 'i',
    'ị': 'i',
    'o': 'o',
    'ò': 'o',
    'ó': 'o',
    'ỏ': 'o',
    'õ': 'o',
    'ọ': 'o',
    'ô': 'o',
    'ồ': 'o',
    'ố': 'o',
    'ổ': 'o',
    'ỗ': 'o',
    'ộ': 'o',
    'ơ': 'o',
    'ờ': 'o',
    'ớ': 'o',
    'ở': 'o',
    'ỡ': 'o',
    'ợ': 'o',
    'u': 'u',
    'ù': 'u',
    'ú': 'u',
    'ủ': 'u',
    'ũ': 'u',
    'ụ': 'u',
    'ư': 'u',
    'ừ': 'u',
    'ứ': 'u',
    'ử': 'u',
    'ữ': 'u',
    'ự': 'u',
    'y': 'y',
    'ỳ': 'y',
    'ý': 'y',
    'ỷ': 'y',
    'ỹ': 'y',
    'ỵ': 'y',
    'đ': 'd',
  };
}
