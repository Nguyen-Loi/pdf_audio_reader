import 'package:fpdart/fpdart.dart';
import 'package:pdf_audio_reader/core/errors/exceptions.dart';
import 'package:pdf_audio_reader/core/errors/failures.dart';
import 'package:pdf_audio_reader/features/pdf_parser/data/datasources/syncfusion_pdf_datasource.dart';
import 'package:pdf_audio_reader/features/pdf_parser/domain/entities/parsed_document.dart';
import 'package:pdf_audio_reader/features/pdf_parser/domain/repositories/pdf_parser_repository.dart';

class PdfParserRepositoryImpl implements PdfParserRepository {
  final SyncfusionPdfDatasource _datasource;
  const PdfParserRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, ParsedDocument>> extractText(
    String filePath, {
    required String pdfId,
    required String title,
  }) async {
    try {
      final doc = await _datasource.extractText(
        filePath,
        pdfId: pdfId,
        title: title,
      );
      return Right(doc);
    } on PdfParseException catch (e) {
      return Left(PdfParseFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
