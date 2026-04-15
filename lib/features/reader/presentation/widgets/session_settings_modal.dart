import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/core/constants/app_colors.dart';
import 'package:pdf_audio_reader/core/constants/app_dimensions.dart';
import 'package:pdf_audio_reader/core/constants/app_text_styles.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/tts_config_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/widgets/voice_selector_sheet.dart';

class SessionSettingsModal extends ConsumerWidget {
  const SessionSettingsModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionConfig = ref.watch(ttsConfigProvider);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.pagePadding),
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXl)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary.withAlpha(128),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Session Settings', style: AppTextStyles.h3),
                TextButton(
                  onPressed: () {
                    final globalConfig = ref.read(globalTtsConfigProvider);
                    ref
                        .read(ttsConfigProvider.notifier)
                        .setSpeed(globalConfig.speed);
                    ref
                        .read(ttsConfigProvider.notifier)
                        .setLanguage(globalConfig.language);
                    ref
                        .read(ttsConfigProvider.notifier)
                        .setVoice(globalConfig.voice);
                    ref
                        .read(ttsConfigProvider.notifier)
                        .setScrollDirection(globalConfig.scrollDirection);
                  },
                  child: const Text('Reset',
                      style: TextStyle(color: AppColors.accent)),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
            const Text('Speech Speed', style: AppTextStyles.labelSmall),
            Row(
              children: [
                const Icon(Icons.speed,
                    color: AppColors.textSecondary, size: 20),
                Expanded(
                  child: Slider(
                    value: sessionConfig.speed,
                    min: 0.5,
                    max: 3.0,
                    divisions: 10,
                    label: '${sessionConfig.speed.toStringAsFixed(1)}x',
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.bgSurface,
                    onChanged: (val) {
                      ref.read(ttsConfigProvider.notifier).setSpeed(val);
                    },
                  ),
                ),
                Text('${sessionConfig.speed.toStringAsFixed(1)}x',
                    style: AppTextStyles.bodyMedium),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            const Text('Language', style: AppTextStyles.labelSmall),
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: sessionConfig.language,
                  dropdownColor: AppColors.bgCard,
                  items: _buildLanguageItems(sessionConfig.language),
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(ttsConfigProvider.notifier).setLanguage(val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            const Text('Voice', style: AppTextStyles.labelSmall),
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: ListTile(
                title: Text(
                  sessionConfig.voice?['name']?.toString() ?? 'System Default',
                  style: AppTextStyles.bodyMedium,
                ),
                subtitle: Text(
                  sessionConfig.voice?['locale']?.toString() ??
                      sessionConfig.language,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => const VoiceSelectorSheet(),
                  );
                },
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            const Text('Scroll Direction', style: AppTextStyles.labelSmall),
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Axis>(
                  isExpanded: true,
                  value: sessionConfig.scrollDirection,
                  dropdownColor: AppColors.bgCard,
                  items: const [
                    DropdownMenuItem(
                      value: Axis.vertical,
                      child: Text('Vertical', style: AppTextStyles.bodyMedium),
                    ),
                    DropdownMenuItem(
                      value: Axis.horizontal,
                      child: Text('Horizontal', style: AppTextStyles.bodyMedium),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref
                          .read(ttsConfigProvider.notifier)
                          .setScrollDirection(val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
          ],
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildLanguageItems(String current) {
    final items = <String, String>{
      'en-US': 'English',
      'vi-VN': 'Vietnamese',
    };

    if (!items.containsKey(current)) {
      items[current] = current;
    }

    return items.entries
        .map(
          (entry) => DropdownMenuItem(
            value: entry.key,
            child: Text(entry.value, style: AppTextStyles.bodyMedium),
          ),
        )
        .toList();
  }
}
