import 'dart:convert';

class UserModel {
  final String uuid;
  final String name;
  final String firstName;
  final String email;
  final String photoUrl;

  UserModel({
    required this.uuid,
    required this.name,
    required this.firstName,
    required this.email,
    required this.photoUrl,
  });

  // Converte um Map (JSON) para um objeto UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uuid: json['uuid'],
      name: json['name'],
      firstName: json['first_name'],
      email: json['email'],
      photoUrl: json['photoUrl'],
    );
  }

  // Converte um objeto UserModel para um Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'first_name': firstName,
      'email': email,
      'photoUrl': photoUrl,
    };
  }
}
