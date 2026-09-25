import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../data/practice_models.dart';
import '../providers/practice_providers.dart';
import 'widgets/filtered_question_card.dart';
import 'widgets/filtered_skeleton_loader.dart';

/// Shows a flat list of questions filtered by [board] or [year].
class FilteredQuestionListScreen extends ConsumerStatefulWidget {
  final String title;
  final String? board;
  final int? year;
  final String? subjectId;
  final String? chapterId;

  const FilteredQuestionListScreen({
    super.key,
    required this.title,
    this.board,
    this.year,
    this.subjectId,
    this.chapterId,
  });

  @override
  ConsumerState<FilteredQuestionListScreen> createState() =>
      _FilteredQuestionListScreenState();
}

class _FilteredQuestionListScreenState
    extends ConsumerState<FilteredQuestionListScreen> {
  List<Question> _questions = [];
  Map<String, String> _subjectNames = {};
  bool _loading = true;
  String? _error;

  Set<String> _selectedSubjectIds = {};
  Set<String> _selectedChapterIds = {};
  Set<int> _selectedYears = {};

  @override
  void initState() {
    super.initState();
    if (widget.subjectId != null) _selectedSubjectIds.add(widget.subjectId!);
    if (widget.year != null) _selectedYears.add(widget.year!);
    if (widget.chapterId != null) _selectedChapterIds.add(widget.chapterId!);
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      var query = Supabase.instance.client.from('questions').select();
      if (widget.board != null) {
        query = query.eq('board', widget.board!);
      }
      if (_selectedYears.isNotEmpty) {
        query = query.inFilter('year', _selectedYears.toList());
      }
      if (_selectedSubjectIds.isNotEmpty) {
        query = query.inFilter('subject_id', _selectedSubjectIds.toList());
      }
      if (_selectedChapterIds.isNotEmpty) {
        query = query.inFilter('chapter_id', _selectedChapterIds.toList());
      }

      final data = await query.order('created_at');

      final subjects = await ref.read(subjectsProvider.future);
      final subjectMap = {for (var s in subjects) s.id: s.name};

      if (mounted) {
        setState(() {
          _subjectNames = subjectMap;
          _questions = data.map((j) => Question.fromJson(j)).toList();
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
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        scrolledUnderElevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),
      body: Column(
        children: [
          // Filter Row (Horizontal Slider)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildFilterChip(
                    _selectedSubjectIds.isEmpty
                        ? 'নবায়ন বিষয়'
                        : '${_selectedSubjectIds.length} বিষয়',
                    Icons.notes_outlined,
                    _selectedSubjectIds.isNotEmpty,
                    _showSubjectFilter,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    _selectedChapterIds.isEmpty
                        ? 'অধ্যায়'
                        : '${_selectedChapterIds.length} অধ্যায়',
                    Icons.chrome_reader_mode_outlined,
                    _selectedChapterIds.isNotEmpty,
                    _showChapterFilter,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    _selectedYears.isEmpty
                        ? 'সাল'
                        : '${_selectedYears.length} সাল',
                    Icons.calendar_month_outlined,
                    _selectedYears.isNotEmpty,
                    _showYearFilter,
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: _loading
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 5, // Show 5 skeleton items while loading
                    itemBuilder: (context, index) =>
                        const FilteredQuestionSkeletonLoader(),
                  )
                : _error != null
                ? Center(child: Text('Error: $_error'))
                : _questions.isEmpty
                ? const Center(child: Text('কোনো প্রশ্ন পাওয়া যায়নি।'))
                : Column(
                    children: [
                      // Count chip
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_questions.length} টি প্রশ্ন',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // List
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final Map<String, List<Question>> grouped = {};
                            for (var q in _questions) {
                              grouped.putIfAbsent(q.subjectId, () => []).add(q);
                            }

                            final List<dynamic> listItems = [];
                            for (var entry in grouped.entries) {
                              final subjectName =
                                  _subjectNames[entry.key] ?? 'অজানা বিষয়';
                              listItems.add(
                                '$subjectName - ${entry.value.length} টি প্রশ্ন',
                              );

                              int localIndex = 1;
                              for (var q in entry.value) {
                                listItems.add({
                                  'index': localIndex++,
                                  'question': q,
                                });
                              }
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: listItems.length,
                              itemBuilder: (context, index) {
                                final item = listItems[index];
                                if (item is String) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                      top: 8,
                                      bottom: 16,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  );
                                } else {
                                  final map = item as Map<String, dynamic>;
                                  return FilteredQuestionCard(
                                    index: map['index'] as int,
                                    question: map['question'] as Question,
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Material(
      color: isSelected ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        splashColor: isSelected
            ? Colors.white.withValues(alpha: 0.2)
            : AppColors.primary.withValues(alpha: 0.1),
        highlightColor: isSelected
            ? Colors.white.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.grey.shade800,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSubjectFilter() async {
    final subjects = await ref.read(subjectsProvider.future);
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        Set<String> tempSelected = Set.from(_selectedSubjectIds);
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Select Subjects',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: CheckboxListTile(
                      title: const Text(
                        'Select All',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      value:
                          subjects.isNotEmpty &&
                          tempSelected.length == subjects.length,
                      onChanged: (bool? value) {
                        setModalState(() {
                          if (value == true) {
                            tempSelected.addAll(subjects.map((e) => e.id));
                          } else {
                            tempSelected.clear();
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjects[index];
                        final isSelected = tempSelected.contains(subject.id);
                        return CheckboxListTile(
                          title: Text(
                            subject.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setModalState(() {
                              if (value == true) {
                                tempSelected.add(subject.id);
                              } else {
                                tempSelected.remove(subject.id);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppColors.primary,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedSubjectIds = tempSelected;
                          // Optional: Clear chapters if subjects changed
                          // _selectedChapterIds.clear();
                          _loading = true;
                        });
                        _fetchQuestions();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showChapterFilter() async {
    if (_selectedSubjectIds.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one subject first'),
        ),
      );
      return;
    }

    // Fetch chapters for all selected subjects
    List<Chapter> allChapters = [];
    for (String subjectId in _selectedSubjectIds) {
      final chapters = await ref.read(
        chaptersBySubjectProvider(subjectId).future,
      );
      allChapters.addAll(chapters);
    }

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        Set<String> tempSelected = Set.from(_selectedChapterIds);
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Select Chapters',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: CheckboxListTile(
                      title: const Text(
                        'Select All',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      value:
                          allChapters.isNotEmpty &&
                          tempSelected.length == allChapters.length,
                      onChanged: (bool? value) {
                        setModalState(() {
                          if (value == true) {
                            tempSelected.addAll(allChapters.map((e) => e.id));
                          } else {
                            tempSelected.clear();
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: allChapters.length,
                      itemBuilder: (context, index) {
                        final chapter = allChapters[index];
                        final isSelected = tempSelected.contains(chapter.id);
                        return CheckboxListTile(
                          title: Text(
                            chapter.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setModalState(() {
                              if (value == true) {
                                tempSelected.add(chapter.id);
                              } else {
                                tempSelected.remove(chapter.id);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppColors.primary,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedChapterIds = tempSelected;
                          _loading = true;
                        });
                        _fetchQuestions();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showYearFilter() {
    final years = List.generate(15, (i) => 2024 - i);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        Set<int> tempSelected = Set.from(_selectedYears);
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Text(
                    'Select Years',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: CheckboxListTile(
                      title: const Text(
                        'Select All',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      value:
                          years.isNotEmpty &&
                          tempSelected.length == years.length,
                      onChanged: (bool? value) {
                        setModalState(() {
                          if (value == true) {
                            tempSelected.addAll(years);
                          } else {
                            tempSelected.clear();
                          }
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: years.length,
                      itemBuilder: (context, index) {
                        final y = years[index];
                        final isSelected = tempSelected.contains(y);
                        return CheckboxListTile(
                          title: Text(
                            '$y',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setModalState(() {
                              if (value == true) {
                                tempSelected.add(y);
                              } else {
                                tempSelected.remove(y);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppColors.primary,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedYears = tempSelected;
                          _loading = true;
                        });
                        _fetchQuestions();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
