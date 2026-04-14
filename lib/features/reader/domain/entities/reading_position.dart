import 'package:equatable/equatable.dart';

class ReadingPosition extends Equatable {
  final int pageIndex;
  final int charOffset;

  const ReadingPosition({required this.pageIndex, required this.charOffset});

  static const start = ReadingPosition(pageIndex: 0, charOffset: 0);

  ReadingPosition copyWith({int? pageIndex, int? charOffset}) =>
      ReadingPosition(
        pageIndex: pageIndex ?? this.pageIndex,
        charOffset: charOffset ?? this.charOffset,
      );

  @override
  List<Object?> get props => [pageIndex, charOffset];
}
