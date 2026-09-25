// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'practice_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(subjects)
final subjectsProvider = SubjectsProvider._();

final class SubjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Subject>>,
          List<Subject>,
          FutureOr<List<Subject>>
        >
    with $FutureModifier<List<Subject>>, $FutureProvider<List<Subject>> {
  SubjectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subjectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subjectsHash();

  @$internal
  @override
  $FutureProviderElement<List<Subject>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Subject>> create(Ref ref) {
    return subjects(ref);
  }
}

String _$subjectsHash() => r'0b6cfeab737eb5d09ef227be7c4a0b996d4b7b8c';

@ProviderFor(chaptersBySubject)
final chaptersBySubjectProvider = ChaptersBySubjectFamily._();

final class ChaptersBySubjectProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Chapter>>,
          List<Chapter>,
          FutureOr<List<Chapter>>
        >
    with $FutureModifier<List<Chapter>>, $FutureProvider<List<Chapter>> {
  ChaptersBySubjectProvider._({
    required ChaptersBySubjectFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'chaptersBySubjectProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$chaptersBySubjectHash();

  @override
  String toString() {
    return r'chaptersBySubjectProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Chapter>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Chapter>> create(Ref ref) {
    final argument = this.argument as String;
    return chaptersBySubject(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChaptersBySubjectProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$chaptersBySubjectHash() => r'1506585512e3713ef1c67fc5daad1dab9abbf805';

final class ChaptersBySubjectFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Chapter>>, String> {
  ChaptersBySubjectFamily._()
    : super(
        retry: null,
        name: r'chaptersBySubjectProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChaptersBySubjectProvider call(String subjectId) =>
      ChaptersBySubjectProvider._(argument: subjectId, from: this);

  @override
  String toString() => r'chaptersBySubjectProvider';
}

@ProviderFor(QuestionsNotifier)
final questionsProvider = QuestionsNotifierFamily._();

final class QuestionsNotifierProvider
    extends $AsyncNotifierProvider<QuestionsNotifier, List<Question>> {
  QuestionsNotifierProvider._({
    required QuestionsNotifierFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'questionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$questionsNotifierHash();

  @override
  String toString() {
    return r'questionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  QuestionsNotifier create() => QuestionsNotifier();

  @override
  bool operator ==(Object other) {
    return other is QuestionsNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$questionsNotifierHash() => r'f6bf06a1c251c915aa9c1f6983dbe938dcf03a0c';

final class QuestionsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          QuestionsNotifier,
          AsyncValue<List<Question>>,
          List<Question>,
          FutureOr<List<Question>>,
          String
        > {
  QuestionsNotifierFamily._()
    : super(
        retry: null,
        name: r'questionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  QuestionsNotifierProvider call(String chapterId) =>
      QuestionsNotifierProvider._(argument: chapterId, from: this);

  @override
  String toString() => r'questionsProvider';
}

abstract class _$QuestionsNotifier extends $AsyncNotifier<List<Question>> {
  late final _$args = ref.$arg as String;
  String get chapterId => _$args;

  FutureOr<List<Question>> build(String chapterId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Question>>, List<Question>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Question>>, List<Question>>,
              AsyncValue<List<Question>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(bookmarkedQuestions)
final bookmarkedQuestionsProvider = BookmarkedQuestionsProvider._();

final class BookmarkedQuestionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Question>>,
          List<Question>,
          FutureOr<List<Question>>
        >
    with $FutureModifier<List<Question>>, $FutureProvider<List<Question>> {
  BookmarkedQuestionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookmarkedQuestionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookmarkedQuestionsHash();

  @$internal
  @override
  $FutureProviderElement<List<Question>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Question>> create(Ref ref) {
    return bookmarkedQuestions(ref);
  }
}

String _$bookmarkedQuestionsHash() =>
    r'28e6cc68443071adce773cd31ad89eeead2c58bb';

@ProviderFor(questionsByBoard)
final questionsByBoardProvider = QuestionsByBoardFamily._();

final class QuestionsByBoardProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Question>>,
          List<Question>,
          FutureOr<List<Question>>
        >
    with $FutureModifier<List<Question>>, $FutureProvider<List<Question>> {
  QuestionsByBoardProvider._({
    required QuestionsByBoardFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'questionsByBoardProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$questionsByBoardHash();

  @override
  String toString() {
    return r'questionsByBoardProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Question>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Question>> create(Ref ref) {
    final argument = this.argument as String;
    return questionsByBoard(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is QuestionsByBoardProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$questionsByBoardHash() => r'3cde7c8b466d9b42b7c9932b4537467190184347';

final class QuestionsByBoardFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Question>>, String> {
  QuestionsByBoardFamily._()
    : super(
        retry: null,
        name: r'questionsByBoardProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  QuestionsByBoardProvider call(String board) =>
      QuestionsByBoardProvider._(argument: board, from: this);

  @override
  String toString() => r'questionsByBoardProvider';
}

@ProviderFor(questionsByYear)
final questionsByYearProvider = QuestionsByYearFamily._();

final class QuestionsByYearProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Question>>,
          List<Question>,
          FutureOr<List<Question>>
        >
    with $FutureModifier<List<Question>>, $FutureProvider<List<Question>> {
  QuestionsByYearProvider._({
    required QuestionsByYearFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'questionsByYearProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$questionsByYearHash();

  @override
  String toString() {
    return r'questionsByYearProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Question>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Question>> create(Ref ref) {
    final argument = this.argument as int;
    return questionsByYear(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is QuestionsByYearProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$questionsByYearHash() => r'893f72f1d609002570a9c43a41ba76b79d38566e';

final class QuestionsByYearFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Question>>, int> {
  QuestionsByYearFamily._()
    : super(
        retry: null,
        name: r'questionsByYearProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  QuestionsByYearProvider call(int year) =>
      QuestionsByYearProvider._(argument: year, from: this);

  @override
  String toString() => r'questionsByYearProvider';
}

@ProviderFor(userAnalytics)
final userAnalyticsProvider = UserAnalyticsProvider._();

final class UserAnalyticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserAnalytics>,
          UserAnalytics,
          FutureOr<UserAnalytics>
        >
    with $FutureModifier<UserAnalytics>, $FutureProvider<UserAnalytics> {
  UserAnalyticsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userAnalyticsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userAnalyticsHash();

  @$internal
  @override
  $FutureProviderElement<UserAnalytics> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UserAnalytics> create(Ref ref) {
    return userAnalytics(ref);
  }
}

String _$userAnalyticsHash() => r'9fc34a95b5e83573af4124db036b2b9ef5eacfae';

@ProviderFor(dailyStreak)
final dailyStreakProvider = DailyStreakProvider._();

final class DailyStreakProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  DailyStreakProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailyStreakProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailyStreakHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return dailyStreak(ref);
  }
}

String _$dailyStreakHash() => r'47451c7501a74e67601fee970ab658e8e8b118af';
