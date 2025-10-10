import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pandora_snap/configs/routes.dart';
import 'package:pandora_snap/ui/widgets/fab_widget.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint("Nenhuma câmera encontrada.");
        return;
      }
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
    } catch (e) {
      debugPrint("Erro ao inicializar a câmera: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    await _initializeControllerFuture;
    if (!mounted || _controller == null || !_controller!.value.isInitialized || _controller!.value.isTakingPicture) {
      return;
    }
    try {
      final image = await _controller!.takePicture();
      if (!mounted) return;
      context.pushNamed(
        AppRoutes.preview.name,
        extra: image.path,
      );
    } catch (e) {
      debugPrint("Erro ao tirar a foto: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tirar Foto'),
        centerTitle: true,
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError || _controller == null || !_controller!.value.isInitialized) {
              return Center(child: Text("Erro ao carregar a câmera: ${snapshot.error}"));
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 80.0),
              child: Center(
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: ClipRect(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller!.value.previewSize!.height,
                        height: _controller!.value.previewSize!.width,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Fab(
        onPressed: _takePicture,
      ),
    );
  }
}