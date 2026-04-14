import 'package:equatable/equatable.dart';
import 'package:pdf_audio_reader/features/pdf_parser/domain/entities/parsed_page.dart';

class ParsedDocument extends Equatable {
  final String pdfId;
  final String title;
  final List<ParsedPage> pages;

  const ParsedDocument({
    required this.pdfId,
    required this.title,
    required this.pages,
  });

  int get pageCount => pages.length;

  /// Returns only pages with non-empty text.
  List<ParsedPage> get readablePages =>
      pages.where((p) => !p.isEmpty).toList();

  @override
  List<Object?> get props => [pdfId, title, pages];
}
