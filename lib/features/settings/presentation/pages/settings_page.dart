import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf_audio_reader/core/constants/app_colors.dart';
import 'package:pdf_audio_reader/core/constants/app_dimensions.dart';
import 'package:pdf_audio_reader/core/constants/app_text_styles.dart';
import 'package:pdf_audio_reader/core/localization/app_localizations.dart';
import 'package:pdf_audio_reader/core/providers/locale_provider.dart';
import 'package:pdf_audio_reader/core/router/route_names.dart';
import 'package:pdf_audio_reader/core/widgets/gradient_scaffold.dart';
import 'package:pdf_audio_reader/features/auth/presentation/providers/auth_provider.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/tts_config.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/tts_config_provider.dart';
import 'package:pdf_audio_reader/features/subscription/presentation/providers/subscription_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final user = ref.watch(currentUserProvider);
    final config = ref.watch(globalTtsConfigProvider);
    final isPremium = ref.watch(subscriptionProvider).isPremium;
    final appLocale = ref.watch(appLocaleProvider);

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(l10n.settings, style: AppTextStyles.h2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.textSecondary,
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        children: [
          // Account section
          _SectionHeader(l10n.account),
          _SettingsTile(
            icon: Icons.person_outline,
            title: user?.name ?? l10n.guest,
            subtitle: user?.email ?? l10n.notSignedIn,
            trailing: user != null
                ? TextButton(
                    onPressed: () =>
                        ref.read(authNotifierProvider.notifier).signOut(),
                    child: Text(l10n.signOut,
                        style: const TextStyle(color: AppColors.error)),
                  )
                : TextButton(
                    onPressed: () => context.go(RouteNames.login),
                    child: Text(l10n.signIn),
                  ),
          ),

          const SizedBox(height: AppDimensions.lg),

          // Subscription section
          _SectionHeader(l10n.subscription),
          _SettingsTile(
            icon: Icons.workspace_premium_outlined,
            title: isPremium ? l10n.premiumActive : l10n.upgradeToPremium,
            subtitle: isPremium
                ? l10n.backgroundPlaybackEnabled
                : l10n.unlockBackgroundAudioPlayback,
            trailing: !isPremium
                ? const Icon(Icons.chevron_right, color: AppColors.accent)
                : null,
            onTap: !isPremium ? () => context.push(RouteNames.paywall) : null,
            tileColor: AppColors.accent.withAlpha(20),
          ),

          const SizedBox(height: AppDimensions.lg),

          _SectionHeader(l10n.viewOptions),
          _SettingsTile(
            icon: Icons.auto_stories,
            title: l10n.readerMode,
            trailing: DropdownButton<ReaderMode>(
              value: config.readerMode,
              dropdownColor: AppColors.bgCard,
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(
                  value: ReaderMode.textOnly,
                  child: Text(l10n.plainText, style: AppTextStyles.bodyMedium),
                ),
                DropdownMenuItem(
                  value: ReaderMode.originalPdf,
                  child:
                      Text(l10n.originalPdf, style: AppTextStyles.bodyMedium),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref.read(globalTtsConfigProvider.notifier).setReaderMode(val);
                }
              },
            ),
          ),
          _SettingsTile(
            icon: Icons.swap_vert,
            title: l10n.scrollDirection,
            trailing: DropdownButton<Axis>(
              value: config.scrollDirection,
              dropdownColor: AppColors.bgCard,
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(
                  value: Axis.vertical,
                  child: Text(l10n.vertical, style: AppTextStyles.bodyMedium),
                ),
                DropdownMenuItem(
                  value: Axis.horizontal,
                  child: Text(l10n.horizontal, style: AppTextStyles.bodyMedium),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref
                      .read(globalTtsConfigProvider.notifier)
                      .setScrollDirection(val);
                }
              },
            ),
          ),

          const SizedBox(height: AppDimensions.lg),

          // TTS settings
          _SectionHeader(l10n.textToSpeech),
          _SettingsTile(
            icon: Icons.speed_outlined,
            title: l10n.playbackSpeed,
            subtitle: '${config.speed}x',
            trailing:
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ),

          const SizedBox(height: AppDimensions.lg),

          _SectionHeader(l10n.about),
          _SettingsTile(
            icon: Icons.translate,
            title: l10n.appLanguage,
            trailing: DropdownButton<Locale>(
              value: appLocale,
              dropdownColor: AppColors.bgCard,
              underline: const SizedBox(),
              items: [
                DropdownMenuItem(
                  value: const Locale('en'),
                  child: Text(l10n.english, style: AppTextStyles.bodyMedium),
                ),
                DropdownMenuItem(
                  value: const Locale('vi'),
                  child: Text(l10n.vietnamese, style: AppTextStyles.bodyMedium),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref.read(appLocaleProvider.notifier).setLocale(val);
                }
              },
            ),
          ),

          _SettingsTile(
            icon: Icons.info_outline,
            title: l10n.appName,
            subtitle: l10n.versionLabel('1.0.0'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? tileColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.tileColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.sm),
      decoration: BoxDecoration(
        color: tileColor ?? AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: const Color(0xFF3A3A5C)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.bodyMedium),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ))
            : null,
        trailing: trailing,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
    );
  }
}
