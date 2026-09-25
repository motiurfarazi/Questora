import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../data/practice_models.dart';
import '../data/progress_repository.dart';
import '../widgets/question_card.dart';

class QuestionScreen extends ConsumerStatefulWidget {
  final List<Question> initialQuestions;
  final int startingIndex;

  const QuestionScreen({
    super.key,
    required this.initialQuestions,
    this.startingIndex = 0,
  });

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final Set<String> _bookmarkedIds = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startingIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleAnswerSubmitted(bool isCorrect, Question question) {
    ref
        .read(progressRepositoryProvider)
        .saveProgress(
          question.id,
          isCorrect,
          chapterId: question.chapterId,
          subjectId: question.subjectId,
        );
  }

  void _toggleBookmark(Question question) {
    final isBookmarked = _bookmarkedIds.contains(question.id);

    setState(() {
      if (isBookmarked) {
        _bookmarkedIds.remove(question.id);
      } else {
        _bookmarkedIds.add(question.id);
      }
    });

    ref
        .read(progressRepositoryProvider)
        .toggleBookmark(question.id, isBookmarked);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentIndex + 1) / widget.initialQuestions.length;
    final currentQuestion = widget.initialQuestions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${_currentIndex + 1} of ${widget.initialQuestions.length}',
        ),
        actions: [
          IconButton(
            icon: Icon(
              _bookmarkedIds.contains(currentQuestion.id)
                  ? Icons.bookmark
                  : Icons.bookmark_border,
            ),
            onPressed: () => _toggleBookmark(currentQuestion),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemCount: widget.initialQuestions.length,
              itemBuilder: (context, index) {
                final question = widget.initialQuestions[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: QuestionCard(
                    question: question,
                    isPracticeMode: true,
                    onAnswerSubmitted: (isCorrect) =>
                        _handleAnswerSubmitted(isCorrect, question),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: _currentIndex > 0
                  ? () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Previous'),
            ),
            TextButton.icon(
              onPressed: _currentIndex < widget.initialQuestions.length - 1
                  ? () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Next'),
              iconAlignment: IconAlignment.end,
            ),
          ],
        ),
      ),
    );
  }
}
