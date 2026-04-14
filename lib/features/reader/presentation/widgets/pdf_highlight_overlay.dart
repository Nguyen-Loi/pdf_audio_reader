import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/highlight_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/reader_provider.dart';

class PdfHighlightOverlay extends ConsumerStatefulWidget {
  final String filePath;
  final int currentPageIndex;

  const PdfHighlightOverlay({
    super.key,
    required this.filePath,
    required this.currentPageIndex,
  });

  @override
  ConsumerState<PdfHighlightOverlay> createState() => _PdfHighlightOverlayState();
}

class _PdfHighlightOverlayState extends ConsumerState<PdfHighlightOverlay> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  HighlightAnnotation? _currentAnnotation;

  @override
  void didUpdateWidget(covariant PdfHighlightOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPageIndex != widget.currentPageIndex) {
      _pdfViewerController.jumpToPage(widget.currentPageIndex + 1); // 1-indexed in Syncfusion
    }
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for bounds updates from the TTS
    ref.listen(highlightProvider, (previous, next) {
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
    });

    return SfPdfViewer.file(
      File(widget.filePath),
      controller: _pdfViewerController,
      canShowScrollHead: false,
      canShowScrollStatus: false,
      onDocumentLoaded: (details) {
        if (widget.currentPageIndex > 0) {
           _pdfViewerController.jumpToPage(widget.currentPageIndex + 1);
        }
      },
    );
  }
}
