// lib/state/auth_service.dart
import 'package:flutter/foundation.dart';

/// Нэвтрэлтийн төлөв. router-ийн refreshListenable болно.
class AuthService extends ChangeNotifier {
  static const defaultPassword = 'Mobile317';

  bool _loggedIn = false;
  String? _email;
  String _password = defaultPassword; // жишээ: санах ойд хадгална

  bool get loggedIn => _loggedIn;
  String? get email => _email;

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // сервер дуурайлгана
    _loggedIn = password == _password;
    _email = _loggedIn ? email : null;
    notifyListeners();
    return _loggedIn;
  }

  /// Нууц үг солих. Одоогийн нууц үг буруу бол false буцаана.
  Future<bool> changePassword(String current, String next) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (current != _password) return false;
    _password = next;
    return true;
  }

  void logout() {
    _loggedIn = false;
    _email = null;
    notifyListeners();
  }
}

final auth = AuthService();
