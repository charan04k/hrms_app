import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String employeeId;
  final String name;
  final String email;
  final String designation;
  final String department;
  final bool isLoggedIn;

  const UserEntity({
    required this.employeeId,
    required this.name,
    required this.email,
    required this.designation,
    required this.department,
    required this.isLoggedIn,
  });

  @override
  List<Object?> get props => [
        employeeId,
        name,
        email,
        designation,
        department,
        isLoggedIn,
      ];
}