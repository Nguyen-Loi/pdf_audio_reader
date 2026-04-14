import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_audio_reader/core/errors/exceptions.dart';
import 'package:pdf_audio_reader/core/utils/logger.dart';
import 'package:pdf_audio_reader/features/pdf_library/domain/entities/pdf_document_info.dart';
import 'package:uuid/uuid.dart';

/// Saves PDF files to app documents dir and persists metadata to Firestore.
class LocalPdfDatasource {
  final String? userId;

  LocalPdfDatasource({this.userId});

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(userId ?? 'guest')
          .collection('pdfs');

  Future<List<PdfDocumentInfo>> getPdfList() async {
    try {
      final snap = await _col.orderBy('importedAt', descending: true).get();
      return snap.docs
          .map((d) => PdfDocumentInfo.fromMap(d.data()))
          .toList();
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

      await _col.doc(doc.id).set(doc.toMap());
      return doc;
    } catch (e) {
      AppLogger.e('importPdf failed', e);
      throw PdfImportException(e.toString());
    }
  }

  Future<void> deletePdf(String id) async {
    try {
      // Delete from Firestore
      await _col.doc(id).delete();
      // Delete local file
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/$id.pdf');
      if (await file.exists()) await file.delete();
    } catch (e) {
      throw StorageException(e.toString());
    }
  }

  Future<void> saveReadingProgress({
    required String id,
    required int pageIndex,
    required int charOffset,
  }) async {
    await _col.doc(id).update({
      'lastPageIndex': pageIndex,
      'lastCharOffset': charOffset,
    });
  }

  Future<void> updatePageCount(String id, int pageCount) async {
    await _col.doc(id).update({'pageCount': pageCount});
  }
}
