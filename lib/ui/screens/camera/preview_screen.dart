import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pandora_snap/configs/routes.dart';
import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:pandora_snap/domain/repositories/dog_repository.dart';
import 'package:pandora_snap/domain/repositories/photo_repository.dart';
import 'package:pandora_snap/domain/repositories/user_repository.dart';
import 'package:pandora_snap/services/edge_impulse_service.dart';
import 'package:pandora_snap/services/photo_processing_service.dart';
import 'package:pandora_snap/ui/screens/home/calendar_viewmodel.dart';
import 'package:pandora_snap/ui/screens/home/collection_viewmodel.dart';
import 'package:provider/provider.dart';

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
    final visualRect = Rect.fromPoints(_startPoint!, currentPoint);

    setState(() => _boundingBox = visualRect);
  }

  Future<void> _processAndUpload() async {
    if (_selectedDog == null || _boundingBox == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Selecione um cão e desenhe uma caixa ao redor dele.'),
        backgroundColor: Colors.orangeAccent,
      ));
      return;
    }
    
    final user = context.read<UserRepository>().currentUser;
    final collectionViewModel = context.read<CollectionViewModel>();
    final calendarViewModel = context.read<CalendarViewModel>();
    final router = GoRouter.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final RenderBox? imageBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (user == null || imageBox == null) return;

    setState(() => _isLoading = true);
    
    final processingService = PhotoProcessingService(
      edgeImpulseService: EdgeImpulseService(),
      photoRepository: context.read<PhotoRepository>(),
    );

    final result = await processingService.processAndUpload(
      imagePath: widget.imagePath,
      selectedDog: _selectedDog!,
      user: user,
      boundingBox: _boundingBox!,
      imageRenderSize: imageBox.size,
    );

    if (!mounted) return;

    String finalMessage;
    Color finalMessageColor;

    switch (result) {
      case PhotoUploadResult.success:
        finalMessage = "Foto enviada com sucesso!";
        finalMessageColor = Colors.green;
        break;
      case PhotoUploadResult.serverOffline:
        finalMessage = "Foto guardada. O servidor de análise está offline.";
        finalMessageColor = Colors.orangeAccent;
        break;
      case PhotoUploadResult.error:
        finalMessage = "Ocorreu um erro no processamento.";
        finalMessageColor = Colors.red;
        break;
    }

    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text(finalMessage), backgroundColor: finalMessageColor)
    );

    await collectionViewModel.fetchData(user);
    await calendarViewModel.fetchData(user);

    router.goNamed(AppRoutes.home.name);
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
                    stream: context.read<DogRepository>().getDogs(),
                    builder: (context, snapshot) {
                      
                      Widget? suffixWidget;
                      String labelText = 'Selecione um cão';

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        suffixWidget = const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.0),
                          child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.0)),
                        );
                      } else if (snapshot.hasError) {
                        suffixWidget = const Icon(Icons.error, color: Colors.red);
                        labelText = 'Erro ao carregar cães';
                      }

                      return DropdownButtonFormField<Dog>(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              labelText: labelText,
                              fillColor: Theme.of(context).scaffoldBackgroundColor,
                              filled: true,
                              suffixIcon: suffixWidget,
                          ),
                          isExpanded: true,
                          initialValue: _selectedDog,
                          onChanged: snapshot.hasData ? (Dog? newValue) => setState(() => _selectedDog = newValue) : null,
                          items: snapshot.hasData ? snapshot.data!.map((Dog dog) {
                            return DropdownMenuItem<Dog>(value: dog, child: Text(dog.name));
                          }).toList() : [],
                      );
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