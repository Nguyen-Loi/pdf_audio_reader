import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'PDF Readcloud'**
  String get appName;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guest;

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium Active ✓'**
  String get premiumActive;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @backgroundPlaybackEnabled.
  ///
  /// In en, this message translates to:
  /// **'Background playback enabled'**
  String get backgroundPlaybackEnabled;

  /// No description provided for @unlockBackgroundAudioPlayback.
  ///
  /// In en, this message translates to:
  /// **'Unlock background audio playback'**
  String get unlockBackgroundAudioPlayback;

  /// No description provided for @viewOptions.
  ///
  /// In en, this message translates to:
  /// **'View Options'**
  String get viewOptions;

  /// No description provided for @readerMode.
  ///
  /// In en, this message translates to:
  /// **'Reader Mode'**
  String get readerMode;

  /// No description provided for @plainText.
  ///
  /// In en, this message translates to:
  /// **'Plain Text'**
  String get plainText;

  /// No description provided for @originalPdf.
  ///
  /// In en, this message translates to:
  /// **'Original PDF'**
  String get originalPdf;

  /// No description provided for @scrollDirection.
  ///
  /// In en, this message translates to:
  /// **'Scroll Direction'**
  String get scrollDirection;

  /// No description provided for @vertical.
  ///
  /// In en, this message translates to:
  /// **'Vertical'**
  String get vertical;

  /// No description provided for @horizontal.
  ///
  /// In en, this message translates to:
  /// **'Horizontal'**
  String get horizontal;

  /// No description provided for @textToSpeech.
  ///
  /// In en, this message translates to:
  /// **'Text-to-Speech'**
  String get textToSpeech;

  /// No description provided for @playbackSpeed.
  ///
  /// In en, this message translates to:
  /// **'Playback Speed'**
  String get playbackSpeed;

  /// No description provided for @voiceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Voice Language'**
  String get voiceLanguage;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @vietnamese.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese'**
  String get vietnamese;

  /// No description provided for @continueWithoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Continue without account'**
  String get continueWithoutAccount;

  /// No description provided for @listenToYourPdfsWithRealtimeWordHighlighting.
  ///
  /// In en, this message translates to:
  /// **'Listen to your PDFs with\\nreal-time word highlighting'**
  String get listenToYourPdfsWithRealtimeWordHighlighting;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @signInToSyncYourLibraryAcrossDevices.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync your library across devices'**
  String get signInToSyncYourLibraryAcrossDevices;

  /// No description provided for @myLibrary.
  ///
  /// In en, this message translates to:
  /// **'My Library'**
  String get myLibrary;

  /// No description provided for @loadingLibrary.
  ///
  /// In en, this message translates to:
  /// **'Loading library...'**
  String get loadingLibrary;

  /// No description provided for @openingPdf.
  ///
  /// In en, this message translates to:
  /// **'Opening PDF...'**
  String get openingPdf;

  /// No description provided for @importPdf.
  ///
  /// In en, this message translates to:
  /// **'Import PDF'**
  String get importPdf;

  /// No description provided for @noPdfsYet.
  ///
  /// In en, this message translates to:
  /// **'No PDFs yet'**
  String get noPdfsYet;

  /// No description provided for @tapToImportFirstPdf.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to import\\nyour first PDF'**
  String get tapToImportFirstPdf;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name} 👋'**
  String hello(Object name);

  /// No description provided for @pages.
  ///
  /// In en, this message translates to:
  /// **'{count} pages'**
  String pages(int count);

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// No description provided for @pageNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Page not found: {error}'**
  String pageNotFoundMessage(Object error);

  /// No description provided for @pageOf.
  ///
  /// In en, this message translates to:
  /// **'Page {pageNumber} / {pageCount}'**
  String pageOf(int pageNumber, int pageCount);

  /// No description provided for @noTextOnThisPage.
  ///
  /// In en, this message translates to:
  /// **'No text on this page'**
  String get noTextOnThisPage;

  /// No description provided for @sessionSettings.
  ///
  /// In en, this message translates to:
  /// **'Session Settings'**
  String get sessionSettings;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @speechSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speech Speed'**
  String get speechSpeed;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @autoDetectedByContent.
  ///
  /// In en, this message translates to:
  /// **'Auto (detected by content)'**
  String get autoDetectedByContent;

  /// No description provided for @showAllLanguages.
  ///
  /// In en, this message translates to:
  /// **'Show all languages'**
  String get showAllLanguages;

  /// No description provided for @detected.
  ///
  /// In en, this message translates to:
  /// **'Detected: {locale}'**
  String detected(Object locale);

  /// No description provided for @unableToLoadVoices.
  ///
  /// In en, this message translates to:
  /// **'Unable to load voices: {error}'**
  String unableToLoadVoices(Object error);

  /// No description provided for @noVoicesAvailableForThisLanguage.
  ///
  /// In en, this message translates to:
  /// **'No voices available for this language.'**
  String get noVoicesAvailableForThisLanguage;

  /// No description provided for @systemVoice.
  ///
  /// In en, this message translates to:
  /// **'System Voice'**
  String get systemVoice;

  /// No description provided for @searchNotImplementedYet.
  ///
  /// In en, this message translates to:
  /// **'Search not implemented yet.'**
  String get searchNotImplementedYet;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @goPremium.
  ///
  /// In en, this message translates to:
  /// **'Go Premium'**
  String get goPremium;

  /// No description provided for @unlockPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium'**
  String get unlockPremium;

  /// No description provided for @restorePurchase.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchase'**
  String get restorePurchase;

  /// No description provided for @keepReadingWhileScreenIsOff.
  ///
  /// In en, this message translates to:
  /// **'Keep reading while screen is off'**
  String get keepReadingWhileScreenIsOff;

  /// No description provided for @backgroundAudioPlayback.
  ///
  /// In en, this message translates to:
  /// **'Background audio playback'**
  String get backgroundAudioPlayback;

  /// No description provided for @lockScreenAndNotificationControls.
  ///
  /// In en, this message translates to:
  /// **'Lock screen & notification controls'**
  String get lockScreenAndNotificationControls;

  /// No description provided for @allFuturePremiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'All future premium features'**
  String get allFuturePremiumFeatures;

  /// No description provided for @removePdfMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete \"{title}\" from your library. This action cannot be undone.'**
  String removePdfMessage(Object title);

  /// No description provided for @removePdf.
  ///
  /// In en, this message translates to:
  /// **'Remove PDF?'**
  String get removePdf;

  /// No description provided for @openOriginalPdf.
  ///
  /// In en, this message translates to:
  /// **'Open original PDF'**
  String get openOriginalPdf;

  /// No description provided for @viewerWithOriginalLayout.
  ///
  /// In en, this message translates to:
  /// **'Viewer with original layout'**
  String get viewerWithOriginalLayout;

  /// No description provided for @openPlainText.
  ///
  /// In en, this message translates to:
  /// **'Open plain text'**
  String get openPlainText;

  /// No description provided for @textOnlyReader.
  ///
  /// In en, this message translates to:
  /// **'Text-only reader'**
  String get textOnlyReader;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @reader.
  ///
  /// In en, this message translates to:
  /// **'Reader'**
  String get reader;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLabel(Object version);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
