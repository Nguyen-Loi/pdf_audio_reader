import 'package:equatable/equatable.dart';
import 'package:pdf_audio_reader/features/pdf_parser/domain/entities/word_coordinate.dart';

class ParsedPage extends Equatable {
  final int pageIndex;
  final String text; // Normalized plain text
  final List<WordCoordinate> wordCoordinates;

  const ParsedPage({
    required this.pageIndex,
    required this.text,
    this.wordCoordinates = const [],
  });

  bool get isEmpty => text.trim().isEmpty;

  @override
  List<Object?> get props => [pageIndex, text, wordCoordinates];
}

