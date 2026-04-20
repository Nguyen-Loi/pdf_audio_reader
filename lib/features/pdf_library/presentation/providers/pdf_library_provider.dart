import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/features/auth/presentation/providers/auth_provider.dart';
import 'package:pdf_audio_reader/features/pdf_library/data/datasources/local_pdf_datasource.dart';
import 'package:pdf_audio_reader/features/pdf_library/data/repositories/pdf_library_repository_impl.dart';
import 'package:pdf_audio_reader/features/pdf_library/domain/entities/pdf_document_info.dart';
import 'package:pdf_audio_reader/features/pdf_library/domain/repositories/pdf_library_repository.dart';
import 'package:pdf_audio_reader/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:pdf_audio_reader/services/file_service.dart';

final fileServiceProvider = Provider((_) => const FileService());

final pdfDatasourceProvider = Provider<LocalPdfDatasource>((ref) {
  final user = ref.watch(currentUserProvider);
  return LocalPdfDatasource(userId: user?.uid);
});

final pdfLibraryRepositoryProvider = Provider<PdfLibraryRepository>(
  (ref) => PdfLibraryRepositoryImpl(ref.read(pdfDatasourceProvider)),
);

// ── Library notifier ───────────────────────────────────────────────────────

class PdfLibraryNotifier extends AsyncNotifier<List<PdfDocumentInfo>> {
  @override
  Future<List<PdfDocumentInfo>> build() async {
    final result = await ref.read(pdfLibraryRepositoryProvider).getPdfList();
    return result.fold((f) => throw f, (list) => list);
  }

  Future<String?> importPdf() async {
    final fileService = ref.read(fileServiceProvider);
    try {
      final path = await fileService.pickPdf();
      final result =
          await ref.read(pdfLibraryRepositoryProvider).importPdf(path);

      final errorMsg = result.fold(
        (f) => f.message,
        (doc) {
          // Optimistically add
          state = AsyncData([doc, ...state.valueOrNull ?? []]);
          return null;
        },
      );

      if (errorMsg == null) {
        final settings = ref.read(settingsRepositoryProvider);
        settings.incrementImportCount();
      }

      return errorMsg;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> deletePdf(String id) async {
    await ref.read(pdfLibraryRepositoryProvider).deletePdf(id);
    state = AsyncData(
      (state.valueOrNull ?? []).where((d) => d.id != id).toList(),
    );
  }

  Future<void> updatePageCount({
    required String id,
    required int pageCount,
  }) async {
    final docs = state.valueOrNull;
    if (docs == null) return;

    final index = docs.indexWhere((doc) => doc.id == id);
    if (index == -1) return;

    final updatedDocs = [...docs];
    updatedDocs[index] = updatedDocs[index].copyWith(pageCount: pageCount);
    state = AsyncData(updatedDocs);
  }

  Future<void> updateReadingProgress({
    required String id,
    required int pageIndex,
    required int charOffset,
  }) async {
    final docs = state.valueOrNull;
    if (docs == null) return;

    final index = docs.indexWhere((doc) => doc.id == id);
    if (index == -1) return;

    final updatedDocs = [...docs];
    updatedDocs[index] = updatedDocs[index].copyWith(
      lastPageIndex: pageIndex,
      lastCharOffset: charOffset,
    );
    state = AsyncData(updatedDocs);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final result = await ref.read(pdfLibraryRepositoryProvider).getPdfList();
    state = result.fold(
      (f) => AsyncError(f, StackTrace.current),
      (list) => AsyncData(list),
    );
  }
}

final pdfLibraryProvider =
    AsyncNotifierProvider<PdfLibraryNotifier, List<PdfDocumentInfo>>(
  PdfLibraryNotifier.new,
);
