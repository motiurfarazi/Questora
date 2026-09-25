import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../data/practice_models.dart';
import 'math_text_render.dart';
import 'option_tile.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final bool isPracticeMode;
  final Function(bool isCorrect) onAnswerSubmitted;

  const QuestionCard({
    super.key,
    required this.question,
    required this.isPracticeMode,
    required this.onAnswerSubmitted,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  String? _selectedOption;
  bool _isSubmitted = false;
  bool _showExplanation = false;

  void _selectOption(String option) {
    if (_isSubmitted) return;
    setState(() {
      _selectedOption = option;
    });
  }

  void _submitAnswer() {
    if (_selectedOption == null) return;

    setState(() {
      _isSubmitted = true;
    });

    final isCorrect = _selectedOption == widget.question.answer;
    widget.onAnswerSubmitted(isCorrect);
  }

  @override
  void didUpdateWidget(covariant QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      // Reset state for new question
      setState(() {
        _selectedOption = null;
        _isSubmitted = false;
        _showExplanation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: MathTextRender(
              htmlContent: widget.question.questionHtml,
              hasMath: widget.question.hasMath,
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(widget.question.options.length, (i) {
          String optionText = widget.question.options[i];
          bool isSelected =
              _selectedOption == optionText &&
              widget.question.options.indexOf(optionText) == i;
          bool isCorrect =
              optionText == widget.question.answer &&
              widget.question.options.indexOf(optionText) == i;

          return OptionTile(
            index: i,
            optionText: optionText,
            isSelected: isSelected,
            isCorrect: isCorrect,
            showResult: widget.isPracticeMode && _isSubmitted,
            onTap: () {
              if (!_isSubmitted) {
                _selectOption(optionText);
              }
            },
          );
        }),

        const SizedBox(height: 24),
        if (!_isSubmitted)
          ElevatedButton(
            onPressed: _selectedOption == null ? null : _submitAnswer,
            child: const Text('Submit Answer'),
          )
        else if (widget.isPracticeMode) ...[
          if (widget.question.explanationHtml != null)
            TextButton.icon(
              onPressed: () {
                setState(() => _showExplanation = !_showExplanation);
              },
              icon: Icon(
                _showExplanation ? Icons.visibility_off : Icons.visibility,
              ),
              label: Text(
                _showExplanation ? 'Hide Explanation' : 'View Explanation',
              ),
            ),
          if (_showExplanation && widget.question.explanationHtml != null)
            Card(
              color: AppColors.primary.withValues(alpha: 0.05),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: MathTextRender(
                  htmlContent: widget.question.explanationHtml!,
                  hasMath: widget.question.hasMath,
                ),
              ),
            ),
        ],
      ],
    );
  }
}
