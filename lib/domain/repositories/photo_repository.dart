import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pandora_snap/configs/constants.dart';
import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:pandora_snap/domain/models/photo_model.dart';
import 'package:pandora_snap/domain/models/user_model.dart' as model;
import 'package:supabase_flutter/supabase_flutter.dart';

class PhotoRepository {
  final _supabase = Supabase.instance.client;
  static const String _photoQuery = '*, dogs(name)';

  Future<void> uploadPhoto(File imageFile, Dog dog, model.User user) async {
    try {
      final String filePath = '${user.id}/${dog.name}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _supabase.storage.from('photos').upload(filePath, imageFile);
      final String downloadUrl = _supabase.storage.from('photos').getPublicUrl(filePath);
      await _supabase.from('photos').insert({
        'dog_id': dog.id,
        'url': downloadUrl,
        'user_id': _supabase.auth.currentUser!.id,
        'date': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Erro ao fazer upload da foto: $e');
      throw Exception('Não foi possível enviar a foto.');
    }
  }

  Future<void> deletePhotoById(String photoId) async {
    try {
      final response = await _supabase
          .from('photos')
          .select('url')
          .eq('id', photoId)
          .single();

      final photoUrl = response['url'] as String;

      final bucketName = 'photos';
      final uri = Uri.parse(photoUrl);
      final filePath = uri.pathSegments
          .sublist(uri.pathSegments.indexOf(bucketName) + 1)
          .join('/');

      debugPrint("A apagar ficheiro do Storage: $filePath");
      await _supabase.storage.from(bucketName).remove([filePath]);
      debugPrint("✅ Ficheiro apagado do Storage com sucesso.");

      debugPrint("A apagar registo da base de dados com ID: $photoId");
      await _supabase.from('photos').delete().eq('id', photoId);
      debugPrint("✅ Registo apagado da base de dados com sucesso.");

    } catch (e) {
      debugPrint('Erro ao apagar a foto por ID: $e');
      throw Exception('Não foi possível apagar a foto.');
    }
  }

  Future<List<Photo>> getPhotosForDog(int dogId, model.User? user) async {
    if (user == null) return [];
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];
    final response = await _supabase
        .from('photos')
        .select(_photoQuery)
        .eq('user_id', userId)
        .eq('dog_id', dogId)
        .order('date', ascending: false);
    return response.map((map) => Photo.fromMap(map)).toList();
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
        final date = DateTime.parse(map['date']);
        final localDate = date.toLocal();
        return DateTime(localDate.year, localDate.month, localDate.day);
      }).toSet();
    });
  }

  Future<List<Photo>> getPhotosForDate(DateTime date, model.User? user) async {
    if (user == null) return [];
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    final response = await _supabase
        .from('photos')
        .select(_photoQuery)
        .eq('user_id', userId)
        .gte('date', startOfDay.toIso8601String())
        .lte('date', endOfDay.toIso8601String());
    return response.map((map) => Photo.fromMap(map)).toList();
  }
}