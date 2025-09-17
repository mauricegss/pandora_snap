import 'package:flutter/material.dart';
import 'package:pandora_snap/domain/models/user_model.dart';

class UserRepository extends ChangeNotifier {

  User? _currentUser;
  User? get currentUser => _currentUser;

  final List<User> _users = [
    User(username: 'admin', password: 'admin', isAdmin: true),
  ];

  User? login(String username, String password) {
    try {
      final user = _users.firstWhere(
        (user) => user.username == username && user.password == password,
      );
      _currentUser = user;
      notifyListeners();
      return user;
    } catch (e) {
      _currentUser = null;
      notifyListeners();
      return null;
    }
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  bool register(String username, String password) {
    if (_users.any((user) => user.username == username)) {
      return false;
    }
    _users.add(User(username: username, password: password));
    return true;
  }
}