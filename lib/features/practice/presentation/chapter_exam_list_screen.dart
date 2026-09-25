import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../data/practice_models.dart';
import 'filtered_question_list_screen.dart';

/// Shows all board+year exam groups for a given chapter.
/// Tapping a card opens FilteredQuestionListScreen pre-filtered to that chapter.
class ChapterExamListScreen extends ConsumerStatefulWidget {
  final Chapter chapter;

  const ChapterExamListScreen({super.key, required this.chapter});

  @override
  ConsumerState<ChapterExamListScreen> createState() =>
      _ChapterExamListScreenState();
}

class _ChapterExamListScreenState extends ConsumerState<ChapterExamListScreen> {
  bool _loading = true;
  String? _error;

  // board → list of years
  Map<String, List<int>> _boardYearMap = {};

  @override
  void initState() {
    super.initState();
    _fetchBoardYearGroups();
  }

  Future<void> _fetchBoardYearGroups() async {
    try {
      final data = await Supabase.instance.client
          .from('questions')
          .select('board, year')
          .eq('chapter_id', widget.chapter.id)
          .not('board', 'is', null)
          .not('year', 'is', null)
          .order('year', ascending: false);

      final Map<String, Set<int>> grouped = {};
      for (final row in data) {
        final board = row['board'] as String?;
        final year = row['year'] as int?;
        if (board != null && year != null) {
          grouped.putIfAbsent(board, () => {}).add(year);
        }
      }

      if (mounted) {
        setState(() {
          _boardYearMap = {
            for (var e in grouped.entries)
              e.key: (e.value.toList()..sort((a, b) => b.compareTo(a))),
          };
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.chapter.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        scrolledUnderElevation: 4,
        shadowColor: Colors.black26,
      ),
      body: _loading
          ? _buildSkeleton()
          : _error != null
          ? Center(
              child: Text(
                'Error: $_error',
                style: const TextStyle(color: AppColors.error),
              ),
            )
          : _boardYearMap.isEmpty
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 56,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'কোনো প্রশ্ন পাওয়া যায়নি।',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )
          : _buildList(),
    );
  }

  Widget _buildList() {
    final boards = _boardYearMap.keys.toList()..sort();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: boards.length,
      itemBuilder: (context, i) {
        final board = boards[i];
        final years = _boardYearMap[board]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Board Header
            Padding(
              padding: EdgeInsets.only(
                top: i == 0 ? 0 : 20,
                bottom: 10,
                left: 2,
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    board,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            // Year Cards
            ...years.map(
              (year) => _ExamCard(
                board: board,
                year: year,
                chapterId: widget.chapter.id,
                chapterName: widget.chapter.name,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FilteredQuestionListScreen(
                      title: '$board $year',
                      board: board,
                      chapterId: widget.chapter.id,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => _SkeletonCard(),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final String board;
  final int year;
  final String chapterId;
  final String chapterName;
  final VoidCallback onTap;

  const _ExamCard({
    required this.board,
    required this.year,
    required this.chapterId,
    required this.chapterName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Year Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$year',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$board $year',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.edit_note_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            chapterName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
