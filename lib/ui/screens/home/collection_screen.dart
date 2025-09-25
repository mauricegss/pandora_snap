import 'package:flutter/material.dart';
import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:pandora_snap/domain/models/photo_model.dart';
import 'package:pandora_snap/domain/models/user_model.dart' as model;
import 'package:pandora_snap/domain/repositories/dog_repository.dart';
import 'package:pandora_snap/domain/repositories/photo_repository.dart';
import 'package:pandora_snap/domain/repositories/user_repository.dart';
import 'package:pandora_snap/ui/widgets/dog_card_widget.dart';
import 'package:provider/provider.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final model.User? currentUser = context.watch<UserRepository>().currentUser;
    final dogRepository = DogRepository();
    final photoRepository = PhotoRepository();

    return FutureBuilder<List<Dog>>(
      future: dogRepository.getDogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Não foi possível carregar os cães.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Nenhum cão encontrado.'));
        }

        final dogCollection = snapshot.data!;

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.95,
          ),
          itemCount: dogCollection.length,
          itemBuilder: (context, index) {
            final dog = dogCollection[index];

            return FutureBuilder<String>(
              future: photoRepository.getLatestCoverPhotoForDog(dog.id, currentUser),
              builder: (context, coverPhotoSnapshot) {
                if (coverPhotoSnapshot.connectionState == ConnectionState.waiting) {
                  return const Card(child: Center(child: CircularProgressIndicator()));
                }

                final coverPhotoUrl = coverPhotoSnapshot.data ?? 'assets/no_image.png';

                return FutureBuilder<List<Photo>>(
                  future: photoRepository.getPhotosForDog(dog.id, currentUser),
                  builder: (context, photoListSnapshot) {
                    final isCaptured = photoListSnapshot.hasData && photoListSnapshot.data!.isNotEmpty;
                    
                    return DogCard(
                      dog: dog,
                      isCaptured: isCaptured,
                      coverPhotoUrl: coverPhotoUrl,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}