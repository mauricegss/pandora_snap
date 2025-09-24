class Dog {
  final int id;
  final String name;

  Dog({
    required this.id,
    required this.name,
  });

  factory Dog.fromMap(Map<String, dynamic> map) {
    return Dog(
      id: map['id'],
      name: map['name'],
    );
  }
}