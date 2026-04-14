import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_audio_reader/features/audio_handler/tts_audio_handler.dart';
import 'package:pdf_audio_reader/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Performs all async initialization before the app renders.
/// Returns the [TtsAudioHandler] singleton and [SharedPreferences] instance
/// so they can be injected into [ProviderScope] via an `overrides` list.
Future<({TtsAudioHandler handler, SharedPreferences prefs})> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Firebase + Firestore offline persistence
  await FirebaseService.initialize();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize AudioService — returns our handler as a singleton
  final handler = await AudioService.init<TtsAudioHandler>(
    builder: TtsAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.nguyenloi.pdf_audio_reader.audio',
      androidNotificationChannelName: 'PDF Readcloud',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      notificationColor: Color(0xFF6C63FF),
    ),
  );

  return (handler: handler, prefs: prefs);
}
