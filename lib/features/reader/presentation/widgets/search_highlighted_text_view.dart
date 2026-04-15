import 'package:flutter/material.dart';
import 'package:pdf_audio_reader/core/constants/app_colors.dart';
import 'package:pdf_audio_reader/core/constants/app_text_styles.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/text_search_models.dart';

class SearchHighlightedTextView extends StatelessWidget {
  final String pageText;
  final List<TextMatch> matches;
  final TextMatch? activeMatch;

  const SearchHighlightedTextView({
    super.key,
    required this.pageText,
    required this.matches,
    this.activeMatch,
  });

  @override
  Widget build(BuildContext context) {
    if (pageText.isEmpty) {
      return Text(pageText, style: AppTextStyles.readerBody);
    }

    if (matches.isEmpty) {
      return Text(pageText, style: AppTextStyles.readerBody);
    }

    final sorted = [...matches]..sort((a, b) {
        final byStart = a.start.compareTo(b.start);
        if (byStart != 0) return byStart;
        return a.end.compareTo(b.end);
      });

    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final match in sorted) {
      final start = match.start.clamp(0, pageText.length);
      final end = match.end.clamp(start, pageText.length);
      if (start < cursor || end <= start) {
        continue;
      }

      if (start > cursor) {
        spans.add(
          TextSpan(
            text: pageText.substring(cursor, start),
            style: AppTextStyles.readerBody,
          ),
        );
      }

      final isActive = _isSameRange(match, activeMatch);
      spans.add(
        TextSpan(
          text: pageText.substring(start, end),
          style: AppTextStyles.readerBody.copyWith(
            backgroundColor: isActive
                ? AppColors.accent.withAlpha(170)
                : AppColors.primary.withAlpha(90),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      );
      cursor = end;
    }

    if (cursor < pageText.length) {
      spans.add(
        TextSpan(
          text: pageText.substring(cursor),
          style: AppTextStyles.readerBody,
        ),
      );
    }

    return RichText(text: TextSpan(children: spans));
  }

  bool _isSameRange(TextMatch match, TextMatch? other) {
    if (other == null) return false;
    return match.pageIndex == other.pageIndex &&
        match.start == other.start &&
        match.end == other.end;
  }
}
