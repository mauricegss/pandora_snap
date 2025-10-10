import 'package:flutter/material.dart';

class Fab extends StatelessWidget {
  final VoidCallback onPressed;

  const Fab({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 50,
      child: FloatingActionButton(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        onPressed: onPressed,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: const Icon(
          Icons.camera_alt_rounded,
          size: 28,
        ),
      ),
    );
  }
}