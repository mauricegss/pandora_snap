import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:pandora_snap/configs/routes.dart';
import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:pandora_snap/domain/repositories/dog_repository.dart';
import 'package:pandora_snap/domain/repositories/photo_repository.dart';
import 'package:pandora_snap/services/edge_impulse_service.dart';
import 'package:provider/provider.dart';
import 'package:pandora_snap/domain/repositories/user_repository.dart';

class PreviewScreen extends StatefulWidget {
  final String imagePath;
  const PreviewScreen({super.key, required this.imagePath});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  Dog? _selectedDog;
  bool _isLoading = false;
  Rect? _boundingBox;
  Offset? _startPoint;
  final GlobalKey _imageKey = GlobalKey();

  void _onPanStart(DragStartDetails details) {
    final RenderBox? imageBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (imageBox == null) return;
    final startPoint = imageBox.globalToLocal(details.globalPosition);
    setState(() {
      _startPoint = startPoint;
      _boundingBox = Rect.fromPoints(startPoint, startPoint);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_startPoint == null) return;
    final RenderBox? imageBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (imageBox == null) return;

    final currentPoint = imageBox.globalToLocal(details.globalPosition);
    // Cria o retângulo visualmente correto, independentemente da direção.
    final visualRect = Rect.fromPoints(_startPoint!, currentPoint);
    
    setState(() => _boundingBox = visualRect);
  }

  Future<void> _processAndUpload() async {
    if (_selectedDog == null || _boundingBox == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Selecione um cão e desenhe uma caixa ao redor dele.'),
        backgroundColor: Colors.orangeAccent,
      ));
      return;
    }
    
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final user = context.read<UserRepository>().currentUser;
    final RenderBox? imageBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;

    if (imageBox == null) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Erro ao renderizar a imagem. Tente novamente.'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final originalFile = File(widget.imagePath);
      final imageBytes = await originalFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes)!;

      final originalWidth = originalImage.width;
      final originalHeight = originalImage.height;
      int cropWidth, cropHeight, offsetX, offsetY;
      if (originalWidth / originalHeight > 3 / 4) {
        cropHeight = originalHeight;
        cropWidth = (originalHeight * 3) ~/ 4;
        offsetX = (originalWidth - cropWidth) ~/ 2;
        offsetY = 0;
      } else {
        cropWidth = originalWidth;
        cropHeight = (originalWidth * 4) ~/ 3;
        offsetX = 0;
        offsetY = (originalHeight - cropHeight) ~/ 2;
      }

      final croppedImage = img.copyCrop(originalImage, x: offsetX, y: offsetY, width: cropWidth, height: cropHeight);
      final croppedFile = File('${originalFile.parent.path}/cropped_${originalFile.uri.pathSegments.last}');
      await croppedFile.writeAsBytes(img.encodeJpg(croppedImage));

      final scaleX = croppedImage.width / imageBox.size.width;
      final scaleY = croppedImage.height / imageBox.size.height;

      // --- CORREÇÃO DA BOUNDING BOX (Normalização dos Dados) ---
      final normalizedBBox = Rect.fromLTRB(
        min(_boundingBox!.left, _boundingBox!.right) * scaleX,
        min(_boundingBox!.top, _boundingBox!.bottom) * scaleY,
        max(_boundingBox!.left, _boundingBox!.right) * scaleX,
        max(_boundingBox!.top, _boundingBox!.bottom) * scaleY,
      );

      // --- CORREÇÃO DO NOME EM MINÚSCULAS ---
      final dogLabel = _selectedDog!.name.toLowerCase();

      // --- LÓGICA DE FALLBACK ---
      debugPrint("A tentar enviar para o Edge Impulse...");
      final status = await EdgeImpulseService().uploadImage(
        imageFile: croppedFile,
        label: dogLabel,
        boundingBox: normalizedBBox,
      );

      String finalMessage = "Foto processada com sucesso!";
      Color finalMessageColor = Colors.green;

      if (status == UploadStatus.serverOffline) {
        debugPrint("Servidor Edge Impulse offline. A enviar apenas para o Supabase.");
        finalMessage = "Foto guardada na galeria. O servidor de análise está offline.";
        finalMessageColor = Colors.orangeAccent;
      } else if (status == UploadStatus.failed) {
        debugPrint("Falha no envio para o Edge Impulse. A enviar apenas para o Supabase.");
        finalMessage = "Falha no servidor de análise. A foto foi guardada apenas na galeria.";
        finalMessageColor = Colors.redAccent;
      } else {
        debugPrint("✅ Requisição para o Edge Impulse enviada!");
      }

      // Upload para o Supabase é feito em todos os cenários.
      if (user != null) {
        debugPrint("A enviar para o Supabase...");
        await PhotoRepository().uploadPhoto(croppedFile, _selectedDog!, user);
        debugPrint("✅ Enviado para o Supabase com sucesso!");
      }

      await croppedFile.delete();

      if (!mounted) return;
      scaffoldMessenger.showSnackBar(SnackBar(content: Text(finalMessage), backgroundColor: finalMessageColor));
      router.goNamed(AppRoutes.home.name);

    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Ocorreu um erro no processamento: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marque o Cão na Foto'), centerTitle: true),
      body: Stack(children: [
        Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: Center(
                child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: GestureDetector(
                        onPanStart: _onPanStart,
                        onPanUpdate: _onPanUpdate,
                        child: Stack(fit: StackFit.expand, children: [
                          Image.file(File(widget.imagePath), key: _imageKey, fit: BoxFit.cover),
                          if (_boundingBox == null)
                            Center(
                                child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
                              child: const Text('Arraste na tela para marcar o cão', style: TextStyle(color: Colors.white, fontSize: 16)),
                            )),
                          if (_boundingBox != null) CustomPaint(size: Size.infinite, painter: BoundingBoxPainter(rect: _boundingBox!)),
                        ]))))),
        Positioned(
            top: 14,
            left: 16,
            right: 16,
            child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: StreamBuilder<List<Dog>>(
                    stream: DogRepository().getDogs(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: LinearProgressIndicator());
                      return DropdownButtonFormField<Dog>(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              labelText: 'Selecione um cão',
                              fillColor: Theme.of(context).scaffoldBackgroundColor,
                              filled: true),
                          initialValue: _selectedDog,
                          onChanged: (Dog? newValue) => setState(() => _selectedDog = newValue),
                          items: snapshot.data!.map((Dog dog) {
                            return DropdownMenuItem<Dog>(value: dog, child: Text(dog.name));
                          }).toList());
                    }))),
      ]),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isLoading
          ? const CircularProgressIndicator()
          : FloatingActionButton.extended(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              onPressed: _processAndUpload,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
              label: const Text('Enviar Foto'),
              icon: const Icon(Icons.check),
            ),
    );
  }
}

class BoundingBoxPainter extends CustomPainter {
  final Rect rect;
  BoundingBoxPainter({required this.rect});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRect(rect, paint);
    const handleSize = 6.0;
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(rect.topLeft, handleSize, paint);
    canvas.drawCircle(rect.topRight, handleSize, paint);
    canvas.drawCircle(rect.bottomLeft, handleSize, paint);
    canvas.drawCircle(rect.bottomRight, handleSize, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}