import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:reelify/core/constants/app_constants.dart';
import 'package:reelify/features/ai_recommendation/domain/models/user_interaction.dart';
import 'package:reelify/services/offline/sqlite_service.dart';
import 'package:uuid/uuid.dart';

class InteractionTracker {
  final FirebaseFirestore _firestore;
  final SqliteService _sqlite;
  final Connectivity _connectivity;
  final _uuid = const Uuid();

  InteractionTracker({
    FirebaseFirestore? firestore,
    SqliteService? sqlite,
    Connectivity? connectivity,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _sqlite = sqlite ?? SqliteService.instance,
        _connectivity = connectivity ?? Connectivity();

  /// Track when a user watches a video
  Future<void> trackWatch({
    required String userId,
    required String videoId,
    required String category,
    required double watchRatio, // 0.0 - 1.0
    bool liked = false,
    bool commented = false,
    bool skipped = false,
  }) async {
    final interaction = UserInteraction(
      id: _uuid.v4(),
      userId: userId,
      videoId: videoId,
      category: category,
      watchRatio: watchRatio,
      liked: liked,
      commented: commented,
      skipped: skipped,
      timestamp: DateTime.now(),
    );

    // Always save locally first
    await _sqlite.saveInteraction(interaction);

    // Sync to Firestore if connected
    final result = await _connectivity.checkConnectivity();
    if (result.first != ConnectivityResult.none) {
      await _syncToFirestore(interaction);
    }
  }

  Future<void> _syncToFirestore(UserInteraction interaction) async {
    try {
      await _firestore
          .collection(AppConstants.interactionsCollection)
          .doc(interaction.id)
          .set(interaction.toFirestore());
      await _sqlite.markSynced(interaction.id);
    } catch (_) {
      // Will retry on next sync
    }
  }

  /// Sync all pending local interactions to Firestore
  Future<void> syncPendingInteractions() async {
    final pending = await _sqlite.getUnsyncedInteractions();
    for (final interaction in pending) {
      await _syncToFirestore(interaction);
    }
  }
}
