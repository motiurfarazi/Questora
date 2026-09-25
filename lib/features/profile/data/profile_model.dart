class ProfileModel {
  final String id;
  final String? fullName;
  final String? phone;
  final String? institution;
  final String? board;
  final String? passingYear;
  final String? examType;
  final String? groupType;
  final int totalScore;
  final int streak;

  ProfileModel({
    required this.id,
    this.fullName,
    this.phone,
    this.institution,
    this.board,
    this.passingYear,
    this.examType,
    this.groupType,
    this.totalScore = 0,
    this.streak = 0,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      institution: json['institution'] as String?,
      board: json['board'] as String?,
      passingYear: json['passing_year']
          ?.toString(), // Handle both string and int gracefully
      examType: json['exam_type'] as String?,
      groupType: json['group_type'] as String?,
      totalScore: json['total_score'] as int? ?? 0,
      streak: json['streak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'institution': institution,
      'board': board,
      'passing_year': passingYear,
      'exam_type': examType,
      'group_type': groupType,
      'total_score': totalScore,
      'streak': streak,
    };
  }

  ProfileModel copyWith({
    String? fullName,
    String? phone,
    String? institution,
    String? board,
    String? passingYear,
    String? examType,
    String? groupType,
    int? totalScore,
    int? streak,
  }) {
    return ProfileModel(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      institution: institution ?? this.institution,
      board: board ?? this.board,
      passingYear: passingYear ?? this.passingYear,
      examType: examType ?? this.examType,
      groupType: groupType ?? this.groupType,
      totalScore: totalScore ?? this.totalScore,
      streak: streak ?? this.streak,
    );
  }
}
