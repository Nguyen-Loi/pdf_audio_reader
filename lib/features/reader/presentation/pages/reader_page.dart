import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf_audio_reader/core/constants/app_colors.dart';
import 'package:pdf_audio_reader/core/constants/app_dimensions.dart';
import 'package:pdf_audio_reader/core/constants/app_text_styles.dart';
import 'package:pdf_audio_reader/core/router/route_names.dart';
import 'package:pdf_audio_reader/core/widgets/app_error_widget.dart';
import 'package:pdf_audio_reader/core/widgets/app_loading.dart';
import 'package:pdf_audio_reader/core/widgets/gradient_scaffold.dart';
import 'package:pdf_audio_reader/features/pdf_library/presentation/providers/pdf_library_provider.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/tts_config.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/reader_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/tts_config_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/widgets/highlighted_text_view.dart';
import 'package:pdf_audio_reader/features/reader/presentation/widgets/pdf_highlight_overlay.dart';
import 'package:pdf_audio_reader/features/reader/presentation/widgets/player_controls_bar.dart';
import 'package:pdf_audio_reader/features/reader/presentation/widgets/speed_selector.dart';
import 'package:pdf_audio_reader/features/subscription/presentation/providers/subscription_provider.dart';

class ReaderPage extends ConsumerStatefulWidget {
  final String pdfId;
  const ReaderPage({super.key, required this.pdfId});

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  final _scrollController = ScrollController();
  late final ReaderNotifier _readerNotifier;

  @override
  void initState() {
    super.initState();
    _readerNotifier = ref.read(readerProvider.notifier);
    
    // Open PDF after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _readerNotifier.openPdf(pdfId: widget.pdfId);
      }
    });
  }

  @override
  void dispose() {
    // Save progress on close
    _readerNotifier.saveProgress();
    _readerNotifier.stop();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(readerProvider);
    final isPremium = ref.watch(subscriptionProvider).isPremium;

    return GradientScaffold(
      appBar: _buildAppBar(context, state, isPremium),
      body: state.isLoading
          ? const AppLoading(message: 'Opening PDF…')
          : state.error != null
              ? AppErrorWidget(
                  message: state.error!,
                  onRetry: () => ref
                      .read(readerProvider.notifier)
                      .openPdf(pdfId: widget.pdfId),
                )
              : _buildReaderContent(state, isPremium),
      bottomNavigationBar:
          state.document != null ? const PlayerControlsBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ReaderState state,
    bool isPremium,
  ) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        color: AppColors.textSecondary,
        onPressed: () => context.pop(),
      ),
      title: Text(
        state.document?.title ?? 'Reader',
        style: AppTextStyles.h3,
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        const SpeedSelector(),
        const SizedBox(width: 8),
        // Background play lock icon
        if (!isPremium)
          IconButton(
            icon: const Icon(Icons.lock_outlined, size: 20),
            color: AppColors.accent,
            tooltip: 'Background play (Premium)',
            onPressed: () => context.push(RouteNames.paywall),
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildReaderContent(ReaderState state, bool isPremium) {
    final doc = state.document;
    if (doc == null) return const SizedBox.shrink();

    final pageIndex = state.position.pageIndex;
    final page = doc.pages[pageIndex];
    final readerMode = ref.watch(ttsConfigProvider).readerMode;

    if (readerMode == ReaderMode.originalPdf) {
      final library = ref.watch(pdfLibraryProvider).valueOrNull ?? [];
      final docInfo = library.firstWhere((d) => d.id == widget.pdfId);

      return PdfHighlightOverlay(
        filePath: docInfo.filePath,
        currentPageIndex: pageIndex,
      );
    }

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.pagePadding,
        AppDimensions.md,
        AppDimensions.pagePadding,
        AppDimensions.xxxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page indicator
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.sm,
                  vertical: AppDimensions.xs,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                ),
                child: Text(
                  'Page ${pageIndex + 1} / ${doc.pageCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.lg),

          // Karaoke text
          HighlightedTextView(pageText: page.text),
          const SizedBox(height: AppDimensions.xl),
        ],
      ),
    );
  }
}
