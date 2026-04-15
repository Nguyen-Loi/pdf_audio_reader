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
import 'package:pdf_audio_reader/features/auth/presentation/providers/auth_provider.dart';
import 'package:pdf_audio_reader/features/pdf_library/domain/entities/pdf_document_info.dart';
import 'package:pdf_audio_reader/features/pdf_library/presentation/providers/pdf_library_provider.dart';
import 'package:pdf_audio_reader/features/reader/domain/entities/tts_config.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(pdfLibraryProvider);
    final user = ref.watch(currentUserProvider);

    return GradientScaffold(
      appBar: _buildAppBar(context, ref, user?.name ?? 'Library'),
      floatingActionButton: _buildFab(context, ref),
      body: libraryAsync.when(
        loading: () => const AppLoading(message: 'Loading library…'),
        error: (e, _) => AppErrorWidget(
          message: e.toString(),
          onRetry: () => ref.read(pdfLibraryProvider.notifier).refresh(),
        ),
        data: (pdfs) => pdfs.isEmpty
            ? _buildEmptyState(context, ref)
            : _buildGrid(context, ref, pdfs),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, WidgetRef ref, String name) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, $name 👋',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textSecondary),
          ),
          const Text('My Library', style: AppTextStyles.h2),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          color: AppColors.textSecondary,
          onPressed: () => context.push(RouteNames.settings),
        ),
      ],
    );
  }

  Widget _buildFab(BuildContext context, WidgetRef ref) {
    return FloatingActionButton.extended(
      onPressed: () async {
        final error = await ref.read(pdfLibraryProvider.notifier).importPdf();
        if (error != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
      },
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.add, color: Colors.white),
      label: const Text('Import PDF',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
              ),
              child: const Icon(Icons.picture_as_pdf_outlined,
                  size: 48, color: AppColors.textDisabled),
            ),
            const SizedBox(height: AppDimensions.lg),
            const Text('No PDFs yet', style: AppTextStyles.h2),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'Tap the button below to import\nyour first PDF',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(
      BuildContext context, WidgetRef ref, List<PdfDocumentInfo> pdfs) {
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.bgCard,
      onRefresh: () => ref.read(pdfLibraryProvider.notifier).refresh(),
      child: GridView.builder(
        padding: const EdgeInsets.all(AppDimensions.pagePadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppDimensions.md,
          mainAxisSpacing: AppDimensions.md,
          childAspectRatio: 0.72,
        ),
        itemCount: pdfs.length,
        itemBuilder: (context, i) => _PdfCard(
          doc: pdfs[i],
          onTap: () => context.push(RouteNames.reader,
              extra: ReaderPageParams(pdfId: pdfs[i].id)),
          onLongPress: () => _showOpenOptions(context, pdfs[i].id),
          onOpenOriginal: () => context.push(
            RouteNames.reader,
            extra: ReaderPageParams(
              pdfId: pdfs[i].id,
              initialReaderMode: ReaderMode.originalPdf,
            ),
          ),
          onOpenPlainText: () => context.push(
            RouteNames.reader,
            extra: ReaderPageParams(
              pdfId: pdfs[i].id,
              initialReaderMode: ReaderMode.textOnly,
            ),
          ),
          onDelete: () => _confirmDelete(context, ref, pdfs[i]),
        ),
      ),
    );
  }

  Future<void> _showOpenOptions(BuildContext context, String pdfId) {
    final openOriginalPdf = ReaderPageParams(
        pdfId: pdfId, initialReaderMode: ReaderMode.originalPdf);
    final openTextOnly =
        ReaderPageParams(pdfId: pdfId, initialReaderMode: ReaderMode.textOnly);
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              top: AppDimensions.sm,
              bottom: AppDimensions.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.bgCardHover,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),
                ListTile(
                  leading: const Icon(
                    Icons.picture_as_pdf_rounded,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Open original PDF',
                    style: AppTextStyles.labelLarge,
                  ),
                  subtitle: Text(
                    'Viewer with original layout',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push(
                      RouteNames.reader,
                      extra: openOriginalPdf,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.text_snippet_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Open plain text',
                    style: AppTextStyles.labelLarge,
                  ),
                  subtitle: Text(
                    'Text-only reader',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push(
                      RouteNames.reader,
                      extra: openTextOnly,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Future<void> _confirmDelete(
  BuildContext context,
  WidgetRef ref,
  PdfDocumentInfo doc,
) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('Remove PDF?'),
        content: Text(
          'This will delete "${doc.title}" from your library. This action cannot be undone.',
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Remove',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      );
    },
  );

  if (shouldDelete == true && context.mounted) {
    await ref.read(pdfLibraryProvider.notifier).deletePdf(doc.id);
  }
}

// ── PDF Card ──────────────────────────────────────────────────────────────

class _PdfCard extends StatelessWidget {
  final PdfDocumentInfo doc;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onOpenOriginal;
  final VoidCallback onOpenPlainText;
  final VoidCallback onDelete;

  const _PdfCard({
    required this.doc,
    required this.onTap,
    required this.onLongPress,
    required this.onOpenOriginal,
    required this.onOpenPlainText,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasProgress = doc.lastPageIndex != null && doc.pageCount > 0;
    final progress =
        hasProgress ? (doc.lastPageIndex! + 1) / doc.pageCount : 0.0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: const Color(0xFF3A3A5C)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PDF cover area
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppDimensions.radiusLg),
                        topRight: Radius.circular(AppDimensions.radiusLg),
                      ),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      size: 52,
                      color: AppColors.primary,
                    ),
                  ),
                  // Context menu
                  Positioned(
                    top: 4,
                    right: 4,
                    child: PopupMenuButton<String>(
                      color: AppColors.bgCard,
                      icon: const Icon(Icons.more_vert,
                          size: 18, color: AppColors.textSecondary),
                      onSelected: (v) {
                        switch (v) {
                          case 'open_original':
                            onOpenOriginal();
                            break;
                          case 'open_plain_text':
                            onOpenPlainText();
                            break;
                          case 'delete':
                            onDelete();
                            break;
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'open_original',
                          child: Row(
                            children: [
                              Icon(Icons.picture_as_pdf_rounded,
                                  color: AppColors.primary, size: 18),
                              SizedBox(width: 8),
                              Text('Open original PDF'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'open_plain_text',
                          child: Row(
                            children: [
                              Icon(Icons.text_snippet_outlined,
                                  color: AppColors.primary, size: 18),
                              SizedBox(width: 8),
                              Text('Open plain text'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  color: AppColors.error, size: 18),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Info section
            Padding(
              padding: const EdgeInsets.all(AppDimensions.sm + 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    style: AppTextStyles.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppDimensions.xs),
                  Text(
                    '${doc.pageCount} pages',
                    style: AppTextStyles.bodySmall,
                  ),
                  if (hasProgress) ...[
                    const SizedBox(height: AppDimensions.xs),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.bgCardHover,
                      color: AppColors.primary,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                      minHeight: 3,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReaderPageParams {
  final String pdfId;
  final ReaderMode? initialReaderMode;

  ReaderPageParams({
    required this.pdfId,
    this.initialReaderMode,
  });
}
