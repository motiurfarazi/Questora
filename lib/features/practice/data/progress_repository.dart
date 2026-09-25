import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/database/local_progress_db.dart';
import 'practice_models.dart';

part 'progress_repository.g.dart';

class ProgressRepository {
  final SupabaseClient _supabase;

  ProgressRepository(this._supabase);

  /// Save progress LOCALLY to SQLite (not Supabase).
  Future<void> saveProgress(
    String questionId,
    bool isCorrect, {
    String? chapterId,
    String? chapterName,
    String? subjectId,
  }) async {
    await LocalProgressDb.saveProgress(
      questionId: questionId,
      isCorrect: isCorrect,
      chapterId: chapterId,
      chapterName: chapterName,
      subjectId: subjectId,
    );
  }

  /// Toggle bookmark LOCALLY to SQLite.
  Future<void> toggleBookmark(String questionId, bool isBookmarked) async {
    await LocalProgressDb.toggleBookmark(
      questionId,
      isCurrentlyBookmarked: isBookmarked,
    );
  }

  /// Fetch bookmarked questions from Supabase using local bookmark IDs.
  Future<List<Question>> getBookmarkedQuestions() async {
    final ids = await LocalProgressDb.getBookmarkedIds();
    if (ids.isEmpty) return [];
    final response = await _supabase
        .from('questions')
        .select()
        .inFilter('id', ids);
    return response.map((json) => Question.fromJson(json)).toList();
  }

  /// Build analytics from local SQLite data.
  Future<UserAnalytics> getUserAnalytics() async {
    final rows = await LocalProgressDb.getAllProgress();
    final mockExamRows = await LocalProgressDb.getMockExams();

    final mockExams = mockExamRows
        .map((e) => MockExamResult.fromMap(e))
        .toList();

    if (rows.isEmpty) {
      return UserAnalytics(
        totalQuestionsAttempted: 0,
        totalCorrect: 0,
        weakTopics: [],
        allTopics: [],
        mockExams: mockExams,
      );
    }

    int totalCorrect = 0;
    final topicStats = <String, Map<String, dynamic>>{};
    final chapterIdsToFetch =
        <String>{}; // Collect chapter IDs to fetch true names

    for (var row in rows) {
      final isCorrect = (row['is_correct'] as int) == 1;
      if (isCorrect) totalCorrect++;

      final chapterId = row['chapter_id'] as String?;
      if (chapterId == null) continue;

      chapterIdsToFetch.add(chapterId);

      if (!topicStats.containsKey(chapterId)) {
        topicStats[chapterId] = {'name': 'Unknown', 'total': 0, 'correct': 0};
      }

      topicStats[chapterId]!['total'] =
          (topicStats[chapterId]!['total'] as int) + 1;
      if (isCorrect) {
        topicStats[chapterId]!['correct'] =
            (topicStats[chapterId]!['correct'] as int) + 1;
      }
    }

    // Fetch chapter names from Supabase to replace 'Unknown'
    if (chapterIdsToFetch.isNotEmpty) {
      try {
        final chaptersResponse = await _supabase
            .from('chapters')
            .select('id, name')
            .inFilter('id', chapterIdsToFetch.toList());

        for (final item in chaptersResponse) {
          final id = item['id'] as String;
          final name = item['name'] as String;
          if (topicStats.containsKey(id)) {
            topicStats[id]!['name'] = name;
          }
        }
      } catch (e) {
        // If it fails (e.g., offline), we keep the default 'Unknown'
      }
    }

    final allTopics = topicStats.entries.map((e) {
      return TopicAccuracy(
        topicId: e.key,
        topicName: e.value['name'] as String,
        totalAttempted: e.value['total'] as int,
        correctCount: e.value['correct'] as int,
      );
    }).toList()..sort((a, b) => a.accuracy.compareTo(b.accuracy));

    final weakTopics = allTopics
        .where((t) => t.accuracy < 0.7)
        .take(3)
        .toList();

    return UserAnalytics(
      totalQuestionsAttempted: rows.length,
      totalCorrect: totalCorrect,
      weakTopics: weakTopics,
      allTopics: allTopics,
      mockExams: mockExams,
    );
  }

  /// Calculate daily streak from local SQLite active dates.
  Future<int> calculateDailyStreak() async {
    final sortedDates = await LocalProgressDb.getActiveDates();
    if (sortedDates.isEmpty) return 0;

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .substring(0, 10);

    final dateSet = sortedDates.toSet();
    if (!dateSet.contains(today) && !dateSet.contains(yesterday)) return 0;

    DateTime check = dateSet.contains(today)
        ? DateTime.now()
        : DateTime.now().subtract(const Duration(days: 1));

    int streak = 0;
    for (int i = 0; i < sortedDates.length; i++) {
      final expected = check.toIso8601String().substring(0, 10);
      if (sortedDates[i] == expected) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}

@riverpod
ProgressRepository progressRepository(Ref ref) {
  return ProgressRepository(Supabase.instance.client);
}
