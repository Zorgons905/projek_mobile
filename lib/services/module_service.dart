import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test123/models/module.dart';

class ModuleService {
  final SupabaseClient _client = Supabase.instance.client;

  // Create Module
  Future<Module> createModule({
    required String classroomId,
    required String title,
    String? fileUrl,
    String? fileType,
  }) async {
    final response =
        await _client
            .from('module')
            .insert({
              'classroom_id': classroomId,
              'title': title,
              'file_url': fileUrl,
              'file_type': fileType,
              'uploaded_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

    return Module.fromJson(response);
  }

  // Get Module by ID
  Future<Module?> getModule(String id) async {
    final response =
        await _client.from('module').select().eq('id', id).maybeSingle();

    return response != null ? Module.fromJson(response) : null;
  }

  // Update Module
  Future<Module> updateModule({
    required String id,
    String? title,
    String? fileUrl,
    String? fileType,
  }) async {
    final response =
        await _client
            .from('module')
            .update({
              if (title != null) 'title': title,
              if (fileUrl != null) 'file_url': fileUrl,
              if (fileType != null) 'file_type': fileType,
            })
            .eq('id', id)
            .select()
            .single();

    return Module.fromJson(response);
  }

  // Delete Module
  Future<void> deleteModule(String id) async {
    await _client.from('module').delete().eq('id', id);
  }

  // Get Modules by Classroom
  Future<List<Module>> getModulesByClassroom(String classroomId) async {
    final response = await _client
        .from('module')
        .select()
        .eq('classroom_id', classroomId)
        .order('uploaded_at', ascending: false);
    return response.map((json) => Module.fromJson(json)).toList();
  }
}
