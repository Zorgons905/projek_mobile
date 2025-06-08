import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  // Create Profile
  Future<Profile> createProfile({
    required String id,
    String? role,
    String? name,
    String? bio,
    String? profilePictureUrl,
  }) async {
    final response =
        await _client
            .from('profiles')
            .insert({
              'id': id,
              'role': role,
              'name': name,
              'bio': bio,
              'profile_picture_url': profilePictureUrl,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

    return Profile.fromJson(response);
  }

  // Get Profile by ID
  Future<Profile?> getProfile(String id) async {
    final response =
        await _client.from('profiles').select().eq('id', id).maybeSingle();

    return response != null ? Profile.fromJson(response) : null;
  }

  Future<bool> isLecturer(String userId) async {
    final profile = await getProfile(userId);
    return profile?.role == 'lecturer';
  }

  // Update Profile
  Future<Profile> updateProfile({
    required String id,
    String? role,
    String? name,
    String? bio,
    String? profilePictureUrl,
  }) async {
    final response =
        await _client
            .from('profiles')
            .update({
              if (role != null) 'role': role,
              if (name != null) 'name': name,
              if (bio != null) 'bio': bio,
              'profile_picture_url': profilePictureUrl,
            })
            .eq('id', id)
            .select()
            .single();

    return Profile.fromJson(response);
  }

  // Delete Profile
  Future<void> deleteProfile(String id) async {
    await _client.from('profiles').delete().eq('id', id);
  }

  // Get All Profiles
  Future<List<Profile>> getAllProfiles() async {
    final response = await _client.from('profiles').select();
    return response.map((json) => Profile.fromJson(json)).toList();
  }

  // Get Profiles by Role
  Future<List<Profile>> getProfilesByRole(String role) async {
    final response = await _client.from('profiles').select().eq('role', role);
    return response.map((json) => Profile.fromJson(json)).toList();
  }
}

// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ProfileService {
//   final SupabaseClient _supabase = Supabase.instance.client;

//   /// Ambil data user dari tabel `profiles` berdasarkan user id
//   Future<Map<String, dynamic>?> fetchUserData() async {
//     try {
//       final user = _supabase.auth.currentUser;
//       if (user == null) return null;

//       final response =
//           await _supabase.from('profiles').select().eq('id', user.id).single();

//       return response;
//     } catch (e) {
//       debugPrint('Gagal fetch user data: $e');
//       return null;
//     }
//   }

//   /// Update field profil tertentu (misal: name, bio)
//   Future<bool> updateUserField(String field, String newValue) async {
//     try {
//       final user = _supabase.auth.currentUser;
//       if (user == null) return false;

//       await _supabase
//           .from('profiles')
//           .update({field: newValue})
//           .eq('id', user.id);

//       return true;
//     } catch (e) {
//       debugPrint('Gagal update $field: $e');
//       return false;
//     }
//   }

//   /// Logout user dari sesi saat ini
//   Future<void> signOut() async {
//     try {
//       await _supabase.auth.signOut();
//     } catch (e) {
//       debugPrint('Gagal logout: $e');
//     }
//   }

//   /// Optional: Hapus data profil (jika fitur ini dibutuhkan)
//   Future<bool> deleteProfile() async {
//     try {
//       final user = _supabase.auth.currentUser;
//       if (user == null) return false;

//       await _supabase.from('profiles').delete().eq('id', user.id);
//       return true;
//     } catch (e) {
//       debugPrint('Gagal hapus profil: $e');
//       return false;
//     }
//   }
// }
