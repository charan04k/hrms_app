import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> login(String employeeId, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final Box userBox;

  AuthLocalDataSourceImpl({
    required this.userBox,
  });

  @override
  Future<UserModel?> login(String employeeId, String password) async {
    // Static dummy credentials check
    if (employeeId.trim().toLowerCase() == AppConstants.demoEmployeeId.toLowerCase() &&
        password == AppConstants.demoPassword) {
      final user = const UserModel(
        employeeId: AppConstants.demoEmployeeId,
        name: AppConstants.demoEmployeeName,
        email: AppConstants.demoEmail,
        designation: AppConstants.demoDesignation,
        department: AppConstants.demoDepartment,
        isLoggedIn: true,
      );

      await userBox.put(AppConstants.keyCurrentUser, user.toMap());
      return user;
    }

    return null;
  }

  @override
  Future<void> logout() async {
    await userBox.delete(AppConstants.keyCurrentUser);

  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final rawUser = userBox.get(AppConstants.keyCurrentUser);
    if (rawUser != null) {
      if (rawUser is Map) {
        return UserModel.fromMap(Map<String, dynamic>.from(rawUser));
      }
    }
    return null;
  }

  }

