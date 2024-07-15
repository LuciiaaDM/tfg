import 'package:cloud_firestore/cloud_firestore.dart';

class Incidence {
  String id;
  String category;
  String description;
  String reportedBy;
  String? userId;
  String status;
  Timestamp timestamp;

  Incidence({
    required this.id,
    required this.category,
    required this.description,
    required this.reportedBy,
    this.userId,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'reportedBy': reportedBy,
      'userId': userId,
      'status': status,
      'timestamp': timestamp,
    };
  }

  factory Incidence.fromJson(Map<String, dynamic> json) {
    return Incidence(
      id: json['id'],
      category: json['category'],
      description: json['description'],
      reportedBy: json['reportedBy'],
      userId: json['userId'],
      status: json['status'],
      timestamp: json['timestamp'],
    );
  }
}
