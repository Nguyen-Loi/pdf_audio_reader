import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ReaderUiState {
  fullPage,
  overlayHud,
  audioMode,
}

class ReaderUiStateNotifier extends StateNotifier<ReaderUiState> {
  ReaderUiStateNotifier() : super(ReaderUiState.fullPage);

  void toggleHud() {
    if (state == ReaderUiState.fullPage) {
      state = ReaderUiState.overlayHud;
    } else if (state == ReaderUiState.overlayHud) {
      state = ReaderUiState.fullPage;
    }
  }

  void toggleAudioMode() {
    if (state == ReaderUiState.audioMode) {
      state = ReaderUiState.fullPage;
    } else {
      state = ReaderUiState.audioMode;
    }
  }

  void setAudioMode() => state = ReaderUiState.audioMode;
  void setFullPage() => state = ReaderUiState.fullPage;
  void setOverlayHud() => state = ReaderUiState.overlayHud;
}

final readerUiStateProvider =
    StateNotifierProvider.autoDispose<ReaderUiStateNotifier, ReaderUiState>(
  (ref) => ReaderUiStateNotifier(),
);
