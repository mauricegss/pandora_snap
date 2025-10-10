import 'package:flutter/material.dart';
import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:pandora_snap/domain/models/photo_model.dart';
import 'package:pandora_snap/domain/models/user_model.dart' as model;
import 'package:pandora_snap/domain/repositories/dog_repository.dart';
import 'package:pandora_snap/domain/repositories/photo_repository.dart';

class DogWithPhotos {
  final Dog dog;
  final List<Photo> photos;
  final String coverPhotoUrl;
  final bool isCaptured;

  DogWithPhotos({
    required this.dog,
    required this.photos,
    required this.coverPhotoUrl,
    required this.isCaptured,
  });
}

class CollectionViewModel extends ChangeNotifier {
  final DogRepository _dogRepository;
  final PhotoRepository _photoRepository;

  CollectionViewModel(this._dogRepository, this._photoRepository);

  List<DogWithPhotos> _dogsWithPhotos = [];
  List<DogWithPhotos> get dogsWithPhotos => _dogsWithPhotos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchData(model.User? user) async {
    if (user == null) return;
    _isLoading = true;
    notifyListeners();

    final dogs = await _dogRepository.getDogs().first;
    
    final futureDogsWithPhotos = dogs.map((dog) async {
      final photos = await _photoRepository.getPhotosForDog(dog.id, user);
      final isCaptured = photos.isNotEmpty;
      final coverPhotoUrl = isCaptured ? photos.first.url : 'assets/no_image.png';
      
      return DogWithPhotos(
        dog: dog,
        photos: photos,
        coverPhotoUrl: coverPhotoUrl,
        isCaptured: isCaptured,
      );
    }).toList();

    _dogsWithPhotos = await Future.wait(futureDogsWithPhotos);
    
    _isLoading = false;
    notifyListeners();
  }
}