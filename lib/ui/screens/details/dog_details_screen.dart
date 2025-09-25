import 'package:flutter/material.dart';
import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:pandora_snap/domain/models/photo_model.dart';
import 'package:pandora_snap/domain/models/user_model.dart' as model;
import 'package:pandora_snap/domain/repositories/photo_repository.dart';
import 'package:pandora_snap/domain/repositories/user_repository.dart';
import 'package:pandora_snap/ui/widgets/photo_grid_widget.dart';
import 'package:provider/provider.dart';

class DogDetailsScreen extends StatelessWidget {
  final Dog dog;

  const DogDetailsScreen({super.key, required this.dog});

  @override
  Widget build(BuildContext context) {
    final model.User? currentUser = context.watch<UserRepository>().currentUser;
    final photoRepository = PhotoRepository();

    return Scaffold(
      appBar: AppBar(
        title: Text(dog.name),
        centerTitle: true,
      ),
      
      body: FutureBuilder<List<Photo>>(
        future: photoRepository.getPhotosForDog(dog.id, currentUser),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Ocorreu um erro ao carregar as fotos.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma foto encontrada para este cão.'));
          }

          final photoList = snapshot.data!;
          return PhotoGridView(photoList: photoList);
        },
      ),
    );
  }
}