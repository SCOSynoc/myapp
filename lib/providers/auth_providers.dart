import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myapp/service/auth_service.dart';
import '../models/user.dart';


final authServiceProvider = Provider((ref) => AuthService());

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

class AuthNotifier extends StateNotifier<User?> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    state = await _authService.getCurrentUser();
  }

  Future<void> login(String email, String password) async {
    try {
      await _authService.login(email, password);
      state = await _authService.getCurrentUser();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = null;
  }
}