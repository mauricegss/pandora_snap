import 'package:flutter/material.dart';

class RegisterView extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onRegisterPressed;
  final VoidCallback onShowLoginPressed;

  const RegisterView({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onRegisterPressed,
    required this.onShowLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
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
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(100)))),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(100)))),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: isLoading ? null : onRegisterPressed,
              child: const Text('Confirmar'),
            ),
            TextButton(
              onPressed: isLoading ? null : onShowLoginPressed,
              child: const Text('Já tenho uma conta'),
            ),
          ],
        ),
      ),
    );
  }
}