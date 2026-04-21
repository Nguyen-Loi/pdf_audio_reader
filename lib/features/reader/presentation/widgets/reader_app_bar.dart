import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf_audio_reader/core/constants/app_colors.dart';
import 'package:pdf_audio_reader/core/constants/app_text_styles.dart';
import 'package:pdf_audio_reader/core/localization/app_localizations.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/reader_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/ui_state_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/widgets/reader_search_sheet.dart';
import 'package:pdf_audio_reader/features/reader/presentation/widgets/session_settings_modal.dart';

class ReaderAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ReaderAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final uiState = ref.watch(readerUiStateProvider);

    final isControlsVisible = uiState == ReaderUiState.overlayHud ||
        uiState == ReaderUiState.audioMode;

    return AnimatedSlide(
      offset: isControlsVisible ? Offset.zero : const Offset(0, -1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: isControlsVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !isControlsVisible,
          child: Container(
            color: AppColors.bgDark.withAlpha(242), // ~0.95 opacity
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: AppColors.textSecondary,
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final title =
                          ref.watch(readerProvider.select((s) => s.title));
                      return Text(
                        title ?? l10n.reader,
                        style: AppTextStyles.h3,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  color: AppColors.textSecondary,
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => const ReaderSearchSheet(),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.record_voice_over_outlined),
                  color: uiState == ReaderUiState.audioMode
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  onPressed: () {
                    if (uiState == ReaderUiState.audioMode) {
                      ref.read(readerUiStateProvider.notifier).setOverlayHud();
                      ref.read(readerProvider.notifier).cancelAudio();
                    } else {
                      ref.read(readerUiStateProvider.notifier).setAudioMode();
                      ref.read(readerProvider.notifier).play();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  color: AppColors.textSecondary,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (context) => const SessionSettingsModal(),
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
