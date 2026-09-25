import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:questora/core/theme/app_colors.dart';
import 'package:questora/features/practice/data/practice_models.dart';
import 'package:questora/shared/widgets/primary_button.dart';

void main() {
  group('Questora Data Model Tests', () {
    test('Question model deserializes correctly from JSON', () {
      final json = {
        'id': 'q1',
        'subject_id': 'sub1',
        'chapter_id': 'ch1',
        'topic_id': 'top1',
        'question_html': '<p>What is 2 + 2?</p>',
        'options': ['1', '2', '3', '4'],
        'answer': '4',
        'explanation_html': '<p>Simple addition</p>',
        'board': 'Dhaka',
        'year': 2023,
        'has_math': false,
      };

      final question = Question.fromJson(json);

      expect(question.id, 'q1');
      expect(question.options.length, 4);
      expect(question.answer, '4');
      expect(question.board, 'Dhaka');
      expect(question.year, 2023);
      expect(question.hasMath, isFalse);
    });

    test('Subject model deserializes correctly from JSON', () {
      final json = {
        'id': 'sub_physics',
        'name': 'Physics 1st Paper',
        'exam_type': 'hsc',
        'group_type': 'science',
      };

      final subject = Subject.fromJson(json);
      expect(subject.id, 'sub_physics');
      expect(subject.name, 'Physics 1st Paper');
      expect(subject.examType, 'hsc');
      expect(subject.groupType, 'science');
    });

    test('AppColors palette values are valid', () {
      expect(AppColors.primary, const Color(0xFF1E3A8A));
      expect(AppColors.accent, const Color(0xFF2563EB));
      expect(AppColors.success, const Color(0xFF16A34A));
      expect(AppColors.error, const Color(0xFFDC2626));
    });
  });

  group('Questora Shared Widget Tests', () {
    testWidgets('PrimaryButton renders text and triggers callback on tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Start Practice',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Start Practice'), findsOneWidget);
      await tester.tap(find.text('Start Practice'));
      expect(tapped, isTrue);
    });

    testWidgets('PrimaryButton shows loading indicator when isLoading is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              text: 'Submit',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Submit'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
