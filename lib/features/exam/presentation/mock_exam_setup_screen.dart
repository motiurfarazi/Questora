import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../practice/data/practice_models.dart';
import '../../practice/data/question_repository.dart';
import '../../practice/presentation/exam_screen.dart';
import '../../practice/providers/practice_providers.dart';

class MockExamSetupScreen extends ConsumerStatefulWidget {
  const MockExamSetupScreen({super.key});

  @override
  ConsumerState<MockExamSetupScreen> createState() =>
      _MockExamSetupScreenState();
}

class _MockExamSetupScreenState extends ConsumerState<MockExamSetupScreen> {
  int _questionCount = 30;
  int _durationMinutes = 30;
  Subject? _selectedSubject; // null = All subjects
  List<Chapter> _selectedChapters = []; // Empty = All chapters in the subject
  bool _loading = false;

  final _countOptions = [10, 20, 30, 40, 'Custom'];
  final _durationOptions = [10, 20, 30, 45, 'Custom'];

  bool _isCustomCount = false;
  bool _isCustomDuration = false;

  final _customCountController = TextEditingController();
  final _customDurationController = TextEditingController();

  @override
  void dispose() {
    _customCountController.dispose();
    _customDurationController.dispose();
    super.dispose();
  }

  Future<void> _startExam() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(questionRepositoryProvider);
      final questions = await repo.getMockExamQuestions(
        subjectId: _selectedSubject?.id,
        chapterIds: _selectedChapters.map((c) => c.id).toList(),
        limit: _questionCount,
      );

      if (questions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No questions found. Add some questions first!'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      if (questions.length < _questionCount) {
        if (mounted) {
          final subjName = _selectedSubject?.name ?? 'All Subjects';
          final chapName = _selectedChapters.isNotEmpty
              ? _selectedChapters.map((c) => c.name).join(', ')
              : null;
          final scopeName = chapName != null
              ? '$subjName - $chapName'
              : subjName;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Only ${questions.length} questions available for $scopeName. '
                'Please reduce the number of questions.',
              ),
              backgroundColor: Colors.orange.shade800,
            ),
          );
        }
        return;
      }

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ExamScreen(
              questions: questions,
              durationMinutes: _durationMinutes,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Mock Exam'), centerTitle: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF059669), Color(0xFF10B981)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.timer_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Mock Exam',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Simulate real exam conditions with a timer. '
                    'All answers revealed after submission.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Subject (optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Leave as "All" for a mixed exam',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            subjectsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
              data: (subjects) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SubjectChip(
                      label: 'All Subjects',
                      selected: _selectedSubject == null,
                      color: const Color(0xFF3B82F6),
                      onTap: () => setState(() {
                        _selectedSubject = null;
                        _selectedChapters = [];
                      }),
                    ),
                    ...subjects.map(
                      (s) => _SubjectChip(
                        label: s.name,
                        selected: _selectedSubject?.id == s.id,
                        color: const Color(0xFF7C3AED),
                        onTap: () => setState(() {
                          if (_selectedSubject?.id != s.id) {
                            _selectedSubject = s;
                            _selectedChapters =
                                []; // Reset chapters when subj changes
                          }
                        }),
                      ),
                    ),
                  ],
                );
              },
            ),

            if (_selectedSubject != null) ...[
              const SizedBox(height: 28),
              const Text(
                'Chapter (optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Leave as "All" to include all chapters from this subject',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ref
                  .watch(chaptersBySubjectProvider(_selectedSubject!.id))
                  .when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error loading chapters: $e'),
                    data: (chapters) {
                      if (chapters.isEmpty) {
                        return const Text(
                          'No chapters found for this subject.',
                          style: TextStyle(color: AppColors.textSecondary),
                        );
                      }
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _SubjectChip(
                            label: 'All Chapters',
                            selected: _selectedChapters.isEmpty,
                            color: const Color(0xFF3B82F6),
                            onTap: () => setState(() => _selectedChapters = []),
                          ),
                          ...chapters.map(
                            (c) => _SubjectChip(
                              label: c.name,
                              selected: _selectedChapters.any(
                                (selected) => selected.id == c.id,
                              ),
                              color: const Color(0xFFF59E0B),
                              onTap: () => setState(() {
                                if (_selectedChapters.any(
                                  (selected) => selected.id == c.id,
                                )) {
                                  _selectedChapters =
                                      List.from(_selectedChapters)..removeWhere(
                                        (selected) => selected.id == c.id,
                                      );
                                } else {
                                  _selectedChapters = List.from(
                                    _selectedChapters,
                                  )..add(c);
                                }
                              }),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
            ],

            const SizedBox(height: 28),

            const Text(
              'Number of Questions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: _countOptions.map((option) {
                final isCustomOption = option == 'Custom';
                final selected = isCustomOption
                    ? _isCustomCount
                    : (!_isCustomCount && _questionCount == option);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isCustomOption) {
                            _isCustomCount = true;
                          } else {
                            _isCustomCount = false;
                            _questionCount = option as int;
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF059669)
                              : AppColors.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF059669)
                                : Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$option',
                            style: TextStyle(
                              fontSize: isCustomOption ? 13 : 16,
                              fontWeight: FontWeight.bold,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_isCustomCount) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customCountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Custom Question Count',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF059669)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (val) {
                  final parsed = int.tryParse(val);
                  if (parsed != null && parsed > 0) {
                    setState(() {
                      _questionCount = parsed;
                    });
                  }
                },
              ),
            ],

            const SizedBox(height: 28),

            const Text(
              'Time Limit (minutes)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: _durationOptions.map((option) {
                final isCustomOption = option == 'Custom';
                final selected = isCustomOption
                    ? _isCustomDuration
                    : (!_isCustomDuration && _durationMinutes == option);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isCustomOption) {
                            _isCustomDuration = true;
                          } else {
                            _isCustomDuration = false;
                            _durationMinutes = option as int;
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF059669)
                              : AppColors.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF059669)
                                : Colors.grey.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '$option',
                            style: TextStyle(
                              fontSize: isCustomOption ? 13 : 16,
                              fontWeight: FontWeight.bold,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_isCustomDuration) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customDurationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter Custom Time Limit (minutes)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF059669)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (val) {
                  final parsed = int.tryParse(val);
                  if (parsed != null && parsed > 0) {
                    setState(() {
                      _durationMinutes = parsed;
                    });
                  }
                },
              ),
            ],

            const SizedBox(height: 12),
            Center(
              child: Text(
                'Each question ~${(_durationMinutes * 60 / _questionCount).round()} seconds',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 36),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _startExam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Start $_questionCount-Question Exam  ($_durationMinutes min)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _SubjectChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
