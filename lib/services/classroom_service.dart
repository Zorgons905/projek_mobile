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
  Future<Classroom> updateClassroom({
    required String id,
    String? name,
    String? description,
  }) async {
    final response =
        await _client
            .from('classroom')
            .update({
              if (name != null) 'name': name,
              'description': description,
            })
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
