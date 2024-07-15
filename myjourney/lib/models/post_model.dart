class Post {
  String id;
  String title;
  String location;
  String description;
  String userId;
  String userName; // Agregado el nombre del usuario
  String type;
  DateTime? date;
  double? price;
  String? meetingPoint;
  int? capacity;
  String category;
  String? time;

  Post.activity({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.userId,
    required this.userName, // Inicializa el nombre del usuario
    required this.date,
    required this.price,
    required this.meetingPoint,
    required this.capacity,
    required this.category,
    this.time,
  }) : type = 'activity';

  Post.review({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.userId,
    required this.userName, // Inicializa el nombre del usuario
    required this.category,
  }) : type = 'review';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'description': description,
      'userId': userId,
      'userName': userName,
      'type': type,
      'date': date?.toIso8601String(),
      'price': price,
      'meetingPoint': meetingPoint,
      'capacity': capacity,
      'category': category,
      'time': time,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return json['type'] == 'activity'
        ? Post.activity(
            id: json['id'],
            title: json['title'],
            location: json['location'],
            description: json['description'],
            userId: json['userId'],
            userName: json['userName'],
            date: DateTime.parse(json['date']),
            price: json['price'],
            meetingPoint: json['meetingPoint'],
            capacity: json['capacity'],
            category: json['category'],
            time: json['time'],
          )
        : Post.review(
            id: json['id'],
            title: json['title'],
            location: json['location'],
            description: json['description'],
            userId: json['userId'],
            userName: json['userName'],
            category: json['category'],
          );
  }
}
