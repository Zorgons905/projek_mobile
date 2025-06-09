import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    final res = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return res;
  }

  // Sign up
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
    String username,
  ) async {
    final res = await _supabase.auth.signUp(email: email, password: password);
    if (res.user != null) {
      await _supabase.from('profiles').insert({
        'id': res.user!.id,
        'role': 'student',
        'name': username,
      });
    }
    return res;
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  String? getCurrentUserEmail() {
    return _supabase.auth.currentUser?.email;
  }

  String getCurrentUserID() {
    return _supabase.auth.currentUser!.id;
  }

  /// ✅ Change password with re-authentication
  Future<void> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // Step 1: Re-authenticate
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: oldPassword,
      );

      if (res.user == null) {
        throw Exception("Password lama salah.");
      }

      // Step 2: Update password
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw Exception("Gagal mengganti password: $e");
    }
  }
}
