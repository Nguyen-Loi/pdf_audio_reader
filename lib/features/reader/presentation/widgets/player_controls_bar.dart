import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/core/constants/app_colors.dart';
import 'package:pdf_audio_reader/core/constants/app_dimensions.dart';
import 'package:pdf_audio_reader/core/constants/app_text_styles.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/reader_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/ui_state_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/widgets/session_settings_modal.dart';

class PlayerControlsBar extends ConsumerWidget {
  const PlayerControlsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(readerUiStateProvider);

    return AnimatedSlide(
      offset:
          uiState == ReaderUiState.fullPage ? const Offset(0, 1) : Offset.zero,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: uiState == ReaderUiState.fullPage ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgDark.withAlpha(242), // 0.95 equivalent
            border: const Border(top: BorderSide(color: Color(0xFF2A2A4A))),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(80),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: uiState == ReaderUiState.audioMode
                    ? const _AudioHub(key: ValueKey('audioHub'))
                    : const _StandardBottomBar(key: ValueKey('standardBar')),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StandardBottomBar extends ConsumerWidget {
  const _StandardBottomBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readerProvider);
    final title = state.document?.title ?? 'Unknown Document';
    final pageIndex = state.position.pageIndex;
    final pageCount = state.document?.pageCount ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: AppTextStyles.labelLarge,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          if (pageCount > 1)
            Row(
              children: [
                Text(
                  '${pageIndex + 1}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                Expanded(
                  child: Slider(
                    value: pageIndex.toDouble(),
                    min: 0,
                    max: (pageCount - 1 > 0 ? pageCount - 1 : 1).toDouble(),
                    divisions: pageCount - 1 > 0 ? pageCount - 1 : 1,
                    onChanged: (v) =>
                        ref.read(readerProvider.notifier).skipToPage(v.round()),
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.bgSurface,
                  ),
                ),
                Text(
                  '$pageCount',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AudioHub extends ConsumerWidget {
  const _AudioHub({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readerProvider);
    final isPlaying = state.isPlaying;

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlButton(
                icon: Icons.skip_previous_rounded,
                onPressed: state.position.pageIndex > 0
                    ? () => ref
                        .read(readerProvider.notifier)
                        .skipToPage(state.position.pageIndex - 1)
                    : null,
              ),
              const SizedBox(width: AppDimensions.xl),
              GestureDetector(
                onTap: () {
                  if (isPlaying) {
                    ref.read(readerProvider.notifier).pause();
                  } else {
                    ref.read(readerProvider.notifier).play();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(80),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.xl),
              _ControlButton(
                icon: Icons.skip_next_rounded,
                onPressed: (state.document?.pageCount ?? 0) > 0 &&
                        state.position.pageIndex <
                            (state.document?.pageCount ?? 1) - 1
                    ? () => ref
                        .read(readerProvider.notifier)
                        .skipToPage(state.position.pageIndex + 1)
                    : null,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  ref.read(readerProvider.notifier).pause();
                  ref.read(readerUiStateProvider.notifier).setFullPage();
                },
                icon: const Icon(Icons.close,
                    color: AppColors.textSecondary, size: 20),
                label: const Text('Cancel',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              const SizedBox(width: AppDimensions.xxxl),
              TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => const SessionSettingsModal(),
                  );
                },
                icon:
                    const Icon(Icons.tune, color: AppColors.primary, size: 20),
                label: const Text('Settings',
                    style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _ControlButton({required this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: AppDimensions.iconLg),
      color: onPressed != null ? AppColors.textPrimary : AppColors.textDisabled,
    );
  }
}
