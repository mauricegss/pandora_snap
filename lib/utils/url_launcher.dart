import 'package:url_launcher/url_launcher.dart';

Future<void> launchPandoraInstagram() async {
  final Uri url = Uri.parse('https://www.instagram.com/projeto_pandora_utfpr_pg/');

  if (!await launchUrl(url)) {
      throw Exception('Não foi possível abrir $url');
  }
}