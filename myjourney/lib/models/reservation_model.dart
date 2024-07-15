class Reservation {
  String id;
  String postId;
  String userId;
  String userName;
  int numberOfParticipants;
  double totalPrice;
  String status;
  DateTime activityDate;
  String activityTime;
  String activityTitle; // Agrega el título de la actividad

  Reservation({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.numberOfParticipants,
    required this.totalPrice,
    required this.status,
    required this.activityDate,
    required this.activityTime,
    required this.activityTitle, // Inicializa el título de la actividad
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'numberOfParticipants': numberOfParticipants,
      'totalPrice': totalPrice,
      'status': status,
      'activityDate': activityDate.toIso8601String(),
      'activityTime': activityTime,
      'activityTitle': activityTitle, // Agrega el título al JSON
    };
  }

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      postId: json['postId'],
      userId: json['userId'],
      userName: json['userName'],
      numberOfParticipants: json['numberOfParticipants'],
      totalPrice: json['totalPrice'],
      status: json['status'],
      activityDate: DateTime.parse(json['activityDate']),
      activityTime: json['activityTime'],
      activityTitle: json['activityTitle'], // Lee el título del JSON
    );
  }
}
