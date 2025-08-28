// Caminho: lib/repositories/photo_repository.dart

import 'package:pandora_snap/configs/constants.dart';
import 'package:pandora_snap/domain/models/photo_model.dart';
import 'package:pandora_snap/domain/models/user_model.dart';

class PhotoRepository {
  final List<Photo> _photos = [
    // Todas as fotos existentes agora pertencem ao 'admin'
    Photo(id: 's1', dogName: 'Simba', url: 'https://studio.edgeimpulse.com/v1/api/770783/raw-data/2217682148/image?cacheKey=1756306151484', date: DateTime(2025, 8, 5), userId: 'admin'),
    Photo(id: 's2', dogName: 'Simba', url: 'https://studio.edgeimpulse.com/v1/api/770783/raw-data/2217682144/image?cacheKey=1756306162419', date: DateTime(2025, 8, 12), userId: 'admin'),
    Photo(id: 's3', dogName: 'Simba', url: 'https://studio.edgeimpulse.com/v1/api/770783/raw-data/2217679594/image?cacheKey=1756305045887', date: DateTime(2025, 8, 19), userId: 'admin'),
    Photo(id: 'pr1', dogName: 'Princesa', url: 'https://studio.edgeimpulse.com/v1/api/770783/raw-data/2217679558/image?cacheKey=1756305159139', date: DateTime(2025, 8, 7), userId: 'admin'),
    Photo(id: 'pr2', dogName: 'Princesa', url: 'https://studio.edgeimpulse.com/v1/api/770783/raw-data/2217679554/image?cacheKey=1756305168796', date: DateTime(2025, 8, 14), userId: 'admin'),
    Photo(id: 'pr3', dogName: 'Princesa', url: 'https://studio.edgeimpulse.com/v1/api/770783/raw-data/2217679546/image?cacheKey=1756305380259', date: DateTime(2025, 8, 21), userId: 'admin'),
  ];

  // Função para obter as fotos visíveis para um utilizador específico
  List<Photo> _getVisiblePhotosFor(User? user) {
    if (user == null) return [];
    if (user.isAdmin) {
      return _photos; // Admin vê tudo
    }
    // Utilizador normal só vê as suas próprias fotos
    return _photos.where((photo) => photo.userId == user.username).toList();
  }

  List<Photo> getPhotosForDog(String dogName, User? user) {
    final visiblePhotos = _getVisiblePhotosFor(user);
    return visiblePhotos.where((photo) => photo.dogName == dogName).toList();
  }

  String getLatestCoverPhotoForDog(String dogName, User? user) {
    final photos = getPhotosForDog(dogName, user);
    if (photos.isEmpty) {
      return noImage;
    }
    photos.sort((a, b) => b.date.compareTo(a.date));
    return photos.first.url;
  }

  Set<DateTime> getDatesWithPhotos(User? user) {
    final visiblePhotos = _getVisiblePhotosFor(user);
    return visiblePhotos.map((photo) {
      return DateTime(photo.date.year, photo.date.month, photo.date.day);
    }).toSet();
  }

  List<Photo> getPhotosForDate(DateTime date, User? user) {
    final visiblePhotos = _getVisiblePhotosFor(user);
    return visiblePhotos.where((photo) {
      return photo.date.year == date.year &&
             photo.date.month == date.month &&
             photo.date.day == date.day;
    }).toList();
  }
}
