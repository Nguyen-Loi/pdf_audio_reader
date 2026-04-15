import 'package:equatable/equatable.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/tts_config.dart';

class TtsProgressModel extends Equatable {
  final int startOffset;
  final int endOffset;
  final String word;
  final int pageIndex;
  final ReaderMode renderMode;

  const TtsProgressModel({
    required this.startOffset,
    required this.endOffset,
    required this.word,
    required this.pageIndex,
    required this.renderMode,
  });

  @override
  List<Object?> get props => [
        startOffset,
        endOffset,
        word,
        pageIndex,
        renderMode,
      ];
}
