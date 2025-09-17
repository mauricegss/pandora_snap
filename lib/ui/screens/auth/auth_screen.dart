import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pandora_snap/domain/repositories/user_repository.dart';
import 'package:pandora_snap/configs/routes.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {

  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _pageController = PageController();
  final _loginUsernameController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerUsernameController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _loginUsernameController.dispose();
    _loginPasswordController.dispose();
    _registerUsernameController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  void _login() {
    final username = _loginUsernameController.text;
    final password = _loginPasswordController.text;

    final user = context.read<UserRepository>().login(username, password);

    if (user != null) {
      context.goNamed(AppRoutes.home.name);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuário ou senha inválidos.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _register() {
    final username = _registerUsernameController.text;
    final password = _registerPasswordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }
    
    final success = context.read<UserRepository>().register(username, password);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Conta criada com sucesso! Faça o login para continuar.'),
          backgroundColor: Colors.green,
        ),
      );
      _showLoginPage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este nome de usuário já existe.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showRegisterPage() {
    _pageController.animateToPage(1,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  void _showLoginPage() {
    _pageController.animateToPage(0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-vindo'),
        centerTitle: true,
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildLoginView(),
          _buildRegisterView(),
        ],
      ),
    );
  }

  Widget _buildLoginView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Entrar",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 30),
            TextField(
              controller: _loginUsernameController,
              decoration: const InputDecoration(
                  labelText: 'Usuário',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(100)))),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _loginPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(100)))),
            ),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: _login, child: const Text('Confirmar')),
            TextButton(
                onPressed: _showRegisterPage,
                child: const Text('Criar uma Conta')),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text("Registar",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 30),
            TextField(
              controller: _registerUsernameController,
              decoration: const InputDecoration(
                  labelText: 'Usuário',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(100)))),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _registerPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(100)))),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
                onPressed: _register, child: const Text('Confirmar')),
            TextButton(
                onPressed: _showLoginPage,
                child: const Text('Já tenho uma conta')),
          ],
        ),
      ),
    );
  }
}