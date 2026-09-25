import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../data/practice_models.dart';
import '../providers/exam_provider.dart';
import '../widgets/math_text_render.dart';
import '../widgets/option_tile.dart';
import 'exam_result_screen.dart';

class ExamScreen extends ConsumerStatefulWidget {
  final List<Question> questions;
  final int durationMinutes;
  final bool isReviewMode;

  const ExamScreen({
    super.key,
    required this.questions,
    this.durationMinutes = 20,
    this.isReviewMode = false,
  });

  @override
  ConsumerState<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends ConsumerState<ExamScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Start exam
    if (!widget.isReviewMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(examProvider.notifier)
            .startExam(widget.questions, widget.durationMinutes);
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    if (seconds <= 0) return "00:00";
    final m = (seconds / 60).floor().toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  void _showSubmitConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_rounded,
                    color: Color(0xFF2563EB),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'পরীক্ষা জমা দিন?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'আপনি কি নিশ্চিত যে আপনি পরীক্ষা শেষ করে ফলাফল দেখতে চান?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: const Text(
                          'বাতিল',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ref.read(examProvider.notifier).submitExam();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'জমা দিন',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final examState = ref.watch(examProvider);
    final isSubmitted = examState.isSubmitted;

    // Listen to submission status to navigate to result screen
    ref.listen(examProvider.select((state) => state.isSubmitted), (
      previous,
      submitted,
    ) {
      if (submitted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ExamResultScreen()),
        );
      }
    });

    if (examState.questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Question ${_currentIndex + 1}/${examState.questions.length}',
        ),
        centerTitle: false,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: GestureDetector(
                onTap: widget.isReviewMode
                    ? () => Navigator.of(context).pop()
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (!widget.isReviewMode &&
                            examState.remainingSeconds < 300)
                        ? AppColors.error.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.isReviewMode
                            ? Icons.close
                            : Icons.timer_outlined,
                        size: 18,
                        color:
                            (!widget.isReviewMode &&
                                examState.remainingSeconds < 300)
                            ? AppColors.error
                            : Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.isReviewMode
                            ? "Close"
                            : _formatTime(examState.remainingSeconds),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              (!widget.isReviewMode &&
                                  examState.remainingSeconds < 300)
                              ? AppColors.error
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: isSubmitted
                  ? const NeverScrollableScrollPhysics()
                  : null,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemCount: examState.questions.length,
              itemBuilder: (context, index) {
                final question = examState.questions[index];
                final qSelectedOption = examState.selectedAnswers[question.id];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: MathTextRender(
                            htmlContent: question.questionHtml,
                            hasMath: question.hasMath,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(question.options.length, (optIndex) {
                        final option = question.options[optIndex];
                        return OptionTile(
                          index: optIndex,
                          optionText: option,
                          isSelected:
                              qSelectedOption == option &&
                              question.options.indexOf(option) == optIndex,
                          isCorrect: (isSubmitted || widget.isReviewMode)
                              ? option == question.answer &&
                                    question.options.indexOf(option) == optIndex
                              : false,
                          showResult: isSubmitted || widget.isReviewMode,
                          onTap: () {
                            if (widget.isReviewMode || isSubmitted) return;
                            if (qSelectedOption == option) {
                              ref
                                  .read(examProvider.notifier)
                                  .clearAnswer(question.id);
                            } else {
                              ref
                                  .read(examProvider.notifier)
                                  .selectAnswer(question.id, option);
                            }
                          },
                        );
                      }),
                      // Explanation in review mode
                      if (widget.isReviewMode &&
                          question.explanationHtml != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.4),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_rounded,
                                    size: 18,
                                    color: Color(0xFF059669),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'ব্যাখ্যা:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              MathTextRender(
                                htmlContent: question.explanationHtml!,
                                hasMath: question.hasMath,
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF064E3B),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: (isSubmitted && !widget.isReviewMode)
          ? const SizedBox.shrink()
          : Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Grid / Overview Button
                      if (!widget.isReviewMode)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Material(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.grid_view_rounded,
                                    color: AppColors.primary,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${examState.selectedAnswers.length}/${examState.questions.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox(width: 48),

                      // Navigation Buttons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_currentIndex > 0)
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                side: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                                foregroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 14,
                              ),
                              label: const Text(
                                'Prev',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              onPressed: () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          const SizedBox(width: 10),
                          if (_currentIndex < examState.questions.length - 1)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              icon: const Text(
                                'Next',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              label: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                              ),
                            ),
                          if (!widget.isReviewMode &&
                              _currentIndex == examState.questions.length - 1)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                backgroundColor: const Color(0xFF059669),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _showSubmitConfirmation,
                              icon: const Text(
                                'Submit',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              label: const Icon(
                                Icons.check_circle_outline_rounded,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
