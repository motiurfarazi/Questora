import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/practice_models.dart';
import '../../widgets/math_text_render.dart';

class FilteredQuestionCard extends StatefulWidget {
  final int index;
  final Question question;

  const FilteredQuestionCard({
    super.key,
    required this.index,
    required this.question,
  });

  @override
  State<FilteredQuestionCard> createState() => _FilteredQuestionCardState();
}

class _FilteredQuestionCardState extends State<FilteredQuestionCard> {
  bool _showAnswer = false;
  int? _selectedOptionIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.question.year != null || widget.question.board != null) ...[
                  Row(
                    children: [
                      if (widget.question.year != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${widget.question.year}',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (widget.question.board != null) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          widget.question.board!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.index}. ',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: MathTextRender(
                        htmlContent: widget.question.questionHtml,
                        hasMath: widget.question.hasMath,
                        textStyle: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.question.options.isNotEmpty)
                  ...List.generate(
                    widget.question.options.length,
                    (i) => _buildOptionRow(i, widget.question.options[i]),
                  ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _showAnswer
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(
                    width: double.infinity,
                    height: 10,
                  ),
                  secondChild: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'উত্তর:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: MathTextRender(
                            htmlContent: widget.question.answer,
                            hasMath: widget.question.hasMath,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (widget.question.explanationHtml != null &&
                            widget.question.explanationHtml!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Text(
                            'ব্যাখ্যা:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 4),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: MathTextRender(
                              htmlContent: widget.question.explanationHtml!,
                              hasMath: widget.question.hasMath,
                              textStyle: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showAnswer = !_showAnswer;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  _showAnswer ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow(int index, String optionText) {
    final labels = ['ক', 'খ', 'গ', 'ঘ'];
    final label = index < labels.length ? labels[index] : '${index + 1}';

    final isSelected = _selectedOptionIndex == index;
    final isAnswerRevealed = _selectedOptionIndex != null || _showAnswer;
    final isCorrectOption = optionText.trim() == widget.question.answer.trim();

    Color bgColor = Colors.grey.shade50;
    Color borderColor = Colors.grey.shade200;
    Color textColor = AppColors.textPrimary;
    Color circleBorderColor = AppColors.textSecondary;
    Color circleTextColor = AppColors.textSecondary;

    if (isAnswerRevealed) {
      if (isCorrectOption) {
        bgColor = Colors.green.shade50;
        borderColor = Colors.green.shade400;
        textColor = Colors.green.shade900;
        circleBorderColor = Colors.green.shade600;
        circleTextColor = Colors.green.shade900;
      } else if (isSelected) {
        bgColor = Colors.red.shade50;
        borderColor = Colors.red.shade400;
        textColor = Colors.red.shade900;
        circleBorderColor = Colors.red.shade600;
        circleTextColor = Colors.red.shade900;
      }
    }

    return GestureDetector(
      onTap: () {
        if (_selectedOptionIndex == null) {
          setState(() {
            _selectedOptionIndex = index;
            _showAnswer = true;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: circleBorderColor),
                color: (isAnswerRevealed && isCorrectOption)
                    ? Colors.green.shade100
                    : (isAnswerRevealed && isSelected && !isCorrectOption)
                    ? Colors.red.shade100
                    : Colors.transparent,
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: circleTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MathTextRender(
                htmlContent: optionText,
                hasMath: widget.question.hasMath,
                textStyle: TextStyle(fontSize: 14, color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
