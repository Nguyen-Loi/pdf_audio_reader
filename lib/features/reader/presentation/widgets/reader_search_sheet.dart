import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/core/constants/app_colors.dart';
import 'package:pdf_audio_reader/core/constants/app_dimensions.dart';
import 'package:pdf_audio_reader/core/constants/app_text_styles.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/text_search_models.dart';
import 'package:pdf_audio_reader/features/reader/presentation/controllers/search_controller.dart'
    as reader_search;
import 'package:pdf_audio_reader/features/reader/presentation/providers/reader_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/search_provider.dart';

class ReaderSearchSheet extends ConsumerStatefulWidget {
  const ReaderSearchSheet({super.key});

  @override
  ConsumerState<ReaderSearchSheet> createState() => _ReaderSearchSheetState();
}

class _ReaderSearchSheetState extends ConsumerState<ReaderSearchSheet> {
  late final reader_search.SearchController _controller;
  final TextEditingController _queryController = TextEditingController();
  bool _syncScheduled = false;

  @override
  void initState() {
    super.initState();
    _controller = reader_search.SearchController();
    _controller.addListener(_onControllerUpdated);

    final content = ref.read(readerProvider).content;
    final searchState = ref.read(readerSearchProvider);
    _queryController.text = searchState.query;

    if (content == null) {
      ref.read(readerSearchProvider.notifier).clear();
      return;
    }

    if (content.isPdf) {
      _controller.setPdfSource(
        content.pages
            .map((page) =>
                PdfPageText(pageIndex: page.pageIndex, text: page.text))
            .toList(growable: false),
        initialQuery: searchState.query,
      );
    } else {
      _controller.setPlainTextSource(
        content.rawText,
        initialQuery: searchState.query,
      );
    }

    if (searchState.currentIndex >= 0 &&
        searchState.currentIndex < _controller.matches.length) {
      _controller.setCurrentIndex(searchState.currentIndex);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncProvider();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdated);
    _controller.dispose();
    _queryController.dispose();
    super.dispose();
  }

  void _onControllerUpdated() {
    if (!mounted) return;
    _syncProvider();
    setState(() {});
  }

  void _syncProvider() {
    if (!mounted || _syncScheduled) return;
    _syncScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (!mounted) return;
      ref.read(readerSearchProvider.notifier).setResults(
            query: _controller.query,
            matches: _controller.matches,
            currentIndex: _controller.currentIndex,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaInsets = MediaQuery.of(context).viewInsets;
    final matches = _controller.matches;
    final current = _controller.currentMatch;
    final currentDisplayIndex =
        _controller.currentIndex >= 0 ? _controller.currentIndex + 1 : 0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppDimensions.md,
          right: AppDimensions.md,
          top: AppDimensions.md,
          bottom: mediaInsets.bottom + AppDimensions.md,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.bgDark,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.textDisabled.withAlpha(120)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _queryController,
                        autofocus: true,
                        textInputAction: TextInputAction.search,
                        onChanged: (value) => _controller.updateQuery(value),
                        onSubmitted: (_) =>
                            _goToMatch(_controller.currentMatch),
                        style: AppTextStyles.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Find in document',
                          hintStyle: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                          isDense: true,
                          filled: true,
                          fillColor: AppColors.bgSurface,
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _queryController.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () {
                                    _queryController.clear();
                                    _controller.updateQuery('',
                                        immediate: true);
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusMd),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_up_rounded),
                      onPressed: matches.isEmpty
                          ? null
                          : () => _goToMatch(_controller.previousMatch()),
                    ),
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      onPressed: matches.isEmpty
                          ? null
                          : () => _goToMatch(_controller.nextMatch()),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.sm),
                Row(
                  children: [
                    Text(
                      '$currentDisplayIndex of ${matches.length}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    if (current != null)
                      Text(
                        'Page ${current.pageIndex + 1}',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimensions.md),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: matches.isEmpty
                        ? Center(
                            child: Text(
                              _controller.query.trim().isEmpty
                                  ? 'Type to search'
                                  : 'No matches',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: matches.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: AppColors.textDisabled.withAlpha(90),
                            ),
                            itemBuilder: (context, index) {
                              final match = matches[index];
                              final isActive =
                                  index == _controller.currentIndex;
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions.sm,
                                ),
                                tileColor: isActive
                                    ? AppColors.primary.withAlpha(36)
                                    : Colors.transparent,
                                title: Text(
                                  _snippetFor(match),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.bodySmall,
                                ),
                                subtitle: Text(
                                  'Page ${match.pageIndex + 1} · ${match.start}-${match.end}',
                                  style: AppTextStyles.bodySmall,
                                ),
                                onTap: () {
                                  _controller.setCurrentIndex(index);
                                  _goToMatch(match);
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _snippetFor(TextMatch match) {
    final content = ref.read(readerProvider).content;
    if (content == null) return match.matchedText;

    final pageText = content.pageText(match.pageIndex);
    if (pageText.isEmpty) return match.matchedText;

    const contextRadius = 24;
    final start = (match.start - contextRadius).clamp(0, pageText.length);
    final end = (match.end + contextRadius).clamp(0, pageText.length);
    return pageText.substring(start, end).replaceAll('\n', ' ').trim();
  }

  void _goToMatch(TextMatch? match) {
    if (match == null) return;
    ref.read(readerProvider.notifier).skipToPage(match.pageIndex);
  }
}
