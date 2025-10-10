import 'package:flutter/material.dart';
import 'package:pandora_snap/domain/models/photo_model.dart';
import 'package:pandora_snap/ui/widgets/photo_grid_widget.dart';

class DogDetailsScreen extends StatelessWidget {
  final List<Photo> photos;

  const DogDetailsScreen({super.key, required this.photos});

  @override
  Widget build(BuildContext context) {
    final dogName = photos.isNotEmpty ? photos.first.dogName : 'Cão Desconhecido';

    return Scaffold(
      appBar: AppBar(
        title: Text(dogName),
        centerTitle: true,
      ),
      
      body: PhotoGridView(photoList: photos),
    );
  }
}