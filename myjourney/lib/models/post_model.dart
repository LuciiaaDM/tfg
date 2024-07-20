class Post {
  String id;
  String title;
  String location;
  String description;
  String userId;
  String userName; 
  String type;
  DateTime? date;
  double? price;
  String? meetingPoint;
  int? capacity;
  int? availableSeats; 
  String category;
  String? time;

  Post.activity({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.userId,
    required this.userName, 
    required this.date,
    required this.price,
    required this.meetingPoint,
    required this.capacity,
    required this.availableSeats,
    required this.category,
    this.time,
  }) : type = 'Actividad';

  Post.review({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.userId,
    required this.userName, 
    required this.category,
  }) : type = 'Reseña';

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
      'availableSeats': availableSeats,
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
            availableSeats: json['availableSeats'], 
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
