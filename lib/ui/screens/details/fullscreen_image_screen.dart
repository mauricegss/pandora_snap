import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FullscreenImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullscreenImageScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(imageUrl),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                context.pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
