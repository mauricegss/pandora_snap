import 'package:flutter/material.dart';
import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:pandora_snap/domain/models/photo_model.dart';
import 'package:pandora_snap/domain/models/user_model.dart';
import 'package:pandora_snap/domain/repositories/photo_repository.dart';
import 'package:pandora_snap/domain/repositories/user_repository.dart';
import 'package:pandora_snap/ui/widgets/photo_grid_widget.dart';
import 'package:provider/provider.dart';

class DogDetailsScreen extends StatefulWidget {
  final Dog dog;

  const DogDetailsScreen({super.key, required this.dog});

  @override
  State<DogDetailsScreen> createState() => _DogDetailsScreenState();
}

class _DogDetailsScreenState extends State<DogDetailsScreen> {

  @override
  Widget build(BuildContext context) {

    final User? currentUser = context.watch<UserRepository>().currentUser;
    final List<Photo> photoList = PhotoRepository().getPhotosForDog(widget.dog.name, currentUser);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dog.name),
        centerTitle: true,
      ),
      body: PhotoGridView(photoList: photoList),
    );
  }
}