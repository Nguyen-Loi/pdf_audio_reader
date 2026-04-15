import 'package:equatable/equatable.dart';

class PdfPageText extends Equatable {
  final int pageIndex;
  final String text;

  const PdfPageText({
    required this.pageIndex,
    required this.text,
  });

  @override
  List<Object?> get props => [pageIndex, text];
}

class TextMatch extends Equatable {
  final int pageIndex;
  final int start;
  final int end;
  final String matchedText;

  const TextMatch({
    required this.pageIndex,
    required this.start,
    required this.end,
    required this.matchedText,
  });

  @override
  List<Object?> get props => [pageIndex, start, end, matchedText];
}
