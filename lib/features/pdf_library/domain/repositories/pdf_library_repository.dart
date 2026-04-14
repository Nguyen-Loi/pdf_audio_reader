import 'package:fpdart/fpdart.dart';
import 'package:pdf_audio_reader/core/errors/failures.dart';
import 'package:pdf_audio_reader/features/pdf_library/domain/entities/pdf_document_info.dart';

abstract interface class PdfLibraryRepository {
  Future<Either<Failure, List<PdfDocumentInfo>>> getPdfList();
  Future<Either<Failure, PdfDocumentInfo>> importPdf(String filePath);
  Future<Either<Failure, void>> deletePdf(String id);
  Future<Either<Failure, void>> saveReadingProgress({
    required String id,
    required int pageIndex,
    required int charOffset,
  });
}
