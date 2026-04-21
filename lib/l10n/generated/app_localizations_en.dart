// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PDF Readcloud';

  @override
  String get settings => 'Settings';

  @override
  String get account => 'Account';

  @override
  String get guest => 'Guest';

  @override
  String get notSignedIn => 'Not signed in';

  @override
  String get signOut => 'Sign out';

  @override
  String get signIn => 'Sign in';

  @override
  String get subscription => 'Subscription';

  @override
  String get premiumActive => 'Premium Active ✓';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get backgroundPlaybackEnabled => 'Background playback enabled';

  @override
  String get unlockBackgroundAudioPlayback =>
      'Unlock background audio playback';

  @override
  String get viewOptions => 'View Options';

  @override
  String get readerMode => 'Reader Mode';

  @override
  String get plainText => 'Plain Text';

  @override
  String get originalPdf => 'Original PDF';

  @override
  String get scrollDirection => 'Scroll Direction';

  @override
  String get vertical => 'Vertical';

  @override
  String get horizontal => 'Horizontal';

  @override
  String get textToSpeech => 'Text-to-Speech';

  @override
  String get playbackSpeed => 'Playback Speed';

  @override
  String get voiceLanguage => 'Voice Language';

  @override
  String get about => 'About';

  @override
  String get appLanguage => 'App Language';

  @override
  String get english => 'English';

  @override
  String get vietnamese => 'Vietnamese';

  @override
  String get continueWithoutAccount => 'Continue without account';

  @override
  String get listenToYourPdfsWithRealtimeWordHighlighting =>
      'Listen to your PDFs with\\nreal-time word highlighting';

  @override
  String get getStarted => 'Get started';

  @override
  String get signInToSyncYourLibraryAcrossDevices =>
      'Sign in to sync your library across devices';

  @override
  String get myLibrary => 'My Library';

  @override
  String get loadingLibrary => 'Loading library...';

  @override
  String get openingPdf => 'Opening PDF...';

  @override
  String get importPdf => 'Import PDF';

  @override
  String get noPdfsYet => 'No PDFs yet';

  @override
  String get tapToImportFirstPdf =>
      'Tap the button below to import\\nyour first PDF';

  @override
  String hello(Object name) {
    return 'Hello, $name 👋';
  }

  @override
  String pages(int count) {
    return '$count pages';
  }

  @override
  String get pageNotFound => 'Page not found';

  @override
  String pageNotFoundMessage(Object error) {
    return 'Page not found: $error';
  }

  @override
  String pageOf(int pageNumber, int pageCount) {
    return 'Page $pageNumber / $pageCount';
  }

  @override
  String get noTextOnThisPage => 'No text on this page';

  @override
  String get sessionSettings => 'Session Settings';

  @override
  String get reset => 'Reset';

  @override
  String get speechSpeed => 'Speech Speed';

  @override
  String get voice => 'Voice';

  @override
  String get systemDefault => 'System Default';

  @override
  String get autoDetectedByContent => 'Auto (detected by content)';

  @override
  String get showAllLanguages => 'Show all languages';

  @override
  String detected(Object locale) {
    return 'Detected: $locale';
  }

  @override
  String unableToLoadVoices(Object error) {
    return 'Unable to load voices: $error';
  }

  @override
  String get noVoicesAvailableForThisLanguage =>
      'No voices available for this language.';

  @override
  String get systemVoice => 'System Voice';

  @override
  String get cancel => 'Cancel';

  @override
  String get goPremium => 'Go Premium';

  @override
  String get unlockPremium => 'Unlock Premium';

  @override
  String get restorePurchase => 'Restore Purchase';

  @override
  String get keepReadingWhileScreenIsOff => 'Keep reading while screen is off';

  @override
  String get backgroundAudioPlayback => 'Background audio playback';

  @override
  String get lockScreenAndNotificationControls =>
      'Lock screen & notification controls';

  @override
  String get allFuturePremiumFeatures => 'All future premium features';

  @override
  String removePdfMessage(Object title) {
    return 'This will delete \"$title\" from your library. This action cannot be undone.';
  }

  @override
  String get removePdf => 'Remove PDF?';

  @override
  String get openOriginalPdf => 'Open original PDF';

  @override
  String get viewerWithOriginalLayout => 'Viewer with original layout';

  @override
  String get openPlainText => 'Open plain text';

  @override
  String get textOnlyReader => 'Text-only reader';

  @override
  String get delete => 'Delete';

  @override
  String get retry => 'Retry';

  @override
  String get reader => 'Reader';

  @override
  String versionLabel(Object version) {
    return 'Version $version';
  }

  @override
  String get apply => 'Apply';
}
