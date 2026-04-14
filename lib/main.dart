import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_audio_reader/app.dart';
import 'package:pdf_audio_reader/bootstrap.dart';
import 'package:pdf_audio_reader/features/audio_handler/audio_handler_provider.dart';

void main() async {
  final handler = await bootstrap();

  runApp(
    ProviderScope(
      overrides: [
        // Inject the singleton TtsAudioHandler created by AudioService.init()
        audioHandlerProvider.overrideWithValue(handler),
      ],
      child: const App(),
    ),
  );
}
