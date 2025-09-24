import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pandora_snap/domain/repositories/user_repository.dart';
import 'package:pandora_snap/configs/routes.dart';
import 'package:pandora_snap/ui/screens/auth/widgets/login_widget.dart';
import 'package:pandora_snap/ui/screens/auth/widgets/register_widget.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _pageController = PageController();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final email = _loginEmailController.text;
      final password = _loginPasswordController.text;

      final user =
          await context.read<UserRepository>().login(email, password);

      if (mounted) {
        if (user != null) {
          context.goNamed(AppRoutes.home.name);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email ou senha inválidos.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _register() async {
    setState(() => _isLoading = true);
    try {
      final email = _registerEmailController.text;
      final password = _registerPasswordController.text;

      if (email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, preencha todos os campos.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
        return;
      }

      final success =
          await context.read<UserRepository>().register(email, password);

      if (mounted) {
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
              content: Text('Ocorreu um erro. Verifique o email ou tente novamente.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [

              LoginView(
                emailController: _loginEmailController,
                passwordController: _loginPasswordController,
                isLoading: _isLoading,
                onLoginPressed: _login,
                onShowRegisterPressed: _showRegisterPage,
              ),

              RegisterView(
                emailController: _registerEmailController,
                passwordController: _registerPasswordController,
                isLoading: _isLoading,
                onRegisterPressed: _register,
                onShowLoginPressed: _showLoginPage,
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}