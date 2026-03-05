import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reelify/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:reelify/features/auth/domain/models/user_model.dart';
import 'package:reelify/features/auth/domain/repositories/auth_repository.dart';

// Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

// Auth State Stream (Firebase User)
final authStateProvider = StreamProvider<UserModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

// Current User Provider
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  return repo.getCurrentUser();
});

// Auth Notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository _repo;

  AuthNotifier(this._repo) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    _repo.authStateChanges.listen((user) {
      state = AsyncValue.data(user);
    });
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.signInWithEmail(email: email, password: password),
    );
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _repo.signUpWithEmail(
          email: email, password: password, username: username),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repo.signInWithGoogle());
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
