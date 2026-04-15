import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/highlight_state.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/highlight_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/ui_state_provider.dart';

class PdfHighlightOverlay extends ConsumerStatefulWidget {
  final String filePath;
  final int currentPageIndex;
  final Axis scrollDirection;

  const PdfHighlightOverlay({
    super.key,
    required this.filePath,
    required this.currentPageIndex,
    required this.scrollDirection,
  });

  @override
  ConsumerState<PdfHighlightOverlay> createState() =>
      _PdfHighlightOverlayState();
}

class _PdfHighlightOverlayState extends ConsumerState<PdfHighlightOverlay> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  HighlightAnnotation? _currentAnnotation;
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
  }

  @override
  void dispose() {
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
              pageLayoutMode: PdfPageLayoutMode.continuous,
              scrollDirection: scrollDirection,
              canShowScrollHead: false,
              canShowScrollStatus: false,
              enableTextSelection: true,
              onDocumentLoaded: (details) {
                if (widget.currentPageIndex > 0) {
                  _pdfViewerController.jumpToPage(widget.currentPageIndex + 1);
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
      if (_currentAnnotation != null) {
        _pdfViewerController.removeAnnotation(_currentAnnotation!);
      }

      _currentAnnotation = HighlightAnnotation(
        textBoundsCollection: [
          PdfTextLine(
            next.currentBounds!,
            next.currentWord,
            widget.currentPageIndex + 1,
          )
        ],
      );
      _currentAnnotation!.color = Colors.yellow.withValues(alpha: 0.5);

      _pdfViewerController.addAnnotation(_currentAnnotation!);
    } else {
      if (_currentAnnotation != null) {
        _pdfViewerController.removeAnnotation(_currentAnnotation!);
        _currentAnnotation = null;
      }
    }
  }
}
