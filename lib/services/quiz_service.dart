import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz.dart';

class QuizService {
  final SupabaseClient _client = Supabase.instance.client;

  // Create Quiz
  Future<Quiz> createQuiz({
    required String classroomId,
    required String title,
    bool isRandomizeQuestion = false,
    bool isRandomizeAnswer = false,
  }) async {
    final response =
        await _client
            .from('quiz')
            .insert({
              'classroom_id': classroomId,
              'title': title,
              'created_at': DateTime.now().toIso8601String(),
              'is_randomize_question': isRandomizeQuestion,
              'is_randomize_answer': isRandomizeAnswer,
            })
            .select()
            .single();

    return Quiz.fromJson(response);
  }

  // Get Quiz by ID
  Future<Quiz?> getQuiz(String id) async {
    final response =
        await _client.from('quiz').select().eq('id', id).maybeSingle();

    return response != null ? Quiz.fromJson(response) : null;
  }

  // Update Quiz
  Future<Quiz> updateQuiz({
    required String id,
    String? title,
    bool? isRandomizeQuestion,
    bool? isRandomizeAnswer,
  }) async {
    final response =
        await _client
            .from('quiz')
            .update({
              if (title != null) 'title': title,
              if (isRandomizeQuestion != null)
                'is_randomize_question': isRandomizeQuestion,
              if (isRandomizeAnswer != null)
                'is_randomize_answer': isRandomizeAnswer,
            })
            .eq('id', id)
            .select()
            .single();

    return Quiz.fromJson(response);
  }

  // Delete Quiz
  Future<void> deleteQuiz(String id) async {
    await _client.from('quiz').delete().eq('id', id);
  }

  // Get Quizzes by Classroom
  Future<List<Quiz>> getQuizzesByClassroom(String classroomId) async {
    final response = await _client
        .from('quiz')
        .select()
        .eq('classroom_id', classroomId)
        .order('created_at', ascending: false);
    return response.map((json) => Quiz.fromJson(json)).toList();
  }
}
