import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test123/models/question.dart';

class QuestionService {
  final SupabaseClient _client = Supabase.instance.client;

  // Create Question
  Future<Question> createQuestion({
    required String quizId,
    required String content,
    required int orderNumber,
    String? pictureUrl,
  }) async {
    final response =
        await _client
            .from('question')
            .insert({
              'quiz_id': quizId,
              'content': content,
              'order_number': orderNumber,
              'picture_url': pictureUrl,
            })
            .select()
            .single();

    return Question.fromJson(response);
  }

  // Get Question by ID
  Future<Question?> getQuestion(String id) async {
    final response =
        await _client.from('question').select().eq('id', id).maybeSingle();

    return response != null ? Question.fromJson(response) : null;
  }

  // Update Question
  Future<Question> updateQuestion({
    required String id,
    String? content,
    int? orderNumber,
    String? pictureUrl,
  }) async {
    final response =
        await _client
            .from('question')
            .update({
              if (content != null) 'content': content,
              if (orderNumber != null) 'order_number': orderNumber,
              if (pictureUrl != null) 'picture_url': pictureUrl,
            })
            .eq('id', id)
            .select()
            .single();

    return Question.fromJson(response);
  }

  // Delete Question
  Future<void> deleteQuestion(String id) async {
    await _client.from('question').delete().eq('id', id);
  }

  // Get Questions by Quiz
  Future<List<Question>> getQuestionsByQuiz(String quizId) async {
    final response = await _client
        .from('question')
        .select()
        .eq('quiz_id', quizId)
        .order('order_number', ascending: true);
    return response.map((json) => Question.fromJson(json)).toList();
  }

  // Reorder Questions
  Future<void> reorderQuestions(List<Map<String, dynamic>> questions) async {
    for (final question in questions) {
      await _client
          .from('question')
          .update({'order_number': question['order_number']})
          .eq('id', question['id']);
    }
  }
}
