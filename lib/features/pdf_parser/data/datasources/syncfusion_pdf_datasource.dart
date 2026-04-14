import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pdf_audio_reader/core/errors/exceptions.dart';
import 'package:pdf_audio_reader/features/pdf_parser/domain/entities/parsed_document.dart';
import 'package:pdf_audio_reader/features/pdf_parser/domain/entities/parsed_page.dart';
import 'package:pdf_audio_reader/features/pdf_parser/domain/entities/word_coordinate.dart';

class SyncfusionPdfDatasource {
  Future<ParsedDocument> extractText(
    String filePath, {
    required String pdfId,
    required String title,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist: $filePath');
      }

      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final extractor = PdfTextExtractor(document);

      final List<ParsedPage> parsedPages = [];

      for (int i = 0; i < document.pages.count; i++) {
        final List<TextLine> lines = extractor.extractTextLines(
          startPageIndex: i,
          endPageIndex: i,
        );

        final StringBuffer pageTextBuffer = StringBuffer();
        final List<WordCoordinate> wordCoordinates = [];

        for (final line in lines) {
          for (final word in line.wordCollection) {
            final String wordText = word.text;
            if (wordText.trim().isEmpty) continue; // Skip empty blocks

            final int charStart = pageTextBuffer.length;
            pageTextBuffer.write(wordText);
            final int charEnd = pageTextBuffer.length;

            wordCoordinates.add(
              WordCoordinate(
                charStart: charStart,
                charEnd: charEnd,
                bounds: word.bounds,
              ),
            );

            pageTextBuffer.write(' '); // Space between words
          }
          pageTextBuffer.write('\n'); // Newline between lines
        }

        final pageText = pageTextBuffer.toString();
        parsedPages.add(
          ParsedPage(
            pageIndex: i,
            text: pageText,
            wordCoordinates: wordCoordinates,
          ),
        );
      }

      document.dispose();

      if (parsedPages.isEmpty) {
        throw const PdfParseException('No pages found or document is unreadable.');
      }

      return ParsedDocument(
        pdfId: pdfId,
        title: title,
        pages: parsedPages,
      );
    } catch (e) {
      throw PdfParseException(e.toString());
    }
  }
}
