import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'practice_models.dart';

part 'question_repository.g.dart';

class QuestionRepository {
  final SupabaseClient _supabase;

  QuestionRepository(this._supabase);

  Future<List<Subject>> getSubjects() async {
    final response = await _supabase.from('subjects').select().order('name');
    return response.map((json) => Subject.fromJson(json)).toList();
  }

  Future<List<Chapter>> getChapters(String subjectId) async {
    final response = await _supabase
        .from('chapters')
        .select()
        .eq('subject_id', subjectId)
        .order('order_no');
    return response.map((json) => Chapter.fromJson(json)).toList();
  }

  Future<List<Question>> getQuestionsByChapter(
    String chapterId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _supabase
        .from('questions')
        .select()
        .eq('chapter_id', chapterId)
        .range(offset, offset + limit - 1);
    return response.map((json) => Question.fromJson(json)).toList();
  }

  /// Fetch questions filtered by board (e.g. institution name).
  Future<List<Question>> getQuestionsByBoard(String board) async {
    final response = await _supabase
        .from('questions')
        .select()
        .eq('board', board)
        .order('year', ascending: false);
    return response.map((json) => Question.fromJson(json)).toList();
  }

  /// Fetch questions filtered by year.
  Future<List<Question>> getQuestionsByYear(int year) async {
    final response = await _supabase
        .from('questions')
        .select()
        .eq('year', year)
        .order('board');
    return response.map((json) => Question.fromJson(json)).toList();
  }

  /// Fetch questions by board + year + optional subject (for timed exam mode).
  Future<List<Question>> getQuestionsByBoardAndYear({
    required String board,
    required int year,
    String? subjectId,
  }) async {
    var query = _supabase
        .from('questions')
        .select()
        .eq('board', board)
        .eq('year', year);
    if (subjectId != null) {
      query = query.eq('subject_id', subjectId);
    }
    final response = await query.order('chapter_id');
    return response.map((json) => Question.fromJson(json)).toList();
  }

  Future<List<Question>> getBookmarkedQuestions(String userId) async {
    // Supabase will automatically map the relation between bookmarks and questions
    final response = await _supabase
        .from('bookmarks')
        .select('questions(*)')
        .eq('user_id', userId);

    return response.map((e) => Question.fromJson(e['questions'])).toList();
  }

  /// Fetch random questions for a mock exam.
  /// If [subjectId] is null, questions are picked from ALL subjects.
  Future<List<Question>> getMockExamQuestions({
    String? subjectId,
    List<String>? chapterIds,
    int limit = 30,
  }) async {
    var query = _supabase.from('questions').select();
    if (subjectId != null) {
      query = query.eq('subject_id', subjectId);
    }
    if (chapterIds != null && chapterIds.isNotEmpty) {
      query = query.inFilter('chapter_id', chapterIds);
    }
    // Fetch candidate questions and randomize selection
    final response = await query.limit(limit * 3);
    final all = response.map((json) => Question.fromJson(json)).toList()
      ..shuffle();
    return all.take(limit).toList();
  }
}

@riverpod
QuestionRepository questionRepository(Ref ref) {
  return QuestionRepository(Supabase.instance.client);
}
