import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pandora_snap/domain/models/user_model.dart' as model;
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository extends ChangeNotifier {
  final GoTrueClient _auth = Supabase.instance.client.auth;
  model.User? _currentUser;
  late final StreamSubscription<AuthState> _authStateSubscription;

  model.User? get currentUser => _currentUser;

  UserRepository() {
    _authStateSubscription = _auth.onAuthStateChange.listen((data) {
      final Session? session = data.session;
      if (session != null) {
        _currentUser = model.User(id: session.user.id, username: session.user.email!);
      } else {
        _currentUser = null;
      }
      notifyListeners();
    });
  }
  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
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