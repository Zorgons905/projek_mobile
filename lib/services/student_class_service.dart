import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test123/models/student_class.dart';

class StudentClassService {
  final SupabaseClient _client = Supabase.instance.client;

  // Join Class (Create StudentClass)
  Future<StudentClass> joinClass({
    required String classroomId,
    required String studentId,
  }) async {
    final response =
        await _client
            .from('student_class')
            .insert({
              'classroom_id': classroomId,
              'student_id': studentId,
              'created_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

    return StudentClass.fromJson(response);
  }

  // Leave Class (Delete StudentClass)
  Future<void> leaveClass({
    required String classroomId,
    required String studentId,
  }) async {
    await _client
        .from('student_class')
        .delete()
        .eq('classroom_id', classroomId)
        .eq('student_id', studentId);
  }

  // Get Student's Classes
  Future<List<StudentClass>> getStudentClasses(String studentId) async {
    final response = await _client
        .from('student_class')
        .select()
        .eq('student_id', studentId);
    return response.map((json) => StudentClass.fromJson(json)).toList();
  }

  // Get Class Students
  Future<List<StudentClass>> getClassStudents(String classroomId) async {
    final response = await _client
        .from('student_class')
        .select()
        .eq('classroom_id', classroomId);
    return response.map((json) => StudentClass.fromJson(json)).toList();
  }

  // Check if student is in class
  Future<bool> isStudentInClass({
    required String classroomId,
    required String studentId,
  }) async {
    final response =
        await _client
            .from('student_class')
            .select('id')
            .eq('classroom_id', classroomId)
            .eq('student_id', studentId)
            .maybeSingle();

    return response != null;
  }
}
