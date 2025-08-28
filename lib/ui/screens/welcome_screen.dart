import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pandora_snap/ui/screens/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _launchPandoraURL() async {
    final Uri url = Uri.parse('https://www.instagram.com/projeto_pandora_utfpr_pg/');
    
    if (!await launchUrl(url)) {
      throw Exception('Não foi possível abrir $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bem-Vindo!'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
          },
        ),
      ),
      body: ListView(
        children: [
          SizedBox(height: 350),
          // Conteúdo da tela
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text('Entrar'),
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: _launchPandoraURL,
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
