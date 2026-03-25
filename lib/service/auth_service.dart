import 'package:hive/hive.dart';
import '../models/user.dart';

class AuthService {
  static const String userBoxName = 'userBox';

  Future<void> login(String email, String password) async {




    if (email.isNotEmpty && password.isNotEmpty) {
      final box = Hive.box<User>(userBoxName);
      final user = User(email: email, isLoggedIn: true);
      await box.put('currentUser', user);
    } else {
      throw Exception('Invalid credentials');
    }
  }

  Future<void> logout() async {
    final box = Hive.box<User>(userBoxName);
    await box.delete('currentUser');
  }

  Future<User?> getCurrentUser() async {
    final box = Hive.box<User>(userBoxName);
    return box.get('currentUser');
  }
}