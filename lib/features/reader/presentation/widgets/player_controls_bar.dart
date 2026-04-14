import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/core/constants/app_colors.dart';
import 'package:pdf_audio_reader/core/constants/app_dimensions.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/reader_provider.dart';

class PlayerControlsBar extends ConsumerWidget {
  const PlayerControlsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(readerProvider);
    final isPlaying = state.isPlaying;
    final doc = state.document;
    final pageIndex = state.position.pageIndex;
    final pageCount = doc?.pageCount ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.lg,
        vertical: AppDimensions.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        border: const Border(top: BorderSide(color: Color(0xFF2A2A4A))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Page scrubber
          if (pageCount > 1) ...[
            Row(
              children: [
                Text(
                  'Page ${pageIndex + 1}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: pageIndex.toDouble(),
                    min: 0,
                    max: (pageCount - 1).toDouble(),
                    divisions: pageCount - 1,
                    onChanged: (v) => ref
                        .read(readerProvider.notifier)
                        .skipToPage(v.round()),
                  ),
                ),
                Text(
                  'of $pageCount',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Skip previous page
              _ControlButton(
                icon: Icons.skip_previous_rounded,
                onPressed: pageIndex > 0
                    ? () => ref
                        .read(readerProvider.notifier)
                        .skipToPage(pageIndex - 1)
                    : null,
              ),
              const SizedBox(width: AppDimensions.lg),

              // Play / Pause (big central button)
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
                  width: 64,
                  height: 64,
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
                    isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(width: AppDimensions.lg),
              // Skip next page
              _ControlButton(
                icon: Icons.skip_next_rounded,
                onPressed: pageCount > 0 && pageIndex < pageCount - 1
                    ? () => ref
                        .read(readerProvider.notifier)
                        .skipToPage(pageIndex + 1)
                    : null,
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
