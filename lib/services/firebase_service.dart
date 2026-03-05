import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:reelify/core/constants/app_constants.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  // Firestore helpers
  CollectionReference get usersRef =>
      firestore.collection(AppConstants.usersCollection);
  CollectionReference get videosRef =>
      firestore.collection(AppConstants.videosCollection);
  CollectionReference get commentsRef =>
      firestore.collection(AppConstants.commentsCollection);
  CollectionReference get interactionsRef =>
      firestore.collection(AppConstants.interactionsCollection);

  // Update a document safely
  Future<void> updateDocument(
      String collection, String docId, Map<String, dynamic> data) async {
    await firestore
        .collection(collection)
        .doc(docId)
        .update(data);
  }

  // Set a document (merge)
  Future<void> setDocument(
      String collection, String docId, Map<String, dynamic> data,
      {bool merge = true}) async {
    await firestore
        .collection(collection)
        .doc(docId)
        .set(data, SetOptions(merge: merge));
  }

  // Stream a document
  Stream<DocumentSnapshot> streamDocument(
      String collection, String docId) {
    return firestore.collection(collection).doc(docId).snapshots();
  }

  // Batch update watch history
  Future<void> addToWatchHistory(
      String userId, String videoId) async {
    await usersRef.doc(userId).update({
      'watchHistory': FieldValue.arrayUnion([videoId]),
    });
  }
}
