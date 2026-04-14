import 'package:equatable/equatable.dart';

class TtsProgressModel extends Equatable {
  final int start;
  final int end;
  final String word;

  const TtsProgressModel({
    required this.start,
    required this.end,
    required this.word,
  });

  @override
  List<Object?> get props => [start, end, word];
}
