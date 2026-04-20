import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pdf_audio_reader/core/constants/app_colors.dart';
import 'package:pdf_audio_reader/core/constants/app_dimensions.dart';
import 'package:pdf_audio_reader/core/constants/app_text_styles.dart';
import 'package:pdf_audio_reader/core/localization/app_localizations.dart';
import 'package:pdf_audio_reader/core/widgets/app_error_widget.dart';
import 'package:pdf_audio_reader/core/widgets/app_loading.dart';
import 'package:pdf_audio_reader/core/widgets/gradient_scaffold.dart';
import 'package:pdf_audio_reader/features/pdf_library/presentation/pages/library_page.dart';
import 'package:pdf_audio_reader/features/pdf_library/presentation/providers/pdf_library_provider.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/tts_config.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/text_search_models.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/reader_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/search_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/tts_config_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/ui_state_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/widgets/highlighted_text_view.dart';
import 'package:pdf_audio_reader/features/reader/presentation/widgets/pdf_highlight_overlay.dart';
import 'package:pdf_audio_reader/features/reader/presentation/widgets/player_controls_bar.dart';
import 'package:pdf_audio_reader/features/reader/presentation/widgets/reader_app_bar.dart';
import 'package:pdf_audio_reader/features/reader/presentation/widgets/search_highlighted_text_view.dart';
import 'package:pdf_audio_reader/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:pdf_audio_reader/services/in_app_review_service.dart';


class ReaderPage extends ConsumerStatefulWidget {
  final ReaderPageParams params;
  const ReaderPage({
    super.key,
    required this.params,
  });

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  final _pageController = PageController();
  late final ReaderNotifier _readerNotifier;
  late final InAppReviewService _inAppReviewService;
  int? _pendingPageIndex;
  ProviderSubscription<ReaderState>? _readerSub;
  late String _pdfId;

  @override
  void initState() {
    super.initState();
    _readerNotifier = ref.read(readerProvider.notifier);
    _inAppReviewService = ref.read(inAppReviewServiceProvider);

    _pdfId = widget.params.pdfId;

    _readerSub =
        ref.listenManual<ReaderState>(readerProvider, (previous, next) {
      if (previous?.position.pageIndex != next.position.pageIndex) {
        _syncPageController(next.position.pageIndex);
      }
    });

    // Open PDF after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _readerNotifier.openPdf(
          pdfId: _pdfId,
          initialReaderMode: widget.params.initialReaderMode,
        );
      }
    });
  }

  @override
  void dispose() {
    // Save progress on close
    _readerNotifier.saveProgress();
    _readerNotifier.stop();
    _readerSub?.close();
    _pageController.dispose();
    
    // Check and show in-app review if eligible
    _inAppReviewService.maybeShowReview();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(readerProvider);
    final isPremium = ref.watch(subscriptionProvider).isPremium;
    final uiState = ref.watch(readerUiStateProvider);
    final searchState = ref.watch(readerSearchProvider);

    return GradientScaffold(
      body: Stack(
        children: [
          // Main content
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (uiState == ReaderUiState.audioMode) {
                  ref.read(readerUiStateProvider.notifier).toggleAudioMode();
                } else {
                  ref.read(readerUiStateProvider.notifier).toggleHud();
                }
              },
              child: state.isLoading
                  ? AppLoading(message: l10n.openingPdf)
                  : state.error != null
                      ? AppErrorWidget(
                          message: state.error!,
                          onRetry: () =>
                              ref.read(readerProvider.notifier).openPdf(
                                    pdfId: _pdfId,
                                    initialReaderMode:
                                        widget.params.initialReaderMode,
                                  ),
                        )
                      : _buildReaderContent(
                          state, isPremium, l10n, searchState),
            ),
          ),

          // Top AppBar Overlay
          if (state.content != null)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ReaderAppBar(),
            ),

          // Bottom Controls Overlay
          if (state.content != null)
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: PlayerControlsBar(),
            ),
        ],
      ),
    );
  }

  Widget _buildReaderContent(
    ReaderState state,
    bool isPremium,
    AppLocalizations l10n,
    ReaderSearchState searchState,
  ) {
    final content = state.content;
    if (content == null) return const SizedBox.shrink();

    final pageIndex = state.position.pageIndex;
    final ttsConfig = ref.watch(ttsConfigProvider);

    if (content.isPdf && state.renderMode == ReaderMode.originalPdf) {
      final library = ref.watch(pdfLibraryProvider).valueOrNull ?? [];
      final docInfo = library.firstWhere((d) => d.id == _pdfId);

      return PdfHighlightOverlay(
        filePath: docInfo.filePath,
        currentPageIndex: pageIndex,
        onPageChanged: (index) {
          if (index != pageIndex) {
            ref.read(readerProvider.notifier).skipToPage(index);
          }
        },
        scrollDirection: ttsConfig.scrollDirection,
        pageElements: content.pageElements(pageIndex),
        activeSearchMatch: searchState.currentMatch?.pageIndex == pageIndex
            ? searchState.currentMatch
            : null,
      );
    }

    return _buildTextReaderContent(
      content.pageCount,
      content.toPageTexts(),
      ttsConfig,
      pageIndex,
      l10n,
      searchState,
    );
  }

  void _syncPageController(int pageIndex) {
    if (_pageController.hasClients) {
      final currentPage =
          _pageController.page?.round() ?? _pageController.initialPage;
      if (currentPage != pageIndex) {
        _pageController.jumpToPage(pageIndex);
      }
    } else {
      _pendingPageIndex = pageIndex;
    }
  }

  void _flushPendingPage() {
    final pending = _pendingPageIndex;
    if (pending == null || !_pageController.hasClients) return;
    _pageController.jumpToPage(pending);
    _pendingPageIndex = null;
  }

  Widget _buildTextReaderContent(
    int pageCount,
    List<String> pageTexts,
    TtsConfig ttsConfig,
    int currentPageIndex,
    AppLocalizations l10n,
    ReaderSearchState searchState,
  ) {
    final mediaPadding = MediaQuery.of(context).padding;
    final topPadding = mediaPadding.top + AppDimensions.md;
    final bottomPadding = mediaPadding.bottom + AppDimensions.md;
    final contentPadding = EdgeInsets.fromLTRB(
      AppDimensions.pagePadding,
      topPadding,
      AppDimensions.pagePadding,
      bottomPadding,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _flushPendingPage();
      }
    });

    return PageView.builder(
      controller: _pageController,
      scrollDirection: ttsConfig.scrollDirection,
      itemCount: pageCount,
      onPageChanged: (index) {
        if (index != currentPageIndex) {
          ref.read(readerProvider.notifier).skipToPage(index);
        }
      },
      itemBuilder: (context, index) {
        return SingleChildScrollView(
          padding: contentPadding,
          child: _buildPageContent(
            pageIndex: index,
            pageCount: pageCount,
            pageText: pageTexts[index],
            isActive: index == currentPageIndex,
            l10n: l10n,
            searchState: searchState,
          ),
        );
      },
    );
  }

  Widget _buildPageContent({
    required int pageIndex,
    required int pageCount,
    required String pageText,
    required bool isActive,
    required AppLocalizations l10n,
    required ReaderSearchState searchState,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                l10n.pageOf(pageIndex + 1, pageCount),
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
        _buildPageText(
          pageText: pageText,
          pageIndex: pageIndex,
          isActive: isActive,
          l10n: l10n,
          searchState: searchState,
        ),
        const SizedBox(height: AppDimensions.xl),
      ],
    );
  }

  Widget _buildPageText({
    required String pageText,
    required int pageIndex,
    required bool isActive,
    required AppLocalizations l10n,
    required ReaderSearchState searchState,
  }) {
    if (pageText.isEmpty) {
      return Text(l10n.noTextOnThisPage, style: AppTextStyles.bodyMedium);
    }

    final pageMatches = searchState.matches
        .where((match) => match.pageIndex == pageIndex)
        .toList(growable: false);
    final TextMatch? activePageMatch =
        searchState.currentMatch?.pageIndex == pageIndex
            ? searchState.currentMatch
            : null;

    if (pageMatches.isNotEmpty) {
      return SearchHighlightedTextView(
        pageText: pageText,
        matches: pageMatches,
        activeMatch: activePageMatch,
      );
    }

    if (isActive) {
      return HighlightedTextView(pageText: pageText);
    }
    return Text(pageText, style: AppTextStyles.readerBody);
  }
}
