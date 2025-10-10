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

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final email = _loginEmailController.text;
      final password = _loginPasswordController.text;
      await context.read<UserRepository>().login(email, password);
      if (mounted) {
        context.goNamed(AppRoutes.home.name);
      }
    } catch (e) {
      _showErrorSnackbar(e.toString());
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
        setState(() => _isLoading = false);
        return;
      }

      await context.read<UserRepository>().register(email, password);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso! Verifique o seu email para confirmar.'),
            backgroundColor: Colors.green,
          ),
        );
        _showLoginPage();
      }
    } catch (e) {
      _showErrorSnackbar(e.toString());
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
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}