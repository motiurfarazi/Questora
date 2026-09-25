import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  User? build() {
    final authRepository = ref.watch(authRepositoryProvider);

    // Listen to auth state changes
    final subscription = authRepository.authStateChanges.listen((data) {
      state = data.session?.user;
    });

    ref.onDispose(() {
      subscription.cancel();
    });

    return authRepository.currentUser;
  }

  Future<void> signIn(String email, String password) async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.signInWithEmailPassword(email, password);
  }

  Future<void> signUp(String email, String password) async {
    final authRepo = ref.read(authRepositoryProvider);
    // You could also create the initial profile record here
    await authRepo.signUpWithEmailPassword(email, password);
  }

  Future<bool> signInWithGoogle() async {
    return await ref.read(authRepositoryProvider).signInWithGoogle();
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }
}
