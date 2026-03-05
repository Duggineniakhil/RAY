import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reelify/core/constants/app_constants.dart';
import 'package:reelify/generated/app_localizations.dart';
import 'package:reelify/features/auth/presentation/providers/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';
import 'package:reelify/features/video_feed/presentation/providers/video_feed_provider.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String videoId;
  const CommentsScreen({super.key, required this.videoId});

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _commentController = TextEditingController();
  final _uuid = const Uuid();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final commentId = _uuid.v4();
    await FirebaseFirestore.instance
        .collection(AppConstants.commentsCollection)
        .doc(commentId)
        .set({
      'videoId': widget.videoId,
      'userId': user.id,
      'username': user.username,
      'userAvatar': user.profileImage,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': 0,
    });

    // Increment comment count on video
    await FirebaseFirestore.instance
        .collection(AppConstants.videosCollection)
        .doc(widget.videoId)
        .update({'commentsCount': FieldValue.increment(1)});

    ref.read(videoFeedProvider.notifier).incrementCommentCount(widget.videoId);

    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 4),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.comments,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: theme.hintColor),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                Divider(color: theme.dividerColor, height: 1),

                // Comments list
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(AppConstants.commentsCollection)
                        .where('videoId', isEqualTo: widget.videoId)
                        .orderBy('timestamp', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator(
                                color: theme.colorScheme.primary));
                      }
                      
                      // Handle the "Index Building" error gracefully in UI
                      if (snapshot.hasError) {
                         return Center(
                           child: Padding(
                             padding: const EdgeInsets.all(20.0),
                             child: Column(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Icon(Icons.warning_amber_rounded, size: 48, color: theme.colorScheme.primary),
                                 const SizedBox(height: 12),
                                 const Text('Database Index Building', style: TextStyle(fontWeight: FontWeight.bold)),
                                 const SizedBox(height: 8),
                                 Text(
                                   'Please wait a few minutes and try again.',
                                   textAlign: TextAlign.center,
                                   style: Theme.of(context).textTheme.bodySmall,
                                 ),
                               ],
                             ),
                           ),
                         );
                      }

                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded,
                                  size: 48,
                                  color: theme.hintColor),
                              const SizedBox(height: 12),
                              Text('No comments yet', // Using hardcoded or simple string if localized keys are missing besides core ones
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium),
                              Text('Be the first to comment!',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: docs.length,
                        itemBuilder: (context, i) {
                          final data =
                              docs[i].data() as Map<String, dynamic>;
                          final timestamp =
                              (data['timestamp'] as Timestamp?)
                                  ?.toDate();
                          return _CommentTile(
                            username: data['username'] ?? 'user',
                            avatar: data['userAvatar'] ?? '',
                            text: data['text'] ?? '',
                            timeAgo: timestamp != null
                                ? timeago.format(timestamp)
                                : '',
                          ).animate(delay: (i * 50).ms).fadeIn().slideX(
                                begin: -0.1);
                        },
                      );
                    },
                  ),
                ),

                // Comment input
                Container(
                  padding: EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      MediaQuery.of(context).viewInsets.bottom > 0 ? MediaQuery.of(context).viewInsets.bottom + 12 : 12),
                  decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(color: theme.dividerColor)),
                    color: theme.scaffoldBackgroundColor,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: TextStyle(
                              color: theme.colorScheme.onSurface),
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: l10n.addComment,
                            hintStyle: TextStyle(color: theme.hintColor),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _submitComment,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary,
                          ),
                          child: const Icon(Icons.send_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CommentTile extends StatelessWidget {
  final String username;
  final String avatar;
  final String text;
  final String timeAgo;

  const _CommentTile({
    required this.username,
    required this.avatar,
    required this.text,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.surface,
            backgroundImage:
                avatar.isNotEmpty ? NetworkImage(avatar) : null,
            child: avatar.isEmpty
                ? const Icon(Icons.person_rounded,
                    color: Colors.white, size: 20)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('@$username',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        )),
                    const SizedBox(width: 8),
                    Text(timeAgo,
                        style: TextStyle(
                            color: theme.hintColor, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(text,
                    style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color, fontSize: 14)),
              ],
            ),
          ),
          Icon(Icons.favorite_border_rounded,
              color: theme.hintColor, size: 18),
        ],
      ),
    );
  }
}
