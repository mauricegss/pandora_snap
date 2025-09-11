import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:pandora_snap/configs/routes.dart';

class DogCard extends StatelessWidget {
  final Dog dog;
  final bool isCaptured;
  final String coverPhotoUrl;

  const DogCard({
    super.key,
    required this.dog,
    required this.isCaptured,
    required this.coverPhotoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (isCaptured) {
            // A navegação agora pertence ao card
            context.pushNamed(AppRoutes.dogDetails.name, extra: dog);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                coverPhotoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error, color: Colors.red),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                dog.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  // A opacidade é controlada pela cor do texto
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