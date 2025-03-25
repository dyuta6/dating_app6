import 'package:flutter/cupertino.dart';

import 'AppLocalizationsTr.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String translate(String key) {
    switch (locale.languageCode) {
      case 'tr':
        return AppLocalizationsTr().translate(key);

      default:
        return key;
    }
  }
}
