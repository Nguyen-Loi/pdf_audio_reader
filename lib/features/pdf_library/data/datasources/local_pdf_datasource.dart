import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_audio_reader/core/errors/exceptions.dart';
import 'package:pdf_audio_reader/core/utils/logger.dart';
import 'package:pdf_audio_reader/features/pdf_library/domain/entities/pdf_document_info.dart';
import 'package:uuid/uuid.dart';

/// Saves PDF files and metadata locally in app documents directory.
class LocalPdfDatasource {
  LocalPdfDatasource({String? userId});

  Future<File> get _indexFile async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/pdf_library_index.json');
    if (!await file.exists()) {
      await file.writeAsString('[]');
    }
    return file;
  }

  Future<List<PdfDocumentInfo>> _readIndex() async {
    final file = await _indexFile;
    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const StorageException('Invalid local PDF index format');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(PdfDocumentInfo.fromMap)
        .toList();
  }

  Future<void> _writeIndex(List<PdfDocumentInfo> docs) async {
    final file = await _indexFile;
    await file.writeAsString(jsonEncode(docs.map((e) => e.toMap()).toList()));
  }

  Future<List<PdfDocumentInfo>> getPdfList() async {
    try {
      final docs = await _readIndex();
      docs.sort((a, b) => b.importedAt.compareTo(a.importedAt));
      return docs;
    } catch (e) {
      AppLogger.e('getPdfList failed', e);
      throw StorageException(e.toString());
    }
  }

  Future<PdfDocumentInfo> importPdf(String sourcePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}.pdf';
      final destPath = '${appDir.path}/$fileName';

      // Copy file into app sandbox
      await File(sourcePath).copy(destPath);

      // Basic title from file name
      final rawName = sourcePath.split('/').last.replaceAll('.pdf', '');
      final title = rawName.replaceAll('_', ' ').replaceAll('-', ' ');

      final doc = PdfDocumentInfo(
        id: fileName.replaceAll('.pdf', ''),
        title: title,
        filePath: destPath,
        pageCount: 0, // Updated after parsing
        importedAt: DateTime.now(),
      );

      final docs = await _readIndex();
      docs.add(doc);
      await _writeIndex(docs);
      return doc;
    } catch (e) {
      AppLogger.e('importPdf failed', e);
      throw PdfImportException(e.toString());
    }
  }

  Future<void> deletePdf(String id) async {
    try {
      final docs = await _readIndex();
      final target =
          docs.where((d) => d.id == id).cast<PdfDocumentInfo?>().firstWhere(
                (d) => d != null,
                orElse: () => null,
              );
      docs.removeWhere((d) => d.id == id);
      await _writeIndex(docs);

      final filePath = target?.filePath;
      final file = filePath != null
          ? File(filePath)
          : File('${(await getApplicationDocumentsDirectory()).path}/$id.pdf');
      if (await file.exists()) await file.delete();
    } catch (e) {
      AppLogger.e('deletePdf failed', e);
      throw StorageException(e.toString());
    }
  }

  Future<void> saveReadingProgress({
    required String id,
    required int pageIndex,
    required int charOffset,
  }) async {
    try {
      final docs = await _readIndex();
      final index = docs.indexWhere((d) => d.id == id);
      if (index == -1) {
        throw StorageException('PDF not found: $id');
      }

      docs[index] = docs[index].copyWith(
        lastPageIndex: pageIndex,
        lastCharOffset: charOffset,
      );
      await _writeIndex(docs);
    } catch (e) {
      AppLogger.e('saveReadingProgress failed', e);
      throw StorageException(e.toString());
    }
  }

  Future<void> updatePageCount(String id, int pageCount) async {
    try {
      final docs = await _readIndex();
      final index = docs.indexWhere((d) => d.id == id);
      if (index == -1) {
        throw StorageException('PDF not found: $id');
      }

      docs[index] = docs[index].copyWith(pageCount: pageCount);
      await _writeIndex(docs);
    } catch (e) {
      AppLogger.e('updatePageCount failed', e);
      throw StorageException(e.toString());
    }
  }
}
