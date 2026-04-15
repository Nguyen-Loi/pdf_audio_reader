import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:pdf_audio_reader/features/pdf_parser/domain/entities/parsed_document.dart';
import 'package:pdf_audio_reader/features/pdf_parser/domain/entities/word_coordinate.dart';

enum ReaderContentKind { plainText, pdf }

class ReaderContent extends Equatable {
  final ReaderContentKind kind;
  final String rawText;
  final List<PdfPageData> pages;

  const ReaderContent._({
    required this.kind,
    required this.rawText,
    required this.pages,
  });

  factory ReaderContent.plainText(String rawText) => ReaderContent._(
        kind: ReaderContentKind.plainText,
        rawText: rawText,
        pages: const [],
      );

  factory ReaderContent.pdf(List<PdfPageData> pages) => ReaderContent._(
        kind: ReaderContentKind.pdf,
        rawText: '',
        pages: pages,
      );

  factory ReaderContent.fromParsedDocument(ParsedDocument doc) {
    return ReaderContent.pdf(
      doc.pages
          .map(
            (page) => PdfPageData(
              pageIndex: page.pageIndex,
              text: page.text,
              elements: _mapCoordinates(page.wordCoordinates),
            ),
          )
          .toList(),
    );
  }

  bool get isPdf => kind == ReaderContentKind.pdf;

  int get pageCount => isPdf ? pages.length : 1;

  String pageText(int pageIndex) {
    if (!isPdf) return rawText;
    if (pageIndex < 0 || pageIndex >= pages.length) return '';
    return pages[pageIndex].text;
  }

  List<TextElement> pageElements(int pageIndex) {
    if (!isPdf) return const [];
    if (pageIndex < 0 || pageIndex >= pages.length) return const [];
    return pages[pageIndex].elements;
  }

  List<String> toPageTexts() {
    if (!isPdf) return [rawText];
    return pages.map((p) => p.text).toList();
  }

  static List<TextElement> _mapCoordinates(List<WordCoordinate> coords) {
    return coords
        .map(
          (coord) => TextElement(
            charStart: coord.charStart,
            charEnd: coord.charEnd,
            bounds: coord.bounds,
          ),
        )
        .toList();
  }

  @override
  List<Object?> get props => [kind, rawText, pages];
}

class PdfPageData extends Equatable {
  final int pageIndex;
  final String text;
  final List<TextElement> elements;

  const PdfPageData({
    required this.pageIndex,
    required this.text,
    required this.elements,
  });

  @override
  List<Object?> get props => [pageIndex, text, elements];
}

class TextElement extends Equatable {
  final int charStart;
  final int charEnd;
  final Rect bounds;

  const TextElement({
    required this.charStart,
    required this.charEnd,
    required this.bounds,
  });

  @override
  List<Object?> get props => [charStart, charEnd, bounds];
}
