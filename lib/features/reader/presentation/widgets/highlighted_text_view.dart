import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/core/constants/app_colors.dart';
import 'package:pdf_audio_reader/core/constants/app_text_styles.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/highlight_state.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/highlight_provider.dart';

/// Renders a page of text with word and sentence karaoke highlighting.
class HighlightedTextView extends ConsumerWidget {
  final String pageText;

  const HighlightedTextView({super.key, required this.pageText});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highlight = ref.watch(highlightProvider);
    return _buildRichText(pageText, highlight);
  }

  Widget _buildRichText(String text, HighlightState h) {
    if (text.isEmpty) {
      return const Center(
        child: Text('No text on this page', style: AppTextStyles.bodyMedium),
      );
    }

    // Guard bounds
    final ws = h.wordStart.clamp(0, text.length);
    final we = h.wordEnd.clamp(ws, text.length);
    final ss = h.sentenceStart.clamp(0, ws);
    final se = h.sentenceEnd.clamp(we, text.length);

    // Identical start = no active highlight (initial state)
    if (ws == we) {
      return Text(text, style: AppTextStyles.readerBody);
    }

    return RichText(
      text: TextSpan(
        children: [
          // 1. Before sentence
          if (ss > 0)
            TextSpan(
              text: text.substring(0, ss),
              style: AppTextStyles.readerBody,
            ),

          // 2. Sentence before word
          if (ws > ss)
            TextSpan(
              text: text.substring(ss, ws),
              style: AppTextStyles.readerSentence,
            ),

          // 3. Current WORD (highlighted + scale animation via WidgetSpan)
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: _AnimatedWordSpan(word: h.currentWord),
          ),

          // 4. Sentence after word
          if (se > we)
            TextSpan(
              text: text.substring(we, se),
              style: AppTextStyles.readerSentence,
            ),

          // 5. After sentence
          if (se < text.length)
            TextSpan(
              text: text.substring(se),
              style: AppTextStyles.readerBody,
            ),
        ],
      ),
    );
  }
}

/// Micro-animation on the currently spoken word (pulse scale).
class _AnimatedWordSpan extends StatefulWidget {
  final String word;
  const _AnimatedWordSpan({required this.word});

  @override
  State<_AnimatedWordSpan> createState() => _AnimatedWordSpanState();
}

class _AnimatedWordSpanState extends State<_AnimatedWordSpan>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _ctrl.forward().then((_) => _ctrl.reverse());
  }

  @override
  void didUpdateWidget(covariant _AnimatedWordSpan oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.word != widget.word) {
      _ctrl.forward(from: 0).then((_) => _ctrl.reverse());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(200),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(widget.word, style: AppTextStyles.readerHighlightedWord),
      ),
    );
  }
}
