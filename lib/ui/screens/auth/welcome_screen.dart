import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pandora_snap/configs/routes.dart';
import 'package:pandora_snap/utils/url_launcher.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-Vindo!'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SizedBox(height: 350),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    context.pushNamed(AppRoutes.auth.name);
                  },
                  child: const Text('Entrar'),
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: launchPandoraInstagram,
                  child: const Text(
                    "Siga o Projeto Pandora",
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),

                const SizedBox(height: 180),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
