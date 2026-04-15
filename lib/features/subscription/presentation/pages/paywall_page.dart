import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf_audio_reader/core/constants/app_colors.dart';
import 'package:pdf_audio_reader/core/constants/app_dimensions.dart';
import 'package:pdf_audio_reader/core/constants/app_text_styles.dart';
import 'package:pdf_audio_reader/core/localization/app_localizations.dart';
import 'package:pdf_audio_reader/features/auth/presentation/providers/auth_provider.dart';
import 'package:pdf_audio_reader/core/widgets/gradient_scaffold.dart';
import 'package:pdf_audio_reader/features/subscription/presentation/providers/subscription_provider.dart';

class PaywallPage extends ConsumerStatefulWidget {
  const PaywallPage({super.key});

  @override
  ConsumerState<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends ConsumerState<PaywallPage> {
  bool _purchaseInProgress = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sub = ref.watch(subscriptionProvider);

    if (sub.isPremium) {
      // Already premium — auto-close
      WidgetsBinding.instance.addPostFrameCallback((_) => context.pop());
      return const SizedBox.shrink();
    }

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          color: AppColors.textSecondary,
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.pagePadding),
          child: Column(
            children: [
              const Spacer(),
              // Crown icon
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(80),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
              Text(l10n.goPremium, style: AppTextStyles.displayMedium),
              const SizedBox(height: AppDimensions.sm),
              Text(
                '${l10n.unlockBackgroundAudioPlayback}\n${l10n.keepReadingWhileScreenIsOff}',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.xl),

              // Feature list
              ..._features(l10n)
                  .map((f) => _FeatureRow(icon: f.$1, label: f.$2)),

              const Spacer(),

              // Price / CTA
              if (sub.isLoading)
                const CircularProgressIndicator(color: AppColors.primary)
              else ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _purchaseInProgress
                        ? null
                        : () => _handleUnlockPremium(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(18),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                    ),
                    child: Text(
                      l10n.unlockPremium,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                TextButton(
                  onPressed: () =>
                      ref.read(subscriptionProvider.notifier).restore(),
                  child: Text(
                    l10n.restorePurchase,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],

              if (sub.error != null) ...[
                const SizedBox(height: AppDimensions.sm),
                Text(
                  sub.error!,
                  style:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: AppDimensions.lg),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleUnlockPremium(BuildContext context) async {
    final user = ref.read(currentUserProvider);

    if (user == null) {
      final shouldSignIn = await _showLoginRequiredDialog(context);
      if (!shouldSignIn || !mounted) return;

      final error =
          await ref.read(authNotifierProvider.notifier).signInWithGoogle();
      if (error != null) {
        final isCancelled = error.toLowerCase().contains('cancel');
        if (!isCancelled && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
        return;
      }
    }

    if (!mounted) return;
    setState(() => _purchaseInProgress = true);
    try {
      await ref.read(subscriptionProvider.notifier).purchasePremium();
    } finally {
      if (mounted) {
        setState(() => _purchaseInProgress = false);
      }
    }
  }

  Future<bool> _showLoginRequiredDialog(BuildContext context) async {
    final choice = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Google Sign-In Required'),
        content: const Text('Please sign in with Google to continue'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign in with Google'),
          ),
        ],
      ),
    );

    return choice ?? false;
  }

  List<(IconData, String)> _features(AppLocalizations l10n) => [
        (Icons.volume_up_rounded, l10n.keepReadingWhileScreenIsOff),
        (Icons.music_note_rounded, l10n.lockScreenAndNotificationControls),
        (Icons.cloud_done_outlined, l10n.allFuturePremiumFeatures),
      ];
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppDimensions.md),
          Text(label, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
