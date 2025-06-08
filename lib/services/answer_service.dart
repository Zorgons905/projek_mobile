import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/answer.dart';

class AnswerService {
  final SupabaseClient _client = Supabase.instance.client;

  // Create Answer
  Future<Answer> createAnswer({
    required String questionId,
    required String content,
    required bool isCorrect,
  }) async {
    final response =
        await _client
            .from('answer')
            .insert({
              'question_id': questionId,
              'content': content,
              'is_correct': isCorrect,
            })
            .select()
            .single();

    return Answer.fromJson(response);
  }

  // Get Answer by ID
  Future<Answer?> getAnswer(String id) async {
    final response =
        await _client.from('answer').select().eq('id', id).maybeSingle();

    return response != null ? Answer.fromJson(response) : null;
  }

  // Update Answer
  Future<Answer> updateAnswer({
    required String id,
    String? content,
    bool? isCorrect,
  }) async {
    final response =
        await _client
            .from('answer')
            .update({
              if (content != null) 'content': content,
              if (isCorrect != null) 'is_correct': isCorrect,
            })
            .eq('id', id)
            .select()
            .single();

    return Answer.fromJson(response);
  }

  // Delete Answer
  Future<void> deleteAnswer(String id) async {
    await _client.from('answer').delete().eq('id', id);
  }

  // Get Answers by Question
  Future<List<Answer>> getAnswersByQuestion(String questionId) async {
    final response = await _client
        .from('answer')
        .select()
        .eq('question_id', questionId);
    return response.map((json) => Answer.fromJson(json)).toList();
  }

  // Get Correct Answer for Question
  Future<Answer?> getCorrectAnswer(String questionId) async {
    final response =
        await _client
            .from('answer')
            .select()
            .eq('question_id', questionId)
            .eq('is_correct', true)
            .maybeSingle();

    return response != null ? Answer.fromJson(response) : null;
  }
}
