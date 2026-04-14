import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/core/constants/app_colors.dart';
import 'package:pdf_audio_reader/core/constants/app_dimensions.dart';
import 'package:pdf_audio_reader/core/constants/app_text_styles.dart';
import 'package:pdf_audio_reader/core/widgets/gradient_scaffold.dart';
import 'package:pdf_audio_reader/features/auth/presentation/providers/auth_provider.dart';
import 'package:pdf_audio_reader/features/auth/presentation/widgets/google_sign_in_button.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authNotifierProvider);

    return GradientScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.pagePadding),
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Logo / Brand
              _buildBrandSection(),
              const Spacer(flex: 2),
              // Sign-in card
              _buildAuthCard(context, ref, authAsync),
              const Spacer(),
              // Guest mode
              TextButton(
                onPressed: () => ref.read(authNotifierProvider.notifier).signInAnonymously(),
                child: Text(
                  'Continue without account',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandSection() {
    return Column(
      children: [
        // Animated logo container
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(80),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.menu_book_rounded,
            size: 44,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppDimensions.lg),
        const Text('PDF Readcloud', style: AppTextStyles.displayMedium),
        const SizedBox(height: AppDimensions.sm),
        Text(
          'Listen to your PDFs with\nreal-time word highlighting',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthCard(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<void> authAsync,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        border: Border.all(color: const Color(0xFF3A3A5C)),
      ),
      child: Column(
        children: [
          const Text('Get started', style: AppTextStyles.h2),
          const SizedBox(height: AppDimensions.xs),
          Text(
            'Sign in to sync your library across devices',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.lg),
          if (authAsync.isLoading)
            const CircularProgressIndicator(color: AppColors.primary)
          else
            GoogleSignInButton(
              onPressed: () async {
                final error = await ref
                    .read(authNotifierProvider.notifier)
                    .signInWithGoogle();
                if (error != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error)),
                  );
                }
              },
            ),
          if (authAsync.hasError) ...[
            const SizedBox(height: AppDimensions.sm),
            Text(
              authAsync.error.toString(),
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
