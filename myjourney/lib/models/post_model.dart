class Post {
  String title;
  String location;
  String description;
  String userId; // ID del usuario que crea el post
  String type; // 'activity' o 'review'
  String category; // 'restaurant', 'viewpoint', 'museum', 'historic_place'

  // Campos adicionales para actividades
  DateTime? date;
  double? price;
  String? meetingPoint;
  int? capacity; // Aforo para actividades
  String? time; // Hora para actividades

  Post.activity({
    required this.title,
    required this.location,
    required this.description,
    required this.userId,
    required this.date,
    required this.price,
    required this.meetingPoint,
    required this.capacity,
    required this.time,
    required this.category,
  }) : type = 'activity';

  Post.review({
    required this.title,
    required this.location,
    required this.description,
    required this.userId,
    required this.category,
  }) : type = 'review';

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'location': location,
      'description': description,
      'userId': userId,
      'type': type,
      'category': category,
      'date': date?.toIso8601String(),
      'price': price,
      'meetingPoint': meetingPoint,
      'capacity': capacity,
      'time': time,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return json['type'] == 'activity'
        ? Post.activity(
            title: json['title'],
            location: json['location'],
            description: json['description'],
            userId: json['userId'],
            date: DateTime.parse(json['date']),
            price: json['price'],
            meetingPoint: json['meetingPoint'],
            capacity: json['capacity'],
            time: json['time'],
            category: json['category'],
          )
        : Post.review(
            title: json['title'],
            location: json['location'],
            description: json['description'],
            userId: json['userId'],
            category: json['category'],
          );
  }
}
