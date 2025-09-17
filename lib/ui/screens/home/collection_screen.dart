import 'package:flutter/material.dart';
import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:pandora_snap/domain/models/user_model.dart';
import 'package:pandora_snap/domain/repositories/dog_repository.dart';
import 'package:pandora_snap/domain/repositories/photo_repository.dart';
import 'package:pandora_snap/domain/repositories/user_repository.dart';
import 'package:pandora_snap/ui/widgets/dog_card_widget.dart';
import 'package:provider/provider.dart';

class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = context.watch<UserRepository>().currentUser;
    final dogRepository = DogRepository();
    final photoRepository = PhotoRepository();

    final List<Dog> dogCollection =
        _getSortedDogs(currentUser, dogRepository, photoRepository);

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

        final bool isCaptured =
            photoRepository.getPhotosForDog(dog.name, currentUser).isNotEmpty;
        final coverPhotoUrl =
            photoRepository.getLatestCoverPhotoForDog(dog.name, currentUser);

        return DogCard(
          dog: dog,
          isCaptured: isCaptured,
          coverPhotoUrl: coverPhotoUrl,
        );
      },
    );
  }

  List<Dog> _getSortedDogs(User? currentUser, DogRepository dogRepository,
      PhotoRepository photoRepository) {
    List<Dog> unsortedDogs = dogRepository.getDogs();

    unsortedDogs.sort((a, b) {
      final photoCountA =
          photoRepository.getPhotosForDog(a.name, currentUser).length;
      final photoCountB =
          photoRepository.getPhotosForDog(b.name, currentUser).length;
      final countCompare = photoCountB.compareTo(photoCountA);
      if (countCompare != 0) return countCompare;
      return a.name.compareTo(b.name);
    });

    return unsortedDogs;
  }
}