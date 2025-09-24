import 'package:pandora_snap/domain/models/dog_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DogRepository {
  final _supabase = Supabase.instance.client;

  Future<List<Dog>> getDogs() async {
    try {
      final response = await _supabase.from('dogs').select().order('name', ascending: true);
      return response.map((map) => Dog.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }
}