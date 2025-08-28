import 'package:pandora_snap/domain/models/dog_model.dart';

class DogRepository {
  
  final List<Dog> _dogs = [
    Dog(name: 'Simba'),
    Dog(name: 'Caramela'),
    Dog(name: 'Batman'),
    Dog(name: 'Pitoco'),
    Dog(name: 'Greta'),
    Dog(name: 'Princesa'),
  ];

  List<Dog> getDogs() {
    return _dogs;
  }
}