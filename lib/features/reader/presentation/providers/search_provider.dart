import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/text_search_models.dart';

class ReaderSearchState {
  final String query;
  final List<TextMatch> matches;
  final int currentIndex;

  const ReaderSearchState({
    this.query = '',
    this.matches = const [],
    this.currentIndex = -1,
  });

  TextMatch? get currentMatch {
    if (currentIndex < 0 || currentIndex >= matches.length) return null;
    return matches[currentIndex];
  }

  ReaderSearchState copyWith({
    String? query,
    List<TextMatch>? matches,
    int? currentIndex,
  }) {
    return ReaderSearchState(
      query: query ?? this.query,
      matches: matches ?? this.matches,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

class ReaderSearchNotifier extends StateNotifier<ReaderSearchState> {
  ReaderSearchNotifier() : super(const ReaderSearchState());

  void setResults({
    required String query,
    required List<TextMatch> matches,
    required int currentIndex,
  }) {
    if (!mounted) return;
    state = ReaderSearchState(
      query: query,
      matches: List<TextMatch>.unmodifiable(matches),
      currentIndex: currentIndex,
    );
  }

  void setCurrentIndex(int index) {
    if (!mounted) return;
    if (index < 0 || index >= state.matches.length) return;
    state = state.copyWith(currentIndex: index);
  }

  void clear() {
    if (!mounted) return;
    state = const ReaderSearchState();
  }
}

final readerSearchProvider =
    StateNotifierProvider<ReaderSearchNotifier, ReaderSearchState>(
  (ref) => ReaderSearchNotifier(),
);
