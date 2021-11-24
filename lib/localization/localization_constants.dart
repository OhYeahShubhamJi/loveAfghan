import 'package:flutter/cupertino.dart';
import 'package:loveafghan/localization/loveafghan_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getTranslated(BuildContext context, String key) {
  return LoveafghanLocalization.of(context).getTranslatedValue(key);
}

// language Code
const String ENGLISH = 'en';
const String ARABIC = 'ar';
const String SPANISH = 'es';
const String DUTCH = 'nl';
const String RUSSIAN = 'ru';
const String URDU = 'ur';
const String HINDI = 'hi';
const String GERMAN = 'de';
const String FRENCH = 'fr';
const String FARSI = 'fa';
const String PASHTO = 'ps';

const String LANGUAGE_CODE = 'languageCode';

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();

  await _prefs.setString(LANGUAGE_CODE, languageCode);

  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  Locale _temp;
  switch (languageCode) {
    case ENGLISH:
      _temp = Locale(languageCode, 'US');
      break;
    case ARABIC:
      _temp = Locale(languageCode, 'AE');
      break;
    case SPANISH:
      _temp = Locale(languageCode, 'ES');
      break;
    case DUTCH:
      _temp = Locale(languageCode, 'NL');
      break;
    case RUSSIAN:
      _temp = Locale(languageCode, 'RU');
      break;
    case URDU:
      _temp = Locale(languageCode, 'PK');
      break;
    case HINDI:
      _temp = Locale(languageCode, 'IN');
      break;
    case GERMAN:
      _temp = Locale(languageCode, 'DE');
      break;
    case FRENCH:
      _temp = Locale(languageCode, 'FR');
      break;
    case FARSI:
      _temp = Locale(languageCode, 'IR');
      break;
    case PASHTO:
      _temp = Locale(languageCode, 'AF');
      break;
    default:
      _temp = Locale(ENGLISH, 'US');
  }
  return _temp;
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LANGUAGE_CODE) ?? ENGLISH;
  return _locale(languageCode);
}

Future<String> getLanguageCode() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LANGUAGE_CODE) ?? ENGLISH;
  return languageCode;
}
