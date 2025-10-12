import 'package:flutter/material.dart';
import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:pandora_snap/ui/screens/home/collection_viewmodel.dart';
import 'package:pandora_snap/ui/widgets/photo_grid_widget.dart';
import 'package:provider/provider.dart';

class DogDetailsScreen extends StatelessWidget {
  final Dog dog;

  const DogDetailsScreen({super.key, required this.dog});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CollectionViewModel>();
    
    final dogWithPhotos = viewModel.dogsWithPhotos.firstWhere(
      (element) => element.dog.id == dog.id,
      orElse: () => DogWithPhotos(dog: dog, photos: [], coverPhotoUrl: '', isCaptured: false),
    );
    final photos = dogWithPhotos.photos;

    return Scaffold(
      appBar: AppBar(
        title: Text(dog.name),
        centerTitle: true,
      ),
      body: PhotoGridView(photoList: photos),
    );
  }
}