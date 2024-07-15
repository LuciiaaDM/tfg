class Chat {
  String id;
  List<String> participants;

  Chat({
    required this.id,
    required this.participants,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'participants': participants,
    };
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] ?? '',
      participants: List<String>.from(json['participants'] ?? []),
    );
  }
}
