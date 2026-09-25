import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Local SQLite database for storing user practice progress.
/// This avoids saving progress to Supabase, reducing cloud costs
/// and allowing the app to work with large question banks.
class LocalProgressDb {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'questora_progress.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE mock_exams (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              exam_type TEXT NOT NULL,
              title TEXT NOT NULL,
              total_questions INTEGER NOT NULL,
              correct INTEGER NOT NULL,
              wrong INTEGER NOT NULL,
              skipped INTEGER NOT NULL,
              duration_seconds INTEGER NOT NULL,
              taken_at TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE user_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id TEXT NOT NULL,
        chapter_id TEXT,
        chapter_name TEXT,
        subject_id TEXT,
        is_correct INTEGER NOT NULL,
        answered_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE bookmarks (
        question_id TEXT PRIMARY KEY,
        bookmarked_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE mock_exams (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exam_type TEXT NOT NULL,
        title TEXT NOT NULL,
        total_questions INTEGER NOT NULL,
        correct INTEGER NOT NULL,
        wrong INTEGER NOT NULL,
        skipped INTEGER NOT NULL,
        duration_seconds INTEGER NOT NULL,
        taken_at TEXT NOT NULL
      )
    ''');
  }

  /// Save mock exam details.
  static Future<void> saveMockExam({
    required String examType,
    required String title,
    required int totalQuestions,
    required int correct,
    required int wrong,
    required int skipped,
    required int durationSeconds,
  }) async {
    final db = await database;
    await db.insert('mock_exams', {
      'exam_type': examType, // 'mock' or 'chapter' or 'board'
      'title': title,
      'total_questions': totalQuestions,
      'correct': correct,
      'wrong': wrong,
      'skipped': skipped,
      'duration_seconds': durationSeconds,
      'taken_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get mock exam history
  static Future<List<Map<String, dynamic>>> getMockExams() async {
    final db = await database;
    try {
      return await db.query('mock_exams', orderBy: 'taken_at DESC');
    } catch (e) {
      // If the table doesn't exist yet (e.g. migration didn't run), return empty
      return [];
    }
  }

  static Future<void> saveProgress({
    required String questionId,
    required bool isCorrect,
    String? chapterId,
    String? chapterName,
    String? subjectId,
  }) async {
    final db = await database;
    await db.insert('user_progress', {
      'question_id': questionId,
      'chapter_id': chapterId,
      'chapter_name': chapterName,
      'subject_id': subjectId,
      'is_correct': isCorrect ? 1 : 0,
      'answered_at': DateTime.now().toIso8601String(),
    });
  }

  /// Fetch raw progress rows for analytics.
  static Future<List<Map<String, dynamic>>> getAllProgress() async {
    final db = await database;
    return db.query('user_progress', orderBy: 'answered_at DESC');
  }

  /// Check if a question is bookmarked.
  static Future<bool> isBookmarked(String questionId) async {
    final db = await database;
    final result = await db.query(
      'bookmarks',
      where: 'question_id = ?',
      whereArgs: [questionId],
    );
    return result.isNotEmpty;
  }

  /// Toggle bookmark locally.
  static Future<void> toggleBookmark(
    String questionId, {
    required bool isCurrentlyBookmarked,
  }) async {
    final db = await database;
    if (isCurrentlyBookmarked) {
      await db.delete(
        'bookmarks',
        where: 'question_id = ?',
        whereArgs: [questionId],
      );
    } else {
      await db.insert('bookmarks', {
        'question_id': questionId,
        'bookmarked_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  /// Get all bookmarked question IDs.
  static Future<List<String>> getBookmarkedIds() async {
    final db = await database;
    final rows = await db.query('bookmarks', columns: ['question_id']);
    return rows.map((r) => r['question_id'] as String).toList();
  }

  /// Get distinct active dates for streak calculation.
  static Future<List<String>> getActiveDates() async {
    final db = await database;
    final rows = await db.rawQuery(
      'SELECT DISTINCT substr(answered_at, 1, 10) AS date FROM user_progress ORDER BY date DESC',
    );
    return rows.map((r) => r['date'] as String).toList();
  }

  /// Clear all local progress (for testing/reset).
  static Future<void> clearAllProgress() async {
    final db = await database;
    await db.delete('user_progress');
    try {
      await db.delete('mock_exams');
    } catch (e) {
      // Ignore if table doesn't exist
    }
  }
}
