import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum UploadStatus { success, serverOffline, failed }

class EdgeImpulseService {
  final String _serverUrl = "${dotenv.env['CLOUD_RUN_URL']!}/upload";

  Future<UploadStatus> uploadImage({
    required File imageFile,
    required String label,
    required Rect boundingBox,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(_serverUrl));

      request.fields['label'] = label;
      request.fields['bbox_x'] = boundingBox.left.round().toString();
      request.fields['bbox_y'] = boundingBox.top.round().toString();
      request.fields['bbox_width'] = boundingBox.width.round().toString();
      request.fields['bbox_height'] = boundingBox.height.round().toString();

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: basename(imageFile.path),
      ));

      var response = await request.send().timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        debugPrint('Resposta do servidor Python: $responseBody');
        return UploadStatus.success;
      } else {
        final responseBody = await response.stream.bytesToString();
        debugPrint('Erro no servidor Python: ${response.statusCode}');
        debugPrint('Corpo da resposta: $responseBody');
        return UploadStatus.failed;
      }
    } on SocketException {
      debugPrint('Exceção de Socket: Não foi possível conectar ao servidor. Verifique o IP e se o servidor está online.');
      return UploadStatus.serverOffline;
    } on TimeoutException {
      debugPrint('Timeout: A conexão com o servidor demorou demais. Verifique o IP e se o servidor está online.');
      return UploadStatus.serverOffline;
    } catch (e) {
      debugPrint('Exceção ao enviar para o servidor local: $e');
      return UploadStatus.failed;
    }
  }
}