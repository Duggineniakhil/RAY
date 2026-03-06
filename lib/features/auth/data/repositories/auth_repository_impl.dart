import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reelify/core/constants/app_constants.dart';
import 'package:reelify/features/auth/domain/models/user_model.dart';
import 'package:reelify/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await _getUserFromFirestore(user.uid);
    });
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) throw Exception('User not found after sign in.');
    
    return await _getUserFromFirestore(user.uid) ??
        _createDefaultUser(user);
  }

  @override
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = credential.user;
    if (firebaseUser == null) throw Exception('User not found after account creation.');
    
    await firebaseUser.updateDisplayName(username);
    final user = UserModel(
      id: firebaseUser.uid,
      email: email,
      username: username.toLowerCase().replaceAll(' ', '_'),
      displayName: username,
      createdAt: DateTime.now(),
    );
    await _saveUserToFirestore(user);
    return user;
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in was cancelled');

    final googleAuth = await googleUser.authentication;
    // Check if authentication details are unexpectedly null
    // ignore: unnecessary_null_comparison
    if (googleAuth == null) {
       throw Exception('Failed to obtain Google authentication details.');
    }
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;

    if (firebaseUser == null) {
      throw Exception('Failed to obtain Firebase user after Google sign-in.');
    }

    // Check if user already exists
    final existing = await _getUserFromFirestore(firebaseUser.uid);
    if (existing != null) return existing;

    // Create new user
    final username = (googleUser.displayName ?? googleUser.email)
        .toLowerCase()
        .replaceAll(' ', '_');
    final user = UserModel(
      id: firebaseUser.uid,
      email: googleUser.email,
      username: username,
      displayName: googleUser.displayName ?? username,
      profileImage: googleUser.photoUrl ?? '',
      createdAt: DateTime.now(),
    );
    await _saveUserToFirestore(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return await _getUserFromFirestore(user.uid);
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoUrl, String? bio, String? username, bool? isPrivate}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    if (displayName != null) await user.updateDisplayName(displayName);
    if (photoUrl != null) await user.updatePhotoURL(photoUrl);
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .update({
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'profileImage': photoUrl,
      if (bio != null) 'bio': bio,
      if (username != null) 'username': username,
      if (isPrivate != null) 'isPrivate': isPrivate,
    });
  }

  // Helpers
  Future<UserModel?> _getUserFromFirestore(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> _saveUserToFirestore(UserModel user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .set(user.toFirestore());
  }

  UserModel _createDefaultUser(User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      username: firebaseUser.displayName?.toLowerCase().replaceAll(' ', '_') ??
          'user_${firebaseUser.uid.substring(0, 6)}',
      displayName: firebaseUser.displayName ?? 'User',
      profileImage: firebaseUser.photoURL ?? '',
      createdAt: DateTime.now(),
    );
  }
}
