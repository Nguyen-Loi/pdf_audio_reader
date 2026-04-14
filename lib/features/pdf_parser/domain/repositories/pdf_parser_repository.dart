import 'package:fpdart/fpdart.dart';
import 'package:pdf_audio_reader/core/errors/failures.dart';
import 'package:pdf_audio_reader/features/pdf_parser/domain/entities/parsed_document.dart';

abstract interface class PdfParserRepository {
  Future<Either<Failure, ParsedDocument>> extractText(
    String filePath, {
    required String pdfId,
    required String title,
  });
}
