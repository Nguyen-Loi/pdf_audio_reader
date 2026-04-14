import 'package:equatable/equatable.dart';

class PdfDocumentInfo extends Equatable {
  final String id;
  final String title;
  final String filePath;
  final int pageCount;
  final DateTime importedAt;
  final int? lastPageIndex;
  final int? lastCharOffset;

  const PdfDocumentInfo({
    required this.id,
    required this.title,
    required this.filePath,
    required this.pageCount,
    required this.importedAt,
    this.lastPageIndex,
    this.lastCharOffset,
  });

  PdfDocumentInfo copyWith({
    String? id,
    String? title,
    String? filePath,
    int? pageCount,
    DateTime? importedAt,
    int? lastPageIndex,
    int? lastCharOffset,
  }) {
    return PdfDocumentInfo(
      id: id ?? this.id,
      title: title ?? this.title,
      filePath: filePath ?? this.filePath,
      pageCount: pageCount ?? this.pageCount,
      importedAt: importedAt ?? this.importedAt,
      lastPageIndex: lastPageIndex ?? this.lastPageIndex,
      lastCharOffset: lastCharOffset ?? this.lastCharOffset,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'filePath': filePath,
        'pageCount': pageCount,
        'importedAt': importedAt.toIso8601String(),
        'lastPageIndex': lastPageIndex,
        'lastCharOffset': lastCharOffset,
      };

  factory PdfDocumentInfo.fromMap(Map<String, dynamic> map) =>
      PdfDocumentInfo(
        id: map['id'] as String,
        title: map['title'] as String,
        filePath: map['filePath'] as String,
        pageCount: (map['pageCount'] as num).toInt(),
        importedAt: DateTime.parse(map['importedAt'] as String),
        lastPageIndex: map['lastPageIndex'] as int?,
        lastCharOffset: map['lastCharOffset'] as int?,
      );

  @override
  List<Object?> get props => [id, title, filePath, pageCount, importedAt];
}
