import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  static const defaultPassword = 'Mongol2021';

  bool _loggedIn = false;
  String? _email;
  String _password = defaultPassword;

  bool get loggedIn => _loggedIn;
  String? get email => _email;

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _loggedIn = password == _password;
    _email = _loggedIn ? email : null;
    notifyListeners();
    return _loggedIn;
  }

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
