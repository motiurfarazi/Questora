import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../data/practice_models.dart';
import '../providers/practice_providers.dart';
import 'exam_screen.dart';
import 'question_screen.dart';

/// Displays a list of questions for practice. Supports three modes:
/// - By [chapter]: questions for a specific chapter (with pagination).
/// - By [board]: questions filtered by board/institution (use [title] for app bar).
/// - By [year]: questions filtered by year (use [title] for app bar).
class QuestionListScreen extends ConsumerStatefulWidget {
  final Chapter? chapter;
  final String? title;
  final String? board;
  final int? year;

  const QuestionListScreen({
    super.key,
    this.chapter,
    this.title,
    this.board,
    this.year,
  }) : assert(
         (chapter != null && board == null && year == null) ||
             (chapter == null && board != null && year == null) ||
             (chapter == null && board == null && year != null),
         'Provide exactly one of: chapter, board, or year',
       );

  @override
  ConsumerState<QuestionListScreen> createState() => _QuestionListScreenState();
}

class _QuestionListScreenState extends ConsumerState<QuestionListScreen> {
  final ScrollController _scrollController = ScrollController();

  bool get _isChapterMode => widget.chapter != null;
  bool get _isBoardMode => widget.board != null;
  // Removed _isYearMode as it is unused

  String get _appBarTitle {
    if (widget.chapter != null) return widget.chapter!.name;
    return widget.title ?? '';
  }

  @override
  void initState() {
    super.initState();
    if (_isChapterMode) {
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isChapterMode) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(questionsProvider(widget.chapter!.id).notifier).fetchMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChapterMode) {
      return _buildChapterBody();
    }
    if (_isBoardMode) {
      return _buildListBody(
        questionsAsync: ref.watch(questionsByBoardProvider(widget.board!)),
        onRefresh: () => ref.refresh(questionsByBoardProvider(widget.board!)),
      );
    }
    return _buildListBody(
      questionsAsync: ref.watch(questionsByYearProvider(widget.year!)),
      onRefresh: () => ref.refresh(questionsByYearProvider(widget.year!)),
    );
  }

  Widget _buildChapterBody() {
    final questionsAsync = ref.watch(questionsProvider(widget.chapter!.id));

    return Scaffold(
      appBar: AppBar(title: Text(_appBarTitle)),
      body: questionsAsync.when(
        data: (questions) => _questionsList(
          questions: questions,
          questionsAsync: questionsAsync,
          onRefresh: () => ref.refresh(questionsProvider(widget.chapter!.id)),
          controller: _scrollController,
          hasMore: true,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
      bottomNavigationBar: _buildQuizButton(questionsAsync: questionsAsync),
    );
  }

  Widget _buildListBody({
    required AsyncValue<List<Question>> questionsAsync,
    required VoidCallback onRefresh,
  }) {
    return Scaffold(
      appBar: AppBar(title: Text(_appBarTitle)),
      body: questionsAsync.when(
        data: (questions) => _questionsList(
          questions: questions,
          questionsAsync: questionsAsync,
          onRefresh: onRefresh,
          hasMore: false,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
      bottomNavigationBar: _buildQuizButton(questionsAsync: questionsAsync),
    );
  }

  Widget _questionsList({
    required List<Question> questions,
    required AsyncValue<List<Question>> questionsAsync,
    required VoidCallback onRefresh,
    ScrollController? controller,
    required bool hasMore,
  }) {
    if (questions.isEmpty) {
      return const Center(child: Text('কোনো প্রশ্ন পাওয়া যায়নি।'));
    }
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        controller: controller,
        padding: const EdgeInsets.all(16),
        itemCount:
            questions.length + (hasMore && questionsAsync.isLoading ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == questions.length) {
            return const _CircularProgressPadding();
          }
          final question = questions[index];
          return Card(
            elevation: 1,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              title: Text(
                'প্রশ্ন ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                question.board != null && question.year != null
                    ? '${question.board} - ${question.year}'
                    : ((question.board != null || question.year != null)
                          ? '${question.year ?? question.board}'
                          : 'প্র্যাকটিস প্রশ্ন'),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              trailing: const Icon(Icons.play_arrow, color: AppColors.primary),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => QuestionScreen(
                      initialQuestions: questions,
                      startingIndex: index,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget? _buildQuizButton({
    required AsyncValue<List<Question>> questionsAsync,
  }) {
    return questionsAsync.whenOrNull(
      data: (questions) {
        if (questions.isEmpty) return null;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ExamScreen(questions: questions),
                ),
              );
            },
            child: const Text('কুইজ মোড শুরু করুন'),
          ),
        );
      },
    );
  }
}

class _CircularProgressPadding extends StatelessWidget {
  const _CircularProgressPadding();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}
