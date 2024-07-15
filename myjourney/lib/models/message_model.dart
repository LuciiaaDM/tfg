import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String senderId;
  String text;
  Timestamp timestamp;

  Message({
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      senderId: json['senderId'] ?? '',
      text: json['text'] ?? '',
      timestamp: json['timestamp'] as Timestamp,
    );
  }
}
