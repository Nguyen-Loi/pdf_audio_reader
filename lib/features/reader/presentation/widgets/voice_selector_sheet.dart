import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/core/constants/app_colors.dart';
import 'package:pdf_audio_reader/core/constants/app_dimensions.dart';
import 'package:pdf_audio_reader/core/constants/app_text_styles.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/reader_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/tts_config_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/voice_selector_provider.dart';

class VoiceSelectorSheet extends ConsumerWidget {
  const VoiceSelectorSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detectedLocale =
        ref.watch(readerProvider.select((state) => state.detectedLocale));
    final config = ref.watch(ttsConfigProvider);
    final advanced = ref.watch(voiceSelectorAdvancedProvider);
    final voicesAsync = ref.watch(availableVoicesProvider);
    final filteredVoices = ref.watch(filteredVoicesProvider);

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
                const Text('Voice', style: AppTextStyles.h3),
                Text('Detected: $detectedLocale',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Show all languages',
                    style: AppTextStyles.bodyMedium),
                Switch(
                  value: advanced,
                  onChanged: (value) => ref
                      .read(voiceSelectorAdvancedProvider.notifier)
                      .state = value,
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            voicesAsync.when(
              data: (_) => _VoiceList(
                voices: filteredVoices,
                selectedVoice: config.voice,
                fallbackLocale: detectedLocale,
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppDimensions.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
                child: Text(
                  'Unable to load voices: $err',
                  style:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
          ],
        ),
      ),
    );
  }
}

class _VoiceList extends ConsumerWidget {
  final List<Map<String, dynamic>> voices;
  final Map<String, dynamic>? selectedVoice;
  final String fallbackLocale;

  const _VoiceList({
    required this.voices,
    required this.selectedVoice,
    required this.fallbackLocale,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (voices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.lg),
        child: Text(
          'No voices available for this language.',
          style:
              AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return SizedBox(
      height: 320,
      child: ListView.separated(
        itemCount: voices.length,
        separatorBuilder: (_, __) => const Divider(
          color: Color(0xFF2A2A4A),
          height: 1,
        ),
        itemBuilder: (context, index) {
          final voice = voices[index];
          final voiceName = voice['name']?.toString() ?? 'System Voice';
          final voiceLocale = voice['locale']?.toString() ?? fallbackLocale;
          final isSelected = _isSameVoice(selectedVoice, voice);

          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(voiceName, style: AppTextStyles.bodyMedium),
            subtitle: Text(
              voiceLocale,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: AppColors.primary)
                : const Icon(Icons.circle_outlined,
                    color: AppColors.textSecondary),
            onTap: () {
              final newConfig =
                  ref.read(ttsConfigProvider).copyWith(voice: voice);
              ref.read(readerProvider.notifier).applyConfig(newConfig);
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }

  bool _isSameVoice(
    Map<String, dynamic>? selected,
    Map<String, dynamic> candidate,
  ) {
    if (selected == null) return false;
    final selectedId = selected['name']?.toString();
    final selectedLocale = selected['locale']?.toString();
    return selectedId == candidate['name']?.toString() &&
        selectedLocale == candidate['locale']?.toString();
  }
}
