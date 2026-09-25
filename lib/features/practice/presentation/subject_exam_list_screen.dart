import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../data/practice_models.dart';
import '../data/question_repository.dart';
import 'exam_screen.dart';
import 'filtered_question_list_screen.dart';

// ignore_for_file: use_build_context_synchronously

/// Shows all board+year exam groups for a given subject.
/// Tapping a card presents a Mode Chooser — Exam Mode or Practice Mode.
class SubjectExamListScreen extends StatefulWidget {
  final Subject subject;

  const SubjectExamListScreen({super.key, required this.subject});

  @override
  State<SubjectExamListScreen> createState() => _SubjectExamListScreenState();
}

class _SubjectExamListScreenState extends State<SubjectExamListScreen> {
  bool _loading = true;
  String? _error;

  List<Map<String, dynamic>> _exams = [];
  List<Map<String, dynamic>> _filtered = [];
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchExams();
    _searchCtrl.addListener(_applySearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchExams() async {
    try {
      final data = await Supabase.instance.client
          .from('questions')
          .select('board, year')
          .eq('subject_id', widget.subject.id)
          .not('board', 'is', null)
          .not('year', 'is', null);

      final Map<String, int> countMap = {};
      for (final row in data) {
        final board = row['board'] as String? ?? '';
        final year = row['year'] as int? ?? 0;
        final key = '$board|$year';
        countMap[key] = (countMap[key] ?? 0) + 1;
      }

      final List<Map<String, dynamic>> exams = countMap.entries.map((e) {
        final parts = e.key.split('|');
        return {
          'board': parts[0],
          'year': int.tryParse(parts[1]) ?? 0,
          'count': e.value,
        };
      }).toList();

      exams.sort((a, b) {
        final yComp = (b['year'] as int).compareTo(a['year'] as int);
        if (yComp != 0) return yComp;
        return (a['board'] as String).compareTo(b['board'] as String);
      });

      if (mounted) {
        setState(() {
          _exams = exams;
          _filtered = exams;
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

  void _applySearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _exams
          .where((e) => '${e['board']} ${e['year']}'.toLowerCase().contains(q))
          .toList();
    });
  }

  void _onExamCardTap(Map<String, dynamic> exam) {
    final board = exam['board'] as String;
    final year = exam['year'] as int;
    final count = exam['count'] as int;
    final title = '$board $year';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ModePickerSheet(
        title: title,
        questionCount: count,
        onExamMode: () async {
          Navigator.of(context).pop(); // close sheet
          // Show loading dialog
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
          try {
            final repo = QuestionRepository(Supabase.instance.client);
            final qs = await repo.getQuestionsByBoardAndYear(
              board: board,
              year: year,
              subjectId: widget.subject.id,
            );
            if (!mounted) return;
            Navigator.of(context).pop(); // close loading
            if (qs.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('কোনো প্রশ্ন পাওয়া যায়নি।')),
              );
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ExamScreen(
                  questions: qs,
                  durationMinutes: qs.length, // 1 min per MCQ
                ),
              ),
            );
          } catch (e) {
            if (!mounted) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        },
        onPracticeMode: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => FilteredQuestionListScreen(
                title: title,
                board: board,
                subjectId: widget.subject.id,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.subject.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
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
          : Column(
              children: [
                // Search bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'পরীক্ষা খুঁজে বের করো',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                // Exam list
                Expanded(
                  child: _filtered.isEmpty
                      ? const Center(
                          child: Text(
                            'কোনো পরীক্ষা পাওয়া যায়নি।',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) {
                            final exam = _filtered[i];
                            return _ExamCard(
                              board: exam['board'] as String,
                              year: exam['year'] as int,
                              count: exam['count'] as int,
                              onTap: () => _onExamCardTap(exam),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 7,
      itemBuilder: (_, i) => Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _ModePickerSheet extends StatelessWidget {
  final String title;
  final int questionCount;
  final VoidCallback onExamMode;
  final VoidCallback onPracticeMode;

  const _ModePickerSheet({
    required this.title,
    required this.questionCount,
    required this.onExamMode,
    required this.onPracticeMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '$questionCount টি প্রশ্ন',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          // Mode Cards
          Row(
            children: [
              Expanded(
                child: _ModeCard(
                  icon: Icons.timer_outlined,
                  label: 'পরীক্ষা মোড',
                  description: '$questionCount মিনিট\nটাইমার সহ',
                  color: AppColors.primary,
                  onTap: onExamMode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModeCard(
                  icon: Icons.auto_stories_outlined,
                  label: 'প্র্যাকটিস মোড',
                  description: 'যেকোনো সময়\nউত্তর দেখা যাবে',
                  color: const Color(0xFF059669),
                  onTap: onPracticeMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      color: color.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final String board;
  final int year;
  final int count;
  final VoidCallback onTap;

  const _ExamCard({
    required this.board,
    required this.year,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
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
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$board $year',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _MetaChip(
                      icon: Icons.timer_outlined,
                      label: '$count মিনিট',
                      color: Colors.red,
                    ),
                    const SizedBox(width: 16),
                    _MetaChip(
                      icon: Icons.edit_outlined,
                      label: '$count টি প্রশ্ন',
                      color: AppColors.success,
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

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
