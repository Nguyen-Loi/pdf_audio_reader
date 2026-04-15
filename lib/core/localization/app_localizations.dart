import 'package:flutter/widgets.dart';
import 'package:pdf_audio_reader/l10n/generated/app_localizations.dart'
    as generated;

export 'package:pdf_audio_reader/l10n/generated/app_localizations.dart'
    show AppLocalizations;

extension AppLocalizationsX on BuildContext {
  generated.AppLocalizations get l10n => generated.AppLocalizations.of(this);
}
