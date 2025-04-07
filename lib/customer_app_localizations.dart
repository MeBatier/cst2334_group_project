import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
/// Provides localized strings for the application based on the current Locale
///
/// This class loads JSON-based translations from the `assets/translations/` directory.
/// Use AppLocalizations.of(context) to access translated strings.
class AppLocalizations {
  // The locale this localization instance is for.
  final Locale locale;
  // A map containing the loaded key-value translation pairs.
  Map<String, String> _localizedStrings = {};
  // Creates a localization instance for a given [locale].
  AppLocalizations(this.locale);

  /// Provides the current [AppLocalizations] instance from the widget [context].
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }
  /// A delegate that loads and provides localized resources.
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  /// Loads the language file from assets and parses it into _localizedStrings.
  Future<bool> load() async {
    String jsonString = await rootBundle.loadString('assets/translations/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }
  /// Retrieves the translated string for the given key.
  String? translate(String key) {
    return _localizedStrings[key];
  }
}
/// A localization delegate for loading AppLocalizations based on Locale.
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  // Const constructor for the delegate.
  const _AppLocalizationsDelegate();
  /// Determines if the app supports the given locale.
  ///
  /// Currently supports English (`en`) and Turkish (`tr`).
  @override
  bool isSupported(Locale locale) {
    return ['en', 'tr'].contains(locale.languageCode);
  }
  /// Loads the appropriate localization resources for the given locale.
  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }
  /// Indicates whether the delegate should reload when locale changes.
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}