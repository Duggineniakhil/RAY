import 'package:reelify/features/auth/domain/models/user_model.dart';

abstract class AuthRepository {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  });
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  });
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> updateProfile({String? displayName, String? photoUrl, String? bio, String? username});
}
