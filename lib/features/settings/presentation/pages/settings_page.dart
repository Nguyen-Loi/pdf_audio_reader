import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf_audio_reader/core/constants/app_colors.dart';
import 'package:pdf_audio_reader/core/constants/app_dimensions.dart';
import 'package:pdf_audio_reader/core/constants/app_text_styles.dart';
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
    final user = ref.watch(currentUserProvider);
    final config = ref.watch(globalTtsConfigProvider);
    final isPremium = ref.watch(subscriptionProvider).isPremium;

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Settings', style: AppTextStyles.h2),
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
          const _SectionHeader('Account'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: user?.name ?? 'Guest',
            subtitle: user?.email ?? 'Not signed in',
            trailing: user != null
                ? TextButton(
                    onPressed: () =>
                        ref.read(authNotifierProvider.notifier).signOut(),
                    child: const Text('Sign out',
                        style: TextStyle(color: AppColors.error)),
                  )
                : TextButton(
                    onPressed: () => context.go(RouteNames.login),
                    child: const Text('Sign in'),
                  ),
          ),

          const SizedBox(height: AppDimensions.lg),

          // Subscription section
          const _SectionHeader('Subscription'),
          _SettingsTile(
            icon: Icons.workspace_premium_outlined,
            title: isPremium ? 'Premium Active ✓' : 'Upgrade to Premium',
            subtitle: isPremium
                ? 'Background playback enabled'
                : 'Unlock background audio playback',
            trailing: !isPremium
                ? const Icon(Icons.chevron_right, color: AppColors.accent)
                : null,
            onTap: !isPremium
                ? () => context.push(RouteNames.paywall)
                : null,
            tileColor: AppColors.accent.withAlpha(20),
          ),

          const SizedBox(height: AppDimensions.lg),

          const _SectionHeader('View Options'),
          _SettingsTile(
            icon: Icons.auto_stories,
            title: 'Reader Mode',
            trailing: DropdownButton<ReaderMode>(
              value: config.readerMode,
              dropdownColor: AppColors.bgCard,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: ReaderMode.textOnly,
                  child: Text('Plain Text', style: AppTextStyles.bodyMedium),
                ),
                DropdownMenuItem(
                  value: ReaderMode.originalPdf,
                  child: Text('Original PDF', style: AppTextStyles.bodyMedium),
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
            title: 'Scroll Direction',
            trailing: DropdownButton<Axis>(
              value: config.scrollDirection,
              dropdownColor: AppColors.bgCard,
              underline: const SizedBox(),
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
                  ref.read(globalTtsConfigProvider.notifier).setScrollDirection(val);
                }
              },
            ),
          ),

          const SizedBox(height: AppDimensions.lg),

          // TTS settings
          const _SectionHeader('Text-to-Speech'),
          _SettingsTile(
            icon: Icons.speed_outlined,
            title: 'Playback Speed',
            subtitle: '${config.speed}x',
            trailing: const Icon(Icons.chevron_right,
                color: AppColors.textSecondary),
          ),
          _SettingsTile(
            icon: Icons.language_outlined,
            title: 'Language',
            trailing: DropdownButton<String>(
              value: config.language,
              dropdownColor: AppColors.bgCard,
              underline: const SizedBox(),
              items: _buildLanguageItems(config.language),
              onChanged: (val) {
                if (val != null) {
                  ref.read(globalTtsConfigProvider.notifier).setLanguage(val);
                }
              },
            ),
          ),

          const SizedBox(height: AppDimensions.lg),
          const _SectionHeader('About'),
          const _SettingsTile(
            icon: Icons.info_outline,
            title: 'PDF Readcloud',
            subtitle: 'Version 1.0.0',
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
