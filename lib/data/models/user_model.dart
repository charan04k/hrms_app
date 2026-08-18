import 'dart:convert';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.employeeId,
    required super.name,
    required super.email,
    required super.designation,
    required super.department,
    required super.isLoggedIn,
  });

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      employeeId: entity.employeeId,
      name: entity.name,
      email: entity.email,
      designation: entity.designation,
      department: entity.department,
      isLoggedIn: entity.isLoggedIn,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      employeeId: map['employeeId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      designation: map['designation'] as String? ?? '',
      department: map['department'] as String? ?? '',
      isLoggedIn: map['isLoggedIn'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'name': name,
      'email': email,
      'designation': designation,
      'department': department,
      'isLoggedIn': isLoggedIn,
    };
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}