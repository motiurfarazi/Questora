import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'math_text_render.dart';

class OptionTile extends StatelessWidget {
  final int index;
  final String optionText;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;
  final VoidCallback onTap;

  const OptionTile({
    super.key,
    required this.index,
    required this.optionText,
    required this.isSelected,
    this.isCorrect = false,
    this.showResult = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.border;
    Color backgroundColor = Colors.white;
    Color textColor = AppColors.textPrimary;

    if (showResult) {
      if (isCorrect) {
        borderColor = AppColors.success;
        backgroundColor = AppColors.success.withValues(alpha: 0.1);
        textColor = AppColors.success;
      } else if (isSelected && !isCorrect) {
        borderColor = AppColors.error;
        backgroundColor = AppColors.error.withValues(alpha: 0.08);
        textColor = AppColors.error;
      }
    } else if (isSelected) {
      borderColor = AppColors.primary;
      backgroundColor = AppColors.primary.withValues(alpha: 0.05);
      textColor = AppColors.primary;
    }

    // Map index to Bengali letters: 0 -> ক, 1 -> খ, 2 -> গ, 3 -> ঘ
    const banglaLetters = ['ক', 'খ', 'গ', 'ঘ', 'ঙ', 'চ'];
    final letter = index >= 0 && index < banglaLetters.length
        ? banglaLetters[index]
        : '${index + 1}';

    // Auto-detect inline LaTeX in the option text
    final hasMath =
        optionText.contains(r'$') ||
        optionText.contains(r'\(') ||
        optionText.contains(r'\[');

    return GestureDetector(
      onTap: showResult ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected || (showResult && (isCorrect || isSelected))
                ? 1.5
                : 1,
          ),
        ),
        child: Row(
          children: [
            // Alphabet circle (e.g., ক, খ)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (showResult && isCorrect)
                    ? AppColors.success
                    : (showResult && isSelected && !isCorrect)
                    ? AppColors.error
                    : isSelected
                    ? AppColors.primary
                    : Colors.transparent,
                border: Border.all(
                  color: (showResult && isCorrect)
                      ? AppColors.success
                      : (showResult && isSelected && !isCorrect)
                      ? AppColors.error
                      : isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color:
                      (showResult &&
                              (isCorrect || (isSelected && !isCorrect))) ||
                          isSelected
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: MathTextRender(
                htmlContent: optionText,
                hasMath: hasMath,
                textStyle: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (showResult && isCorrect) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 22,
              ),
            ],
            if (showResult && isSelected && !isCorrect) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.cancel_rounded,
                color: AppColors.error,
                size: 22,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
