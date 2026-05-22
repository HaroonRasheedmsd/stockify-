import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String _userName = '';
  String _userRole = '';

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String get userName => _userName;
  String get userRole => _userRole;

  AuthProvider() {
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (_isLoggedIn) {
      _userName = prefs.getString('userName') ?? 'Admin';
      _userRole = prefs.getString('userRole') ?? 'Manager';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String username, String password, bool rememberMe) async {
    _isLoading = true;
    notifyListeners();

    // Mock Authentication: check if admin / admin123
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate networking/hashing delay

    if (username.trim().toLowerCase() == 'admin' && password == 'admin123') {
      _isLoggedIn = true;
      _userName = 'Haroon & Arif';
      _userRole = 'Administrator';
      
      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userName', _userName);
        await prefs.setString('userRole', _userRole);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userName = '';
    _userRole = '';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userName');
    await prefs.remove('userRole');
  }
}
