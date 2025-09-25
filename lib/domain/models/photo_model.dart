class Photo {
  final String id;
  final String dogName;
  final String url;
  final DateTime date;
  final String userId;

  Photo({
    required this.id,
    required this.dogName,
    required this.url,
    required this.date,
    required this.userId,
  });

  factory Photo.fromMap(Map<String, dynamic> map) {
    return Photo(
      id: map['id'].toString(),
      dogName: map['dogs'] != null ? map['dogs']['name'] : 'Cão Desconhecido',
      url: map['url'],
      date: DateTime.parse(map['date']),
      userId: map['user_id'],
    );
  }
}