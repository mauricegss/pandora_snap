import 'package:flutter/material.dart';
import 'package:pandora_snap/domain/models/user_model.dart' as model;
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository extends ChangeNotifier {
  final GoTrueClient _auth = Supabase.instance.client.auth;
  model.User? _currentUser;

  model.User? get currentUser => _currentUser;

  UserRepository() {
    _checkInitialSession();
  }

  void _checkInitialSession() {
    final supabaseUser = _auth.currentUser;
    if (supabaseUser != null) {
      _currentUser = model.User(id: supabaseUser.id, username: supabaseUser.email!);
    }
  }

  Future<model.User> login(String email, String password) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null) {
        _currentUser = model.User(id: user.id, username: user.email!);
        notifyListeners();
        return _currentUser!;
      }
      throw 'Utilizador não encontrado na resposta.';
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Ocorreu um erro inesperado durante o login.';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    try {
      await _auth.signUp(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Ocorreu um erro inesperado durante o registo.';
    }
  }
}