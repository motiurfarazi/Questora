import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../core/theme/app_colors.dart';
import '../../practice/data/practice_models.dart';

class ReviewScreen extends StatelessWidget {
  final List<Question> questions;
  final Map<String, String> userAnswers; // questionId -> option chosen

  const ReviewScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Review Answers')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, i) {
          final q = questions[i];
          final userAnswer = userAnswers[q.id];
          final isCorrect = userAnswer == q.answer;
          final wasSkipped = userAnswer == null;

          final borderColor = wasSkipped
              ? Colors.grey
              : isCorrect
              ? Colors.green
              : Colors.red;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: borderColor.withValues(alpha: 0.05),
              border: Border.all(
                color: borderColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: borderColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Q${i + 1}  •  ${wasSkipped
                              ? "Skipped"
                              : isCorrect
                              ? "Correct"
                              : "Wrong"}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Html(data: q.questionHtml),
                  const Divider(height: 24),
                  if (!wasSkipped && !isCorrect) ...[
                    _AnswerRow(
                      label: 'Your answer:',
                      value: userAnswer,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 6),
                  ],
                  _AnswerRow(
                    label: 'Correct answer:',
                    value: q.answer,
                    color: Colors.green,
                  ),
                  if (q.explanationHtml != null &&
                      q.explanationHtml!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: const Text(
                        'View Explanation',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      children: [Html(data: q.explanationHtml!)],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AnswerRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AnswerRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
