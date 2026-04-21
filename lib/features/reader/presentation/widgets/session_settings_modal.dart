import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/core/constants/app_colors.dart';
import 'package:pdf_audio_reader/core/constants/app_dimensions.dart';
import 'package:pdf_audio_reader/core/constants/app_text_styles.dart';
import 'package:pdf_audio_reader/core/localization/app_localizations.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/tts_config_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/reader_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/widgets/voice_selector_sheet.dart';

import 'package:pdf_audio_reader/features/reader/domain/entities/tts_config.dart';

class SessionSettingsModal extends ConsumerStatefulWidget {
  const SessionSettingsModal({super.key});

  @override
  ConsumerState<SessionSettingsModal> createState() => _SessionSettingsModalState();
}

class _SessionSettingsModalState extends ConsumerState<SessionSettingsModal> {
  late TtsConfig _localConfig;

  @override
  void initState() {
    super.initState();
    _localConfig = ref.read(ttsConfigProvider);
  }

  bool get _hasChanges {
    final current = ref.watch(ttsConfigProvider);
    return _localConfig.speed != current.speed ||
           _localConfig.scrollDirection != current.scrollDirection ||
           _localConfig.voice?['name'] != current.voice?['name'] ||
           _localConfig.voice?['locale'] != current.voice?['locale'];
  }

  Future<void> _applyChanges() async {
    final readerNotifier = ref.read(readerProvider.notifier);
    final isPlaying = ref.read(readerProvider).isPlaying;

    if (isPlaying) {
      await readerNotifier.pause();
    }

    ref.read(ttsConfigProvider.notifier).setSpeed(_localConfig.speed);
    ref.read(ttsConfigProvider.notifier).setScrollDirection(_localConfig.scrollDirection);
    ref.read(ttsConfigProvider.notifier).setVoice(_localConfig.voice);

    await readerNotifier.applyConfig(_localConfig);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
                Text(l10n.sessionSettings, style: AppTextStyles.h3),
                TextButton(
                  onPressed: () {
                    final globalConfig = ref.read(globalTtsConfigProvider);
                    setState(() {
                      _localConfig = _localConfig.copyWith(
                        speed: globalConfig.speed,
                        voice: globalConfig.voice,
                        scrollDirection: globalConfig.scrollDirection,
                      );
                    });
                  },
                  child: Text(l10n.reset,
                      style: const TextStyle(color: AppColors.accent)),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.lg),
            Text(l10n.speechSpeed, style: AppTextStyles.labelSmall),
            Row(
              children: [
                const Icon(Icons.speed,
                    color: AppColors.textSecondary, size: 20),
                Expanded(
                  child: Slider(
                    value: _localConfig.speed,
                    min: 0.5,
                    max: 3.0,
                    divisions: 10,
                    label: '${_localConfig.speed.toStringAsFixed(1)}x',
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.bgSurface,
                    onChanged: (val) {
                      setState(() {
                        _localConfig = _localConfig.copyWith(speed: val);
                      });
                    },
                  ),
                ),
                Text('${_localConfig.speed.toStringAsFixed(1)}x',
                    style: AppTextStyles.bodyMedium),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Text(l10n.voice, style: AppTextStyles.labelSmall),
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: ListTile(
                title: Text(
                  _localConfig.voice?['name']?.toString() ??
                      l10n.systemDefault,
                  style: AppTextStyles.bodyMedium,
                ),
                subtitle: Text(
                  _localConfig.voice?['locale']?.toString() ??
                      l10n.autoDetectedByContent,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary),
                onTap: () async {
                  final voice = await showModalBottomSheet<Map<String, dynamic>>(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => const VoiceSelectorSheet(),
                  );
                  if (voice != null && mounted) {
                    setState(() {
                      _localConfig = _localConfig.copyWith(voice: voice);
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            Text(l10n.scrollDirection, style: AppTextStyles.labelSmall),
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
                  value: _localConfig.scrollDirection,
                  dropdownColor: AppColors.bgCard,
                  items: [
                    DropdownMenuItem(
                      value: Axis.vertical,
                      child:
                          Text(l10n.vertical, style: AppTextStyles.bodyMedium),
                    ),
                    DropdownMenuItem(
                      value: Axis.horizontal,
                      child: Text(l10n.horizontal,
                          style: AppTextStyles.bodyMedium),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _localConfig = _localConfig.copyWith(scrollDirection: val);
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _hasChanges ? _applyChanges : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasChanges ? AppColors.primary : AppColors.bgSurface,
                  foregroundColor: _hasChanges ? Colors.black : AppColors.textSecondary,
                  disabledBackgroundColor: AppColors.bgSurface,
                  disabledForegroundColor: AppColors.textSecondary.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(vertical: AppDimensions.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                ),
                child: Text(
                  l10n.apply,
                  style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
