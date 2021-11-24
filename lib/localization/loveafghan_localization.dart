import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class LoveafghanLocalization {
  final Locale locale;

  LoveafghanLocalization(this.locale);

  static LoveafghanLocalization of(BuildContext context) {
    return Localizations.of<LoveafghanLocalization>(
        context, LoveafghanLocalization);
  }

  Map<String, String> _localizedValues;

  Future load() async {
    String jsonStringValues =
        await rootBundle.loadString('lib/lang/${locale.languageCode}.json');

    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);

    _localizedValues =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  String getTranslatedValue(String key) {
    return _localizedValues[key];
  }

  // stat
  static const LocalizationsDelegate<LoveafghanLocalization> delegate =
      _LoveafghanLocalizationDelegate();
}

class _LoveafghanLocalizationDelegate
    extends LocalizationsDelegate<LoveafghanLocalization> {
  const _LoveafghanLocalizationDelegate();
  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'es', 'nl', 'ru', 'ur', 'hi', 'de', 'fr', 'fa', 'ps']
        .contains(locale.languageCode);
  }

  @override
  Future<LoveafghanLocalization> load(Locale locale) async {
    LoveafghanLocalization localization = new LoveafghanLocalization(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(_LoveafghanLocalizationDelegate old) => false;
}
