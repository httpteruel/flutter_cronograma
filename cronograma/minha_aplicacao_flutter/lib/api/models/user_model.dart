// lib/api/models/user_model.dart

import 'package:minha_aplicacao_flutter/domain/entities/user.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String?
      password; // Apenas para requisição de registro/login, não deve ser retornada

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      // password não deve ser desserializado de uma resposta de GET
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (password != null) 'password': password,
    };
  }

  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
    );
  }
}
