import 'package:flutter/material.dart';
import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:pandora_snap/domain/models/photo_model.dart';
import 'package:pandora_snap/domain/models/user_model.dart';
import 'package:pandora_snap/domain/repositories/photo_repository.dart';
import 'package:pandora_snap/domain/repositories/user_repository.dart';
import 'package:pandora_snap/ui/widgets/photo_grid_widget.dart';

class DogDetailsScreen extends StatefulWidget {
  final Dog dog;

  const DogDetailsScreen({super.key, required this.dog});

  @override
  State<DogDetailsScreen> createState() => _DogDetailsScreenState();
}

class _DogDetailsScreenState extends State<DogDetailsScreen> {
  late final List<Photo> photoList;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    // 1. Busca o utilizador logado
    currentUser = UserRepository().currentUser;
    // 2. Passa os DOIS argumentos necessários para a função
    photoList = PhotoRepository().getPhotosForDog(widget.dog.name, currentUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.dog.name),
        centerTitle: true,
      ),
      body: PhotoGridView(photoList: photoList),
    );
  }
}
