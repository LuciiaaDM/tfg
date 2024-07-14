class UserModel {
  String uid;
  String username;
  String email;
  String residence;
  String phoneNumber;
  String? additionalInfo;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.residence,
    required this.phoneNumber,
    this.additionalInfo,
  });

  // Convert a UserModel object into a map
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'residence': residence,
      'phoneNumber': phoneNumber,
      'additionalInfo': additionalInfo,
    };
  }

  // Create a UserModel object from a map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      username: json['username'],
      email: json['email'],
      residence: json['residence'],
      phoneNumber: json['phoneNumber'],
      additionalInfo: json['additionalInfo'],
    );
  }
}
