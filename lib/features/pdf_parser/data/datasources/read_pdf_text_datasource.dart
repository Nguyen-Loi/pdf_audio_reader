import 'package:pdf_audio_reader/core/errors/exceptions.dart';
import 'package:pdf_audio_reader/core/extensions/string_ext.dart';
import 'package:pdf_audio_reader/core/utils/logger.dart';
import 'package:pdf_audio_reader/features/pdf_parser/domain/entities/parsed_document.dart';
import 'package:pdf_audio_reader/features/pdf_parser/domain/entities/parsed_page.dart';
import 'package:read_pdf_text/read_pdf_text.dart';

class ReadPdfTextDatasource {
  const ReadPdfTextDatasource();

  Future<ParsedDocument> extractText(
    String filePath, {
    required String pdfId,
    required String title,
  }) async {
    try {
      // Returns List<String> — one entry per page
      final rawPages = await ReadPdfText.getPDFtextPaginated(filePath);

      if (rawPages.isEmpty) {
        throw const PdfParseException(
          'No pages found. The PDF may be encrypted or scanned.',
        );
      }

      final pages = rawPages.asMap().entries.map((entry) {
        final normalized = entry.value.normalizeWhitespace();
        return ParsedPage(pageIndex: entry.key, text: normalized);
      }).toList();

      final readableCount = pages.where((p) => !p.isEmpty).length;
      if (readableCount == 0) {
        throw const PdfParseException(
          'No readable text found. This may be a scanned image PDF.',
        );
      }

      AppLogger.i('Parsed $pdfId: ${pages.length} pages, '
          '$readableCount readable');

      return ParsedDocument(pdfId: pdfId, title: title, pages: pages);
    } on PdfParseException {
      rethrow;
    } catch (e) {
      AppLogger.e('extractText failed', e);
      throw PdfParseException(e.toString());
    }
  }
}
