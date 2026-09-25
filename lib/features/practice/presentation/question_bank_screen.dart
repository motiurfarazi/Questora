import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/theme/app_colors.dart';

import '../providers/practice_providers.dart';
import 'subject_exam_list_screen.dart';
import 'filtered_question_list_screen.dart';

part 'question_bank_screen.g.dart';

/// Returns a list of distinct boards from the questions table.
@riverpod
Future<List<String>> distinctBoards(Ref ref) async {
  final data = await Supabase.instance.client
      .from('questions')
      .select('board')
      .not('board', 'is', null)
      .order('board');
  final seen = <String>{};
  return data
      .map((r) => r['board'] as String)
      .where((b) => b.isNotEmpty && seen.add(b))
      .toList();
}

/// Returns a list of distinct years from the questions table.
@riverpod
Future<List<int>> distinctYears(Ref ref) async {
  final data = await Supabase.instance.client
      .from('questions')
      .select('year')
      .not('year', 'is', null)
      .order('year', ascending: false);
  final seen = <int>{};
  return data.map((r) => r['year'] as int).where((y) => seen.add(y)).toList();
}

/// Returns question count per subject id: { subjectId: count }
@riverpod
Future<Map<String, int>> subjectQuestionCounts(Ref ref) async {
  final data = await Supabase.instance.client
      .from('questions')
      .select('subject_id');
  final map = <String, int>{};
  for (final row in data) {
    final id = row['subject_id'] as String;
    map[id] = (map[id] ?? 0) + 1;
  }
  return map;
}

enum _BankTab { subject, board, year }

class QuestionBankScreen extends ConsumerStatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  ConsumerState<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends ConsumerState<QuestionBankScreen> {
  _BankTab _tab = _BankTab.subject;

  // Palette of card backgrounds — cycles through subjects
  static const _cardColors = [
    Color(0xFF7C3AED), // purple
    Color(0xFF0D9488), // teal
    Color(0xFFD97706), // amber
    Color(0xFF1E3A8A), // dark blue
    Color(0xFFBE185D), // pink
    Color(0xFF059669), // green
    Color(0xFF4F46E5), // indigo
    Color(0xFFDC2626), // red
    Color(0xFF0369A1), // sky blue
    Color(0xFF92400E), // brown
  ];

  Color _cardColor(int index) => _cardColors[index % _cardColors.length];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('প্রশ্নব্যাংক'), centerTitle: false),
      body: Column(
        children: [
          _FilterTabBar(
            current: _tab,
            onChanged: (t) => setState(() => _tab = t),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_tab) {
      case _BankTab.subject:
        return _SubjectGrid(cardColor: _cardColor);
      case _BankTab.board:
        return _BoardGrid(cardColor: _cardColor);
      case _BankTab.year:
        return _YearGrid(cardColor: _cardColor);
    }
  }
}

class _FilterTabBar extends StatelessWidget {
  final _BankTab current;
  final ValueChanged<_BankTab> onChanged;

  const _FilterTabBar({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (_BankTab.subject, 'বিষয় ভিত্তিক'),
      (_BankTab.board, 'বোর্ড ভিত্তিক'),
      (_BankTab.year, 'বছর ভিত্তিক'),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: tabs.map((entry) {
          final (tab, label) = entry;
          final selected = current == tab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.primary : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SubjectGrid extends ConsumerWidget {
  final Color Function(int) cardColor;
  const _SubjectGrid({required this.cardColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);
    final countsAsync = ref.watch(subjectQuestionCountsProvider);

    return subjectsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (subjects) {
        if (subjects.isEmpty) {
          return const Center(child: Text('কোনো বিষয় পাওয়া যায়নি।'));
        }
        final counts = countsAsync.value ?? <String, int>{};
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.92,
          ),
          itemCount: subjects.length,
          itemBuilder: (context, i) {
            final subject = subjects[i];
            final count = counts[subject.id] ?? 0;
            return _BankCard(
              title: subject.name,
              subtitle: subject.examType.toUpperCase(),
              count: count,
              color: cardColor(i),
              icon: _subjectIcon(subject.name),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SubjectExamListScreen(subject: subject),
                ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _subjectIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('math') || n.contains('গণিত')) return Icons.functions;
    if (n.contains('physics') || n.contains('পদার্থ')) return Icons.bolt;
    if (n.contains('chemistry') || n.contains('রসায়ন')) return Icons.science;
    if (n.contains('biology') || n.contains('জীব')) return Icons.biotech;
    if (n.contains('english')) return Icons.translate;
    if (n.contains('bangla') || n.contains('বাংলা')) return Icons.menu_book;
    if (n.contains('ict') || n.contains('তথ্য')) return Icons.computer;
    return Icons.subject;
  }
}

class _BoardGrid extends ConsumerWidget {
  final Color Function(int) cardColor;
  const _BoardGrid({required this.cardColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardsAsync = ref.watch(distinctBoardsProvider);

    return boardsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (boards) {
        if (boards.isEmpty) {
          return const Center(child: Text('কোনো বোর্ড পাওয়া যায়নি।'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.92,
          ),
          itemCount: boards.length,
          itemBuilder: (context, i) {
            final board = boards[i];
            return _BankCard(
              title: board,
              subtitle: 'বোর্ড',
              count: null,
              color: cardColor(i),
              icon: Icons.account_balance,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FilteredQuestionListScreen(
                    title: '$board Board',
                    board: board,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _YearGrid extends ConsumerWidget {
  final Color Function(int) cardColor;
  const _YearGrid({required this.cardColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final yearsAsync = ref.watch(distinctYearsProvider);

    return yearsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (years) {
        if (years.isEmpty) {
          return const Center(child: Text('কোনো বছর পাওয়া যায়নি।'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.92,
          ),
          itemCount: years.length,
          itemBuilder: (context, i) {
            final year = years[i];
            return _BankCard(
              title: '$year',
              subtitle: 'সাল',
              count: null,
              color: cardColor(i),
              icon: Icons.calendar_today_rounded,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FilteredQuestionListScreen(
                    title: '$year সালের প্রশ্ন',
                    year: year,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BankCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int? count;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _BankCard({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circle in top-right
            Positioned(
              top: -18,
              right: -18,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon circle
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const Spacer(),
                  // Subject name
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Bottom row: subtitle tag + question count
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (count != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.edit_outlined,
                                color: Colors.white70,
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
