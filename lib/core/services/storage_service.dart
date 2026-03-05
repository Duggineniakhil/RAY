import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final extension = imageFile.path.split('.').last;
      final ref = _storage
          .ref()
          .child('users')
          .child(user.uid)
          .child('profile.$extension');

      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
      return null;
    }
  }

  Future<String?> uploadVideo(File videoFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage
          .ref()
          .child('users')
          .child(user.uid)
          .child('videos')
          .child('$fileName.mp4');

      final uploadTask = await ref.putFile(videoFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading video: $e');
      return null;
    }
  }

  Future<String?> uploadThumbnail(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = _storage
          .ref()
          .child('users')
          .child(user.uid)
          .child('thumbnails')
          .child('$fileName.jpg');

      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading thumbnail: $e');
      return null;
    }
  }
}
