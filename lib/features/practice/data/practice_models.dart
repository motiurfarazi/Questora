class Subject {
  final String id;
  final String name;
  final String examType;
  final String groupType;

  Subject({
    required this.id,
    required this.name,
    required this.examType,
    required this.groupType,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      examType: json['exam_type'] as String,
      groupType: json['group_type'] as String,
    );
  }
}

class Chapter {
  final String id;
  final String subjectId;
  final String name;
  final int orderNo;

  Chapter({
    required this.id,
    required this.subjectId,
    required this.name,
    required this.orderNo,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String,
      name: json['name'] as String,
      orderNo: json['order_no'] as int,
    );
  }
}

class Question {
  final String id;
  final String subjectId;
  final String chapterId;
  final String? topicId;
  final String questionHtml;
  final List<String> options;
  final String answer;
  final String? explanationHtml;
  final String? board;
  final int? year;
  final bool hasMath;

  Question({
    required this.id,
    required this.subjectId,
    required this.chapterId,
    this.topicId,
    required this.questionHtml,
    required this.options,
    required this.answer,
    this.explanationHtml,
    this.board,
    this.year,
    required this.hasMath,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      subjectId: json['subject_id'] as String,
      chapterId: json['chapter_id'] as String,
      topicId: json['topic_id'] as String?,
      questionHtml: json['question_html'] as String,
      options: List<String>.from(json['options'] ?? []),
      answer: json['answer'] as String,
      explanationHtml: json['explanation_html'] as String?,
      board: json['board'] as String?,
      year: json['year'] as int?,
      hasMath: json['has_math'] ?? false,
    );
  }
}

class TopicAccuracy {
  final String topicId;
  final String topicName;
  final int totalAttempted;
  final int correctCount;

  TopicAccuracy({
    required this.topicId,
    required this.topicName,
    required this.totalAttempted,
    required this.correctCount,
  });

  double get accuracy =>
      totalAttempted == 0 ? 0 : correctCount / totalAttempted;
}

class UserAnalytics {
  final int totalQuestionsAttempted;
  final int totalCorrect;
  final List<TopicAccuracy> weakTopics;
  final List<TopicAccuracy> allTopics;
  final List<MockExamResult> mockExams;

  UserAnalytics({
    required this.totalQuestionsAttempted,
    required this.totalCorrect,
    required this.weakTopics,
    this.allTopics = const [],
    this.mockExams = const [],
  });
}

class MockExamResult {
  final int id;
  final String examType; // 'mock', 'chapter', 'board'
  final String title;
  final int totalQuestions;
  final int correct;
  final int wrong;
  final int skipped;
  final int durationSeconds;
  final DateTime takenAt;

  MockExamResult({
    required this.id,
    required this.examType,
    required this.title,
    required this.totalQuestions,
    required this.correct,
    required this.wrong,
    required this.skipped,
    required this.durationSeconds,
    required this.takenAt,
  });

  factory MockExamResult.fromMap(Map<String, dynamic> map) {
    return MockExamResult(
      id: map['id'] as int,
      examType: map['exam_type'] as String,
      title: map['title'] as String,
      totalQuestions: map['total_questions'] as int,
      correct: map['correct'] as int,
      wrong: map['wrong'] as int,
      skipped: map['skipped'] as int,
      durationSeconds: map['duration_seconds'] as int,
      takenAt: DateTime.parse(map['taken_at'] as String),
    );
  }

  double get percentage =>
      totalQuestions == 0 ? 0 : (correct / totalQuestions) * 100;
}
