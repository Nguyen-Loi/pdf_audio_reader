import 'package:fpdart/fpdart.dart';
import 'package:pdf_audio_reader/core/errors/exceptions.dart';
import 'package:pdf_audio_reader/core/errors/failures.dart';
import 'package:pdf_audio_reader/features/pdf_library/data/datasources/local_pdf_datasource.dart';
import 'package:pdf_audio_reader/features/pdf_library/domain/entities/pdf_document_info.dart';
import 'package:pdf_audio_reader/features/pdf_library/domain/repositories/pdf_library_repository.dart';

class PdfLibraryRepositoryImpl implements PdfLibraryRepository {
  final LocalPdfDatasource _datasource;

  const PdfLibraryRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<PdfDocumentInfo>>> getPdfList() async {
    try {
      return Right(await _datasource.getPdfList());
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PdfDocumentInfo>> importPdf(String filePath) async {
    try {
      return Right(await _datasource.importPdf(filePath));
    } on PdfImportException catch (e) {
      return Left(PdfImportFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePdf(String id) async {
    try {
      await _datasource.deletePdf(id);
      return const Right(null);
    } on StorageException catch (e) {
      return Left(StorageFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveReadingProgress({
    required String id,
    required int pageIndex,
    required int charOffset,
  }) async {
    try {
      await _datasource.saveReadingProgress(
        id: id,
        pageIndex: pageIndex,
        charOffset: charOffset,
      );
      return const Right(null);
    } catch (e) {
      return Left(StorageFailure(e.toString()));
    }
  }
}
