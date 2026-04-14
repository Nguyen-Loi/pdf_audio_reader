import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/features/pdf_parser/data/datasources/read_pdf_text_datasource.dart';
import 'package:pdf_audio_reader/features/pdf_parser/data/repositories/pdf_parser_repository_impl.dart';
import 'package:pdf_audio_reader/features/pdf_parser/domain/entities/parsed_document.dart';
import 'package:pdf_audio_reader/features/pdf_parser/domain/repositories/pdf_parser_repository.dart';

final pdfParserDatasourceProvider =
    Provider((_) => const ReadPdfTextDatasource());

final pdfParserRepositoryProvider = Provider<PdfParserRepository>(
  (ref) => PdfParserRepositoryImpl(ref.read(pdfParserDatasourceProvider)),
);

/// Cache — keyed by pdfId so repeat opens don't re-parse.
final parsedDocumentProvider = FutureProvider.family<ParsedDocument, ({
  String filePath,
  String pdfId,
  String title,
})>(
  (ref, args) async {
    final repo = ref.read(pdfParserRepositoryProvider);
    final result = await repo.extractText(
      args.filePath,
      pdfId: args.pdfId,
      title: args.title,
    );
    return result.fold((f) => throw f, (doc) => doc);
  },
);
