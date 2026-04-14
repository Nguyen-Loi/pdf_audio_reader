import 'package:file_picker/file_picker.dart';
import 'package:pdf_audio_reader/core/errors/exceptions.dart';

class FileService {
  const FileService();

  /// Opens the system file picker and returns the picked PDF path.
  /// Throws [PdfImportException] if nothing is selected.
  Future<String> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) {
      throw const PdfImportException('No file selected.');
    }

    final path = result.files.single.path;
    if (path == null) {
      throw const PdfImportException('Could not read file path.');
    }
    return path;
  }
}
