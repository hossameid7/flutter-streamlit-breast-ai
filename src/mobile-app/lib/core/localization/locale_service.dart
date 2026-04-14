import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  final SharedPreferences _prefs;
  static const String _localeKey = 'app_locale';

  LocaleService(this._prefs);

  Future<void> saveLocale(Locale locale) async {
    await _prefs.setString(_localeKey, locale.languageCode);
  }

  Locale? getLocale() {
    final languageCode = _prefs.getString(_localeKey);
    if (languageCode != null) {
      return Locale(languageCode);
    }
    return null;
  }
}
