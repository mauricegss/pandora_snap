import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pandora_snap/configs/routes.dart';
import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:pandora_snap/domain/repositories/dog_repository.dart';
import 'package:pandora_snap/domain/repositories/photo_repository.dart';
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

  // A função _getImageDimensions foi REMOVIDA daqui

  void _onPanStart(DragStartDetails details) {
    final RenderBox imageBox = _imageKey.currentContext!.findRenderObject() as RenderBox;
    final startPoint = imageBox.globalToLocal(details.globalPosition);
    setState(() {
      _startPoint = startPoint;
      _boundingBox = Rect.fromPoints(startPoint, startPoint);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_startPoint == null) return;
    final RenderBox imageBox = _imageKey.currentContext!.findRenderObject() as RenderBox;
    final currentPoint = imageBox.globalToLocal(details.globalPosition);
    setState(() {
      _boundingBox = Rect.fromLTRB(
        _startPoint!.dx < currentPoint.dx ? _startPoint!.dx : currentPoint.dx,
        _startPoint!.dy < currentPoint.dy ? _startPoint!.dy : currentPoint.dy,
        _startPoint!.dx > currentPoint.dx ? _startPoint!.dx : currentPoint.dx,
        _startPoint!.dy > currentPoint.dy ? _startPoint!.dy : currentPoint.dy,
      );
    });
  }

  Future<void> _uploadData() async {
    if (_selectedDog == null || _boundingBox == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Selecione um cão e desenhe uma caixa ao redor dele.'),
        backgroundColor: Colors.orangeAccent,
      ));
      return;
    }

    setState(() => _isLoading = true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      final user = context.read<UserRepository>().currentUser;
      if (user == null) throw Exception("Usuário não logado.");

      final imageFile = File(widget.imagePath);
      final photoRepo = PhotoRepository();

      await photoRepo.uploadPhoto(imageFile, _selectedDog!, user);

      if (!mounted) return;
      scaffoldMessenger.showSnackBar(const SnackBar(
        content: Text('Foto guardada com sucesso!'),
        backgroundColor: Colors.green,
      ));
      router.goNamed(AppRoutes.home.name);

    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Erro ao guardar a foto: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marque o Cão na Foto'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: Center(
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(widget.imagePath),
                        key: _imageKey,
                        fit: BoxFit.cover,
                      ),
                      if (_boundingBox == null)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Arraste na tela para marcar o cão',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      if (_boundingBox != null)
                        CustomPaint(
                          size: Size.infinite,
                          painter: BoundingBoxPainter(rect: _boundingBox!),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
                      filled: true,
                    ),
                    initialValue: _selectedDog,
                    onChanged: (Dog? newValue) => setState(() => _selectedDog = newValue),
                    items: snapshot.data!.map((Dog dog) {
                      return DropdownMenuItem<Dog>(value: dog, child: Text(dog.name));
                    }).toList(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _isLoading
          ? const CircularProgressIndicator()
          : FloatingActionButton.extended(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              onPressed: _uploadData,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
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