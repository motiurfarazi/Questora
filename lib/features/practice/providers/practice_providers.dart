import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/practice_models.dart';
import '../data/question_repository.dart';
import '../data/progress_repository.dart';

part 'practice_providers.g.dart';

@riverpod
Future<List<Subject>> subjects(Ref ref) async {
  final repo = ref.watch(questionRepositoryProvider);
  return repo.getSubjects();
}

@riverpod
Future<List<Chapter>> chaptersBySubject(Ref ref, String subjectId) async {
  final repo = ref.watch(questionRepositoryProvider);
  return repo.getChapters(subjectId);
}

@riverpod
class QuestionsNotifier extends _$QuestionsNotifier {
  @override
  Future<List<Question>> build(String chapterId) async {
    final repo = ref.watch(questionRepositoryProvider);
    return repo.getQuestionsByChapter(chapterId);
  }

  Future<void> fetchMore() async {
    if (state.isLoading) return;

    final currentQuestions = state.value ?? [];
    final repo = ref.read(questionRepositoryProvider);

    state = const AsyncLoading();

    try {
      final moreQuestions = await repo.getQuestionsByChapter(
        chapterId,
        offset: currentQuestions.length,
      );
      state = AsyncData([...currentQuestions, ...moreQuestions]);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}

@riverpod
Future<List<Question>> bookmarkedQuestions(Ref ref) async {
  final repo = ref.watch(progressRepositoryProvider);
  return repo.getBookmarkedQuestions();
}

@riverpod
Future<List<Question>> questionsByBoard(Ref ref, String board) async {
  final repo = ref.watch(questionRepositoryProvider);
  return repo.getQuestionsByBoard(board);
}

@riverpod
Future<List<Question>> questionsByYear(Ref ref, int year) async {
  final repo = ref.watch(questionRepositoryProvider);
  return repo.getQuestionsByYear(year);
}

@riverpod
Future<UserAnalytics> userAnalytics(Ref ref) async {
  final repo = ref.watch(progressRepositoryProvider);
  return repo.getUserAnalytics();
}

@riverpod
Future<int> dailyStreak(Ref ref) async {
  final repo = ref.watch(progressRepositoryProvider);
  return repo.calculateDailyStreak();
}
