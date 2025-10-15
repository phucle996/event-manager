import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  final SharedPreferences _prefs;

  bool get isLoggedIn => _isLoggedIn;

  AuthProvider(this._prefs) {
    _loadLoginState();
  }

  void _loadLoginState() {
    _isLoggedIn = _prefs.getBool('isLoggedIn') ?? false;
    notifyListeners();
  }

  Future<void> login() async {
    _isLoggedIn = true;
    await _prefs.setBool('isLoggedIn', true);
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    await _prefs.setBool('isLoggedIn', false);
    notifyListeners();
  }
}
