import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/practice_providers.dart';
import '../widgets/math_text_render.dart';
import 'question_screen.dart';

class BookmarkListScreen extends ConsumerWidget {
  const BookmarkListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarkedQuestionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Questions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(bookmarkedQuestionsProvider);
            },
          ),
        ],
      ),
      body: bookmarksAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return const Center(
              child: Text(
                'No bookmarked questions found.',
                style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              return ref.refresh(bookmarkedQuestionsProvider.future);
            },
            child: ListView.separated(
              itemCount: questions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final question = questions[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: MathTextRender(
                    htmlContent: question.questionHtml,
                    hasMath: question.hasMath,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () {
                    // Navigate to QuestionScreen with this list context
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (context) => QuestionScreen(
                              initialQuestions: questions,
                              startingIndex: index,
                            ),
                          ),
                        )
                        .then((_) {
                          // Refresh bookmarks when coming back just in case they were unbookmarked
                          ref.invalidate(bookmarkedQuestionsProvider);
                        });
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}
