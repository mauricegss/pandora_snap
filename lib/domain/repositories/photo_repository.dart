import 'dart:io';
import 'package:pandora_snap/configs/constants.dart';
import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:pandora_snap/domain/models/photo_model.dart';
import 'package:pandora_snap/domain/models/user_model.dart' as model;
import 'package:supabase_flutter/supabase_flutter.dart';

class PhotoRepository {
  final _supabase = Supabase.instance.client;

  Future<void> uploadPhoto(File imageFile, Dog dog, model.User user) async {
    try {
      final String filePath =
          '${user.username}/${dog.name}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _supabase.storage.from('photos').upload(filePath, imageFile);

      final String downloadUrl =
          _supabase.storage.from('photos').getPublicUrl(filePath);

      await _supabase.from('photos').insert({
        'dog_id': dog.id,
        'url': downloadUrl,
        'user_id': _supabase.auth.currentUser!.id,
        'date': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Não foi possível enviar a foto.');
    }
  }

  Stream<List<Photo>> getPhotosForDog(int dogId, model.User? user) {
    if (user == null) return Stream.value([]);
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _supabase
        .from('photos')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((listOfMaps) {

          final filteredList = listOfMaps.where((map) => map['dog_id'] == dogId).toList();
          
          filteredList.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

          return filteredList.map((map) => Photo.fromMap(map)).toList();
        });
  }

  Future<String> getLatestCoverPhotoForDog(int dogId, model.User? user) async {
    if (user == null) return noImage;
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return noImage;

    try {
      final response = await _supabase
          .from('photos')
          .select('url')
          .eq('user_id', userId)
          .eq('dog_id', dogId)
          .order('date', ascending: false)
          .limit(1)
          .single();

      return response['url'];
    } catch (e) {
      return noImage;
    }
  }

  Stream<Set<DateTime>> getDatesWithPhotos(model.User? user) {
    if (user == null) return Stream.value({});
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value({});

    return _supabase
        .from('photos')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((listOfMaps) {
      return listOfMaps.map((map) {
        final date = DateTime.parse(map['date']).toLocal();
        return DateTime(date.year, date.month, date.day);
      }).toSet();
    });
  }

  Stream<List<Photo>> getPhotosForDate(DateTime date, model.User? user) {
    if (user == null) return Stream.value([]);
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _supabase
        .from('photos')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((listOfMaps) {
          final filteredList = listOfMaps.where((map) {
            final photoDate = DateTime.parse(map['date']).toLocal();
            return photoDate.year == date.year &&
                   photoDate.month == date.month &&
                   photoDate.day == date.day;
          }).toList();
          
          return filteredList.map((map) => Photo.fromMap(map)).toList();
        });
  }
}