import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadProfileImage(Uint8List bytes, String extension) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final ref = _storage
          .ref()
          .child('users')
          .child(user.uid)
          .child('profile.$extension');

      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/$extension'),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  Future<String?> uploadVideo(Uint8List bytes, String fileName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final ref = _storage
          .ref()
          .child('users')
          .child(user.uid)
          .child('videos')
          .child('$fileName.mp4');

      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'video/mp4'),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading video: $e');
      return null;
    }
  }

  Future<String?> uploadThumbnail(Uint8List bytes, String fileName) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final ref = _storage
          .ref()
          .child('users')
          .child(user.uid)
          .child('thumbnails')
          .child('$fileName.jpg');

      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading thumbnail: $e');
      return null;
    }
  }
}
