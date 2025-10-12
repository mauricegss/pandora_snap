import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:pandora_snap/domain/models/photo_model.dart';
import 'package:pandora_snap/configs/routes.dart';

class DogCard extends StatelessWidget {
  final Dog dog;
  final bool isCaptured;
  final String coverPhotoUrl;
  final List<Photo> photos;

  const DogCard({
    super.key,
    required this.dog,
    required this.isCaptured,
    required this.coverPhotoUrl,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {

    Widget imageWidget;
    if (coverPhotoUrl.startsWith('assets/')) {
      imageWidget = Image.asset(
        coverPhotoUrl,
        fit: BoxFit.cover,
      );
    } else {
      imageWidget = CachedNetworkImage(
        imageUrl: coverPhotoUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (isCaptured) {
            context.pushNamed(AppRoutes.dogDetails.name, extra: dog);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: imageWidget,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                dog.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCaptured ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}