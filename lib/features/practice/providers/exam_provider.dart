import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/practice_models.dart';
import '../../../core/database/local_progress_db.dart';
import 'practice_providers.dart';

part 'exam_provider.g.dart';

class ExamState {
  final List<Question> questions;
  final Map<String, String> selectedAnswers;
  final int remainingSeconds;
  final int durationMinutes;
  final bool isSubmitted;

  ExamState({
    required this.questions,
    required this.selectedAnswers,
    required this.remainingSeconds,
    required this.durationMinutes,
    this.isSubmitted = false,
  });

  ExamState copyWith({
    List<Question>? questions,
    Map<String, String>? selectedAnswers,
    int? remainingSeconds,
    int? durationMinutes,
    bool? isSubmitted,
  }) {
    return ExamState(
      questions: questions ?? this.questions,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }

  int get correctCount {
    int count = 0;
    for (var q in questions) {
      if (selectedAnswers[q.id] == q.answer) count++;
    }
    return count;
  }

  int get incorrectCount {
    int count = 0;
    for (var q in questions) {
      if (selectedAnswers.containsKey(q.id) &&
          selectedAnswers[q.id] != q.answer) {
        count++;
      }
    }
    return count;
  }

  int get skippedCount => questions.length - selectedAnswers.length;
  double get score => correctCount - (incorrectCount * 0.25);
}

@riverpod
class ExamNotifier extends _$ExamNotifier {
  Timer? _timer;

  @override
  ExamState build() {
    ref.onDispose(() => _timer?.cancel());
    return ExamState(
      questions: [],
      selectedAnswers: {},
      remainingSeconds: 0,
      durationMinutes: 0,
      isSubmitted: false,
    );
  }

  void startExam(List<Question> questions, int durationMinutes) {
    if (questions.isEmpty) return;

    // The original code had shuffling and limiting to 20 questions.
    // The instruction implies removing this and using the questions directly.
    // final examQuestions = List<Question>.from(questions)..shuffle();
    // final limitedQuestions = examQuestions.take(20).toList();

    state = ExamState(
      questions: questions, // Using questions directly as per instruction
      selectedAnswers: {},
      remainingSeconds: durationMinutes * 60,
      durationMinutes: durationMinutes,
      isSubmitted: false,
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer timer) {
    if (state.remainingSeconds > 0) {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    } else {
      timer.cancel();
      if (!state.isSubmitted) {
        submitExam();
      }
    }
  }

  void selectAnswer(String questionId, String option) {
    if (state.isSubmitted) return;
    final updatedAnswers = Map<String, String>.from(state.selectedAnswers);
    updatedAnswers[questionId] = option;
    state = state.copyWith(selectedAnswers: updatedAnswers);
  }

  void clearAnswer(String questionId) {
    if (state.isSubmitted) return;
    final updatedAnswers = Map<String, String>.from(state.selectedAnswers);
    updatedAnswers.remove(questionId);
    state = state.copyWith(selectedAnswers: updatedAnswers);
  }

  Future<void> submitExam() async {
    _timer?.cancel();
    state = state.copyWith(isSubmitted: true);

    // Save every attempted question's result to local SQLite
    for (final question in state.questions) {
      final selected = state.selectedAnswers[question.id];
      if (selected == null) continue; // skip unanswered
      final isCorrect = selected == question.answer;
      await LocalProgressDb.saveProgress(
        questionId: question.id,
        isCorrect: isCorrect,
        chapterId: question.chapterId,
        subjectId: question.subjectId,
      );
    }

    // Invalidate progress providers so the UI updates
    ref.invalidate(userAnalyticsProvider);
    ref.invalidate(dailyStreakProvider);

    // Save Mock Exam record summary
    final int durationSeconds =
        (state.durationMinutes * 60) - state.remainingSeconds;

    // Auto-generate title based on mock index (or you can pass a specific title)
    // We fetch current count to guess a title:
    final existingMocks = await LocalProgressDb.getMockExams();
    final mockIndex = existingMocks.length + 1;
    final String title = 'Mock - ${mockIndex.toString().padLeft(2, '0')}';

    const String examType = 'mock';

    await LocalProgressDb.saveMockExam(
      examType: examType,
      title: title,
      totalQuestions: state.questions.length,
      correct: state.correctCount,
      wrong: state.incorrectCount,
      skipped: state.skippedCount,
      durationSeconds: durationSeconds,
    );

    // Re-invalidate after mock is saved
    ref.invalidate(userAnalyticsProvider);
  }
}
