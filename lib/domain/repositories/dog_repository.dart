import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DogRepository {
  final _supabase = Supabase.instance.client;

  Stream<List<Dog>> getDogs() {
    return _supabase
        .from('dogs')
        .stream(primaryKey: ['id'])
        .order('name', ascending: true)
        .map((listOfMaps) => listOfMaps.map((map) => Dog.fromMap(map)).toList());
  }
}