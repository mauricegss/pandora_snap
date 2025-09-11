import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pandora_snap/domain/models/photo_model.dart';
import 'package:pandora_snap/configs/routes.dart';

class PhotoGridView extends StatelessWidget {
  final List<Photo> photoList;

  const PhotoGridView({super.key, required this.photoList});

  @override
  Widget build(BuildContext context) {
    if (photoList.isEmpty) {
      return const Center(
        child: Text('Nenhuma foto encontrada.'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: photoList.length,
      itemBuilder: (context, index) {
        final photo = photoList[index];
        return GestureDetector(
          onTap: () {
            context.pushNamed(AppRoutes.fullscreenImage.name, extra: photo.url);
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              photo.url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, color: Colors.red),
            ),
          ),
        );
      },
    );
  }
}