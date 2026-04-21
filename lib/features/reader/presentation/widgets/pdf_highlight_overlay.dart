import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/highlight_state.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/reader_content.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/text_search_models.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/highlight_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/ui_state_provider.dart';

class PdfHighlightOverlay extends ConsumerStatefulWidget {
  final String filePath;
  final int currentPageIndex;
  final ValueChanged<int> onPageChanged;
  final Axis scrollDirection;
  final List<TextElement> pageElements;
  final TextMatch? activeSearchMatch;

  const PdfHighlightOverlay({
    super.key,
    required this.filePath,
    required this.currentPageIndex,
    required this.onPageChanged,
    required this.scrollDirection,
    required this.pageElements,
    required this.activeSearchMatch,
  });

  @override
  ConsumerState<PdfHighlightOverlay> createState() =>
      _PdfHighlightOverlayState();
}

class _PdfHighlightOverlayState extends ConsumerState<PdfHighlightOverlay> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  HighlightAnnotation? _currentTtsAnnotation;
  HighlightAnnotation? _currentSearchAnnotation;
  ProviderSubscription<HighlightState>? _highlightSub;
  late Future<Uint8List> _pdfBytesFuture;

  @override
  void initState() {
    super.initState();
    _pdfBytesFuture = File(widget.filePath).readAsBytes();
    _highlightSub =
        ref.listenManual<HighlightState>(highlightProvider, (previous, next) {
      _applyHighlight(next);
    });
  }

  @override
  void didUpdateWidget(covariant PdfHighlightOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath) {
      setState(() {
        _pdfBytesFuture = File(widget.filePath).readAsBytes();
      });
    }
    if (oldWidget.currentPageIndex != widget.currentPageIndex) {
      _pdfViewerController
          .jumpToPage(widget.currentPageIndex + 1); // 1-indexed in Syncfusion
    }

    if (oldWidget.currentPageIndex != widget.currentPageIndex ||
        oldWidget.activeSearchMatch != widget.activeSearchMatch ||
        oldWidget.pageElements != widget.pageElements) {
      _applySearchHighlight();
    }
  }

  @override
  void dispose() {
    if (_currentTtsAnnotation != null) {
      _pdfViewerController.removeAnnotation(_currentTtsAnnotation!);
    }
    if (_currentSearchAnnotation != null) {
      _pdfViewerController.removeAnnotation(_currentSearchAnnotation!);
    }
    _pdfViewerController.dispose();
    _highlightSub?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrollDirection = widget.scrollDirection == Axis.horizontal
        ? PdfScrollDirection.horizontal
        : PdfScrollDirection.vertical;

    return FutureBuilder<Uint8List>(
      future: _pdfBytesFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            SfPdfViewer.memory(
              snapshot.data!,
              controller: _pdfViewerController,
              pageLayoutMode: scrollDirection == PdfScrollDirection.horizontal
                  ? PdfPageLayoutMode.single
                  : PdfPageLayoutMode.continuous,
              scrollDirection: scrollDirection,
              canShowScrollHead: false,
              canShowScrollStatus: false,
              enableTextSelection: true,
              onDocumentLoaded: (details) {
                if (widget.currentPageIndex > 0) {
                  _pdfViewerController.jumpToPage(widget.currentPageIndex + 1);
                }
                _applySearchHighlight();
              },
              onPageChanged: (details) {
                final newPageIndex = details.newPageNumber - 1;
                if (newPageIndex != widget.currentPageIndex) {
                  widget.onPageChanged(newPageIndex);
                }
              },
            ),
            // Transparent tap overlay to detect taps
            Positioned.fill(
              child: Consumer(
                builder: (context, ref, _) {
                  return GestureDetector(
                    onTap: () {
                      final uiNotifier = ref.read(
                        readerUiStateProvider.notifier,
                      );
                      final uiState = ref.read(readerUiStateProvider);

                      if (uiState == ReaderUiState.audioMode) {
                        uiNotifier.toggleAudioMode();
                      } else {
                        uiNotifier.toggleHud();
                      }
                    },
                    behavior: HitTestBehavior.translucent,
                    child: const SizedBox.expand(),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _applyHighlight(HighlightState next) {
    if (next.currentBounds != null) {
      if (_currentTtsAnnotation != null) {
        _pdfViewerController.removeAnnotation(_currentTtsAnnotation!);
      }

      _currentTtsAnnotation = HighlightAnnotation(
        textBoundsCollection: [
          PdfTextLine(
            next.currentBounds!,
            next.currentWord,
            widget.currentPageIndex + 1,
          )
        ],
      );
      _currentTtsAnnotation!.color = Colors.yellow.withValues(alpha: 0.5);

      _pdfViewerController.addAnnotation(_currentTtsAnnotation!);
    } else {
      if (_currentTtsAnnotation != null) {
        _pdfViewerController.removeAnnotation(_currentTtsAnnotation!);
        _currentTtsAnnotation = null;
      }
    }
  }

  void _applySearchHighlight() {
    final match = widget.activeSearchMatch;

    if (_currentSearchAnnotation != null) {
      _pdfViewerController.removeAnnotation(_currentSearchAnnotation!);
      _currentSearchAnnotation = null;
    }

    if (match == null) return;
    if (widget.pageElements.isEmpty) return;

    final bounds = _boundsForMatch(match, widget.pageElements);
    if (bounds == null) return;

    _currentSearchAnnotation = HighlightAnnotation(
      textBoundsCollection: [
        PdfTextLine(
          bounds,
          match.matchedText,
          widget.currentPageIndex + 1,
        ),
      ],
    )..color = Colors.orangeAccent.withValues(alpha: 0.45);

    _pdfViewerController.addAnnotation(_currentSearchAnnotation!);
  }

  Rect? _boundsForMatch(TextMatch match, List<TextElement> elements) {
    final overlapping = elements.where(
      (element) =>
          element.charStart < match.end && element.charEnd > match.start,
    );

    double? left;
    double? top;
    double? right;
    double? bottom;

    for (final element in overlapping) {
      final rect = element.bounds;
      left = left == null ? rect.left : (rect.left < left ? rect.left : left);
      top = top == null ? rect.top : (rect.top < top ? rect.top : top);
      right = right == null
          ? rect.right
          : (rect.right > right ? rect.right : right);
      bottom = bottom == null
          ? rect.bottom
          : (rect.bottom > bottom ? rect.bottom : bottom);
    }

    if (left == null || top == null || right == null || bottom == null) {
      return null;
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }
}
