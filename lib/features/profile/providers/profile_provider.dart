import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/profile_model.dart';
import '../data/profile_repository.dart';
import '../../auth/providers/auth_provider.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  FutureOr<ProfileModel?> build() async {
    return _fetchProfile();
  }

  Future<ProfileModel?> _fetchProfile() async {
    final authUser = ref.watch(authProvider);
    if (authUser == null) return null;

    final repo = ref.read(profileRepositoryProvider);
    return await repo.getProfile(authUser.id);
  }

  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? institution,
    String? board,
    String? passingYear,
    String? examType,
    String? groupType,
  }) async {
    final authUser = ref.read(authProvider);
    if (authUser == null) return;

    final repo = ref.read(profileRepositoryProvider);
    final currentProfile = state.value ?? ProfileModel(id: authUser.id);

    final newProfile = currentProfile.copyWith(
      fullName: fullName,
      phone: phone,
      institution: institution,
      board: board,
      passingYear: passingYear,
      examType: examType,
      groupType: groupType,
    );

    // Optimistic update
    state = AsyncData(newProfile);

    try {
      await repo.updateProfile(newProfile);
    } catch (e, st) {
      // Revert on failure
      state = AsyncError(e, st);
    }
  }

  Future<void> updatePassword(String newPassword) async {
    final repo = ref.read(profileRepositoryProvider);
    await repo.updatePassword(newPassword);
  }
}
