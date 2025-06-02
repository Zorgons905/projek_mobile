import 'dart:math';

import '../models/classroom.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClassroomService {
  final SupabaseClient _client = Supabase.instance.client;

  // Generate 8-digit classroom code
  String _generateClassroomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        8,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  // Create Classroom
  Future<Classroom> createClassroom({
    required String name,
    String? description,
    required String lecturerId,
  }) async {
    String code;
    bool isUnique = false;

    // Generate unique code
    do {
      code = _generateClassroomCode();
      final existing =
          await _client
              .from('classroom')
              .select('id')
              .eq('code', code)
              .maybeSingle();
      isUnique = existing == null;
    } while (!isUnique);

    final response =
        await _client
            .from('classroom')
            .insert({
              'name': name,
              'code': code,
              'description': description,
              'lecturer_id': lecturerId,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

    return Classroom.fromJson(response);
  }

  // Get Classroom by ID
  Future<Classroom?> getClassroom(String id) async {
    final response =
        await _client.from('classroom').select().eq('id', id).maybeSingle();

    return response != null ? Classroom.fromJson(response) : null;
  }

  // Get Classroom by Code
  Future<Classroom?> getClassroomByCode(String code) async {
    final response =
        await _client.from('classroom').select().eq('code', code).maybeSingle();

    return response != null ? Classroom.fromJson(response) : null;
  }

  // Update Classroom
  Future<Classroom> updateClassroom({required String id, String? name}) async {
    final response =
        await _client
            .from('classroom')
            .update({if (name != null) 'name': name})
            .eq('id', id)
            .select()
            .single();

    return Classroom.fromJson(response);
  }

  // Delete Classroom
  Future<void> deleteClassroom(String id) async {
    await _client.from('classroom').delete().eq('id', id);
  }

  // Get Classrooms by Lecturer
  Future<List<Classroom>> getClassroomsByLecturer(String lecturerId) async {
    final response = await _client
        .from('classroom')
        .select()
        .eq('lecturer_id', lecturerId);
    return response.map((json) => Classroom.fromJson(json)).toList();
  }

  // Get All Classrooms
  Future<List<Classroom>> getAllClassrooms() async {
    final response = await _client.from('classroom').select();
    return response.map((json) => Classroom.fromJson(json)).toList();
  }
}

// class ClassroomService {
//   final SupabaseClient _supabase = Supabase.instance.client;

//   /// Ambil kelas yang dibuat oleh lecturer
//   Future<List<Map<String, dynamic>>> getClassroomsByLecturer(
//     String lecturerId,
//   ) async {
//     final response = await _supabase
//         .from('classroom')
//         .select()
//         .eq('lecturer_id', lecturerId);

//     return response.cast<Map<String, dynamic>>();
//   }

//   /// Ambil kelas yang diikuti student (dari relasi tabel student_class)
//   Future<List<Map<String, dynamic>>> getClassroomsByStudent(
//     String studentId,
//   ) async {
//     final response = await _supabase
//         .from('student_class')
//         .select('classroom(*)') // ambil info classroom-nya juga
//         .eq('student_id', studentId);

//     return response.cast<Map<String, dynamic>>();
//   }

//   /// Buat classroom baru
//   Future<void> createClassroom(String name, String lecturerId) async {
//     final String code = await _generateUniqueCode(8);

//     await _supabase.from('classroom').insert({
//       'name': name,
//       'code': code,
//       'lecturer_id': lecturerId,
//     });
//   }

//   Future<String> _generateUniqueCode(int length) async {
//     String code;
//     bool exists = true;
//     const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
//     final rand = Random.secure();

//     do {
//       code =
//           List.generate(
//             length,
//             (_) => chars[rand.nextInt(chars.length)],
//           ).join();
//       final res = await _supabase.from('classroom').select().eq('code', code);

//       exists = (res as List).isNotEmpty;
//     } while (exists);

//     return code;
//   }

//   /// Tambahkan student ke classroom
//   Future<void> joinClassroom(String studentId, String classroomId) async {
//     await _supabase.from('student_class').insert({
//       'classroom_id': classroomId,
//       'student_id': studentId,
//     });
//   }

//   /// Ambil detail classroom by ID
//   Future<Map<String, dynamic>> getClassroomDetail(String classroomId) async {
//     final classroomRes =
//         await _supabase
//             .from('classroom')
//             .select()
//             .eq('id', classroomId)
//             .single();

//     final modules = await _supabase
//         .from('module')
//         .select()
//         .eq('classroom_id', classroomId)
//         .order('uploaded_at', ascending: false);

//     final quizzes = await _supabase
//         .from('quiz')
//         .select()
//         .eq('classroom_id', classroomId)
//         .order('created_at', ascending: false);

//     return {...classroomRes, 'modules': modules, 'quizzes': quizzes};
//   }

//   Future<List<Map<String, dynamic>>> getStudentsInClass(
//     String classroomId,
//   ) async {
//     final response = await _supabase
//         .from('student_class')
//         .select('student_id, profiles!student_id(name, email, role)')
//         .eq('classroom_id', classroomId);

//     // Filter di kode kalau belum bisa filter role langsung di Supabase
//     final students =
//         response
//             .where((entry) => entry['profiles']['role'] == 'student')
//             .toList();

//     return students;
//   }
// }
