import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('vi');
  final SharedPreferences _prefs;

  Locale get locale => _locale;

  LocaleProvider(this._prefs) {
    _loadLocale();
  }

  void setLocale(Locale newLocale) {
    if (_locale != newLocale) {
      _locale = newLocale;
      _saveLocale(newLocale);
      notifyListeners();
    }
  }

  _loadLocale() {
    String? languageCode = _prefs.getString('languageCode');
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  _saveLocale(Locale locale) {
    _prefs.setString('languageCode', locale.languageCode);
  }
}
