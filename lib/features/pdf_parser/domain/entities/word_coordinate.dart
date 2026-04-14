import 'dart:ui';
import 'package:equatable/equatable.dart';

/// Links a segment of text inside the aggregated [ParsedPage] string
/// to its physical render bounds within the layout of the original PDF page.
class WordCoordinate extends Equatable {
  /// The inclusive starting character index within the [ParsedPage.text].
  final int charStart;

  /// The exclusive ending character index within the [ParsedPage.text].
  final int charEnd;

  /// The physical bounding box relative to the original unscaled PDF page.
  final Rect bounds;

  const WordCoordinate({
    required this.charStart,
    required this.charEnd,
    required this.bounds,
  });

  @override
  List<Object?> get props => [charStart, charEnd, bounds];
}
