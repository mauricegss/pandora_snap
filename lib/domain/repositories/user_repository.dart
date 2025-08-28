import 'package:pandora_snap/domain/models/user_model.dart';

class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;
  UserRepository._internal();

  User? currentUser;

  final List<User> _users = [
    User(username: 'admin', password: 'admin', isAdmin: true),
  ];

  User? login(String username, String password) {
    try {
      final user = _users.firstWhere(
        (user) => user.username == username && user.password == password,
      );
      currentUser = user;
      return user;
    } catch (e) {
      currentUser = null;
      return null;
    }
  }

  void logout() {
    currentUser = null;
  }

  bool register(String username, String password) {
    if (_users.any((user) => user.username == username)) {
      return false;
    }
    _users.add(User(username: username, password: password));
    return true;
  }
}
