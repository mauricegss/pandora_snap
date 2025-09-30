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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Dog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}