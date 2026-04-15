import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/features/audio_handler/audio_handler_provider.dart';
import 'package:pdf_audio_reader/features/reader/presentation/providers/reader_provider.dart';

final voiceSelectorAdvancedProvider =
    StateProvider.autoDispose<bool>((ref) => false);

final availableVoicesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final handler = ref.read(audioHandlerProvider);
  final voices = await handler.getAvailableVoices();
  return voices
      .whereType<Map>()
      .map((voice) => Map<String, dynamic>.from(voice))
      .toList();
});

final filteredVoicesProvider =
    Provider.autoDispose<List<Map<String, dynamic>>>((ref) {
  final showAll = ref.watch(voiceSelectorAdvancedProvider);
  final detectedLocale =
      ref.watch(readerProvider.select((state) => state.detectedLocale));
  final voicesAsync = ref.watch(availableVoicesProvider);

  return voicesAsync.maybeWhen(
    data: (voices) {
      if (showAll) return voices;
      return voices
          .where((voice) => _matchesLocale(voice['locale'], detectedLocale))
          .toList();
    },
    orElse: () => const [],
  );
});

bool _matchesLocale(dynamic rawLocale, String detectedLocale) {
  final locale = rawLocale?.toString().toLowerCase() ?? '';
  if (locale.isEmpty) return false;

  final target = detectedLocale.toLowerCase();
  if (locale == target) return true;

  final targetLang = target.split('-').first;
  return locale.startsWith(targetLang);
}
