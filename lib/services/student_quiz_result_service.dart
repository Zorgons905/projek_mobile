import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test123/models/student_quiz_result.dart';

class StudentQuizResultService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'student_quiz_result';

  // CREATE - Tambah hasil quiz baru
  Future<StudentQuizResult?> createQuizResult(StudentQuizResult result) async {
    try {
      final response =
          await _supabase
              .from(_tableName)
              .insert(result.toJson())
              .select()
              .single();

      return StudentQuizResult.fromJson(response);
    } catch (e) {
      print('Error creating quiz result: $e');
      throw Exception('Gagal menyimpan hasil quiz: $e');
    }
  }

  // READ - Get semua hasil quiz
  Future<List<StudentQuizResult>> getAllQuizResults() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('submitted_at', ascending: false);

      return (response as List)
          .map((json) => StudentQuizResult.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting all quiz results: $e');
      throw Exception('Gagal mengambil data hasil quiz: $e');
    }
  }

  // READ - Get hasil quiz berdasarkan ID
  Future<StudentQuizResult?> getQuizResultById(String id) async {
    try {
      final response =
          await _supabase.from(_tableName).select().eq('id', id).single();

      return StudentQuizResult.fromJson(response);
    } catch (e) {
      print('Error getting quiz result by id: $e');
      return null;
    }
  }

  // READ - Get hasil quiz berdasarkan student ID
  Future<List<StudentQuizResult>> getQuizResultsByStudentId(
    String studentId,
  ) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('student_id', studentId)
          .order('submitted_at', ascending: false);

      return (response as List)
          .map((json) => StudentQuizResult.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting quiz results by student id: $e');
      throw Exception('Gagal mengambil hasil quiz mahasiswa: $e');
    }
  }

  // READ - Get hasil quiz berdasarkan quiz ID
  Future<List<StudentQuizResult>> getQuizResultsByQuizId(String quizId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('quiz_id', quizId)
          .order('submitted_at', ascending: false);

      return (response as List)
          .map((json) => StudentQuizResult.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting quiz results by quiz id: $e');
      throw Exception('Gagal mengambil hasil quiz: $e');
    }
  }

  // READ - Get hasil quiz specific student untuk specific quiz
  Future<StudentQuizResult?> getStudentQuizResult(
    String studentId,
    String quizId,
  ) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('student_id', studentId)
          .eq('quiz_id', quizId)
          .order('submitted_at', ascending: false)
          .limit(1);

      if (response.isEmpty) return null;

      return StudentQuizResult.fromJson(response.first);
    } catch (e) {
      print('Error getting student quiz result: $e');
      return null;
    }
  }

  // READ - Get statistik quiz (rata-rata, min, max score)
  Future<Map<String, dynamic>> getQuizStatistics(String quizId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('score')
          .eq('quiz_id', quizId);

      if (response.isEmpty) {
        return {
          'total_submissions': 0,
          'average_score': 0.0,
          'min_score': 0.0,
          'max_score': 0.0,
        };
      }

      final scores =
          (response as List)
              .map((r) => (r['score'] as num).toDouble())
              .toList();

      return {
        'total_submissions': scores.length,
        'average_score': scores.reduce((a, b) => a + b) / scores.length,
        'min_score': scores.reduce((a, b) => a < b ? a : b),
        'max_score': scores.reduce((a, b) => a > b ? a : b),
      };
    } catch (e) {
      print('Error getting quiz statistics: $e');
      throw Exception('Gagal mengambil statistik quiz: $e');
    }
  }

  // UPDATE - Update hasil quiz
  Future<StudentQuizResult?> updateQuizResult(
    String id,
    StudentQuizResult updatedResult,
  ) async {
    try {
      final response =
          await _supabase
              .from(_tableName)
              .update(updatedResult.toJson())
              .eq('id', id)
              .select()
              .single();

      return StudentQuizResult.fromJson(response);
    } catch (e) {
      print('Error updating quiz result: $e');
      throw Exception('Gagal mengupdate hasil quiz: $e');
    }
  }

  // UPDATE - Update score saja
  Future<bool> updateScore(String id, double newScore) async {
    try {
      await _supabase.from(_tableName).update({'score': newScore}).eq('id', id);

      return true;
    } catch (e) {
      print('Error updating score: $e');
      return false;
    }
  }

  // DELETE - Hapus hasil quiz berdasarkan ID
  Future<bool> deleteQuizResult(String id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);

      return true;
    } catch (e) {
      print('Error deleting quiz result: $e');
      return false;
    }
  }

  // DELETE - Hapus semua hasil quiz untuk quiz tertentu
  Future<bool> deleteQuizResultsByQuizId(String quizId) async {
    try {
      await _supabase.from(_tableName).delete().eq('quiz_id', quizId);

      return true;
    } catch (e) {
      print('Error deleting quiz results by quiz id: $e');
      return false;
    }
  }

  // DELETE - Hapus semua hasil quiz untuk student tertentu
  Future<bool> deleteQuizResultsByStudentId(String studentId) async {
    try {
      await _supabase.from(_tableName).delete().eq('student_id', studentId);

      return true;
    } catch (e) {
      print('Error deleting quiz results by student id: $e');
      return false;
    }
  }

  // UTILITY - Cek apakah student sudah mengerjakan quiz
  Future<bool> hasStudentTakenQuiz(String studentId, String quizId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('id')
          .eq('student_id', studentId)
          .eq('quiz_id', quizId)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      print('Error checking if student has taken quiz: $e');
      return false;
    }
  }

  // UTILITY - Get ranking mahasiswa dalam quiz
  Future<List<Map<String, dynamic>>> getQuizRanking(String quizId) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            profiles!student_quiz_result_student_id_fkey(name)
          ''')
          .eq('quiz_id', quizId)
          .order('score', ascending: false)
          .order('submitted_at', ascending: true);

      return (response as List).asMap().entries.map((entry) {
        final index = entry.key;
        final result = entry.value;

        return {
          'rank': index + 1,
          'student_name': result['profiles']?['name'] ?? 'Unknown',
          'score': result['score'],
          'submitted_at': result['submitted_at'],
        };
      }).toList();
    } catch (e) {
      print('Error getting quiz ranking: $e');
      throw Exception('Gagal mengambil ranking quiz: $e');
    }
  }

  // UTILITY - Get riwayat quiz mahasiswa dengan info quiz
  Future<List<Map<String, dynamic>>> getStudentQuizHistory(
    String studentId,
  ) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select('''
            *,
            quiz!student_quiz_result_quiz_id_fkey(title, classroom_id)
          ''')
          .eq('student_id', studentId)
          .order('submitted_at', ascending: false);

      return (response as List).map((result) {
        return {
          'id': result['id'],
          'quiz_title': result['quiz']?['title'] ?? 'Unknown Quiz',
          'classroom_id': result['quiz']?['classroom_id'],
          'score': result['score'],
          'submitted_at': result['submitted_at'],
        };
      }).toList();
    } catch (e) {
      print('Error getting student quiz history: $e');
      throw Exception('Gagal mengambil riwayat quiz mahasiswa: $e');
    }
  }
}
