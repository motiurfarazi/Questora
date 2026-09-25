import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/practice_models.dart';
import '../../providers/practice_providers.dart';
import '../subject_exam_list_screen.dart';
import '../chapter_selection_screen.dart';
import '../subject_selection_screen.dart';

class SubjectCard extends ConsumerWidget {
  final Subject subject;
  final PracticeMode mode;

  const SubjectCard({super.key, required this.subject, required this.mode});

  // Helper to get a dynamic appearance based on subject name
  ({Color color, String iconText, IconData? iconData}) _getAppearance(
    String name,
  ) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('math')) {
      return (color: const Color(0xFF7A42F4), iconText: 'Σ', iconData: null);
    } else if (lowerName.contains('physics')) {
      return (
        color: const Color(0xFFE88A01),
        iconText: '',
        iconData: Icons.science_outlined,
      );
    } else if (lowerName.contains('chemistry')) {
      return (
        color: const Color(0xFF17A66C),
        iconText: '',
        iconData: Icons.biotech_outlined,
      );
    } else if (lowerName.contains('biology') ||
        lowerName.contains('botany') ||
        lowerName.contains('zoology')) {
      return (
        color: const Color(0xFF0EA5E9),
        iconText: '',
        iconData: Icons.eco_outlined,
      );
    } else if (lowerName.contains('bangla') || lowerName.contains('english')) {
      return (
        color: const Color(0xFFEF4444),
        iconText: '',
        iconData: Icons.language_outlined,
      );
    } else if (lowerName.contains('ict')) {
      return (
        color: const Color(0xFF3B82F6),
        iconText: '',
        iconData: Icons.computer_outlined,
      );
    }

    // Fallback: Generate a consistent color based on string hash
    final colors = [
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
      const Color(0xFFF59E0B),
      const Color(0xFF6366F1),
      const Color(0xFF10B981),
    ];
    final color = colors[name.hashCode % colors.length];
    return (
      color: color,
      iconText: name.isNotEmpty ? name[0].toUpperCase() : '?',
      iconData: null,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = _getAppearance(subject.name);
    final chaptersAsync = ref.watch(chaptersBySubjectProvider(subject.id));

    return Material(
      color: appearance.color, // Purple from screenshot
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (mode == PracticeMode.chapter) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChapterSelectionScreen(subject: subject),
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SubjectExamListScreen(subject: subject),
              ),
            );
          }
        },
        splashColor: Colors.white.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.1),
        child: Stack(
          children: [
            // Top Right Circular Decoration
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Left Icon
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                    alignment: Alignment.center,
                    child: appearance.iconData != null
                        ? Icon(
                            appearance.iconData,
                            color: Colors.white,
                            size: 22,
                          )
                        : Text(
                            appearance.iconText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  // Texts and Pills
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Left Pill (Group/Exam Type)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              subject.groupType.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Right Pill (Chapters Count)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.library_books_outlined,
                                  color: Colors.white,
                                  size: 13,
                                ),
                                const SizedBox(width: 4),
                                chaptersAsync.when(
                                  data: (chapters) => Text(
                                    '${chapters.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  loading: () => const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  error: (_, _) => const Text(
                                    '?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
