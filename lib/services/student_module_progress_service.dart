import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test123/models/student_module_progress.dart';

class StudentModuleProgressService {
  final SupabaseClient _client = Supabase.instance.client;

  // Create or Update Progress
  Future<StudentModuleProgress> upsertProgress({
    required String studentId,
    required String moduleId,
    required double progressPercent,
  }) async {
    final response =
        await _client
            .from('student_module_progress')
            .upsert({
              'student_id': studentId,
              'module_id': moduleId,
              'progress_percent': progressPercent,
              'last_read_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

    return StudentModuleProgress.fromJson(response);
  }

  // Get Student Progress for Module
  Future<StudentModuleProgress?> getStudentModuleProgress({
    required String studentId,
    required String moduleId,
  }) async {
    final response =
        await _client
            .from('student_module_progress')
            .select()
            .eq('student_id', studentId)
            .eq('module_id', moduleId)
            .maybeSingle();

    return response != null ? StudentModuleProgress.fromJson(response) : null;
  }

  // Get All Student Progress
  Future<List<StudentModuleProgress>> getStudentProgress(
    String studentId,
  ) async {
    final response = await _client
        .from('student_module_progress')
        .select()
        .eq('student_id', studentId);
    return response
        .map((json) => StudentModuleProgress.fromJson(json))
        .toList();
  }

  // Get Module Progress by All Students
  Future<List<StudentModuleProgress>> getModuleProgress(String moduleId) async {
    final response = await _client
        .from('student_module_progress')
        .select()
        .eq('module_id', moduleId);
    return response
        .map((json) => StudentModuleProgress.fromJson(json))
        .toList();
  }
}
