import 'package:equatable/equatable.dart';

class ParsedPage extends Equatable {
  final int pageIndex;
  final String text; // Normalized plain text

  const ParsedPage({required this.pageIndex, required this.text});

  bool get isEmpty => text.trim().isEmpty;

  @override
  List<Object?> get props => [pageIndex, text];
}
