// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_bank_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns a list of distinct boards from the questions table.

@ProviderFor(distinctBoards)
final distinctBoardsProvider = DistinctBoardsProvider._();

/// Returns a list of distinct boards from the questions table.

final class DistinctBoardsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Returns a list of distinct boards from the questions table.
  DistinctBoardsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'distinctBoardsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$distinctBoardsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return distinctBoards(ref);
  }
}

String _$distinctBoardsHash() => r'89f8bb7c086f84cebd099f73b988181e91e60733';

/// Returns a list of distinct years from the questions table.

@ProviderFor(distinctYears)
final distinctYearsProvider = DistinctYearsProvider._();

/// Returns a list of distinct years from the questions table.

final class DistinctYearsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<int>>,
          List<int>,
          FutureOr<List<int>>
        >
    with $FutureModifier<List<int>>, $FutureProvider<List<int>> {
  /// Returns a list of distinct years from the questions table.
  DistinctYearsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'distinctYearsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$distinctYearsHash();

  @$internal
  @override
  $FutureProviderElement<List<int>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<int>> create(Ref ref) {
    return distinctYears(ref);
  }
}

String _$distinctYearsHash() => r'232d86a7178a543c3ae731b93278bb491d2dd1eb';

/// Returns question count per subject id: { subjectId: count }

@ProviderFor(subjectQuestionCounts)
final subjectQuestionCountsProvider = SubjectQuestionCountsProvider._();

/// Returns question count per subject id: { subjectId: count }

final class SubjectQuestionCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, int>>,
          Map<String, int>,
          FutureOr<Map<String, int>>
        >
    with $FutureModifier<Map<String, int>>, $FutureProvider<Map<String, int>> {
  /// Returns question count per subject id: { subjectId: count }
  SubjectQuestionCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subjectQuestionCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subjectQuestionCountsHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, int>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, int>> create(Ref ref) {
    return subjectQuestionCounts(ref);
  }
}

String _$subjectQuestionCountsHash() =>
    r'2e9b48cce1f2b34f8ad420ff389d220711628058';
