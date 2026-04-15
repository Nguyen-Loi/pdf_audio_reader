import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/core/constants/app_colors.dart';
import 'package:pdf_audio_reader/core/constants/app_dimensions.dart';
import 'package:pdf_audio_reader/core/constants/app_text_styles.dart';
import 'package:pdf_audio_reader/core/localization/app_localizations.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/tts_config_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/reader_provider.dart';

class SpeedSelector extends ConsumerWidget {
  const SpeedSelector({super.key});

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(ttsConfigProvider);

    return GestureDetector(
      onTap: () => _showSpeedSheet(context, ref, config.speed),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.sm + 2,
          vertical: AppDimensions.xs + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border: Border.all(color: const Color(0xFF3A3A5C)),
        ),
        child: Text(
          '${config.speed}x',
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }

  void _showSpeedSheet(BuildContext context, WidgetRef ref, double current) {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppDimensions.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.playbackSpeed, style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.lg),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppDimensions.sm,
              runSpacing: AppDimensions.sm,
              children: _speeds.map((s) {
                final selected = s == current;
                return GestureDetector(
                  onTap: () {
                    final newConfig =
                        ref.read(ttsConfigProvider).copyWith(speed: s);
                    ref.read(ttsConfigProvider.notifier).setSpeed(s);
                    ref.read(readerProvider.notifier).applyConfig(newConfig);
                    Navigator.of(context).pop();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.bgCard,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : const Color(0xFF3A3A5C),
                      ),
                    ),
                    child: Text(
                      '${s}x',
                      style: AppTextStyles.labelLarge.copyWith(
                        color:
                            selected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.lg),
          ],
        ),
      ),
    );
  }
}
