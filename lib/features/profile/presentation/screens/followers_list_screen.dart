import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:reelify/core/constants/app_constants.dart';

/// Screen that lists either the followers or following of a user.
class FollowersListScreen extends StatelessWidget {
  final String userId;
  /// 'followers' or 'following'
  final String type;

  const FollowersListScreen({
    super.key,
    required this.userId,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final title = type == 'followers' ? 'Followers' : 'Following';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .collection(type) // 'followers' or 'following'
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                  color: theme.colorScheme.primary),
            );
          }
          if (snap.hasError) {
            return Center(
              child: Text('Error: ${snap.error}',
                  style: theme.textTheme.bodyMedium),
            );
          }

          final docs = snap.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type == 'followers'
                        ? Icons.people_outline_rounded
                        : Icons.person_add_alt_1_rounded,
                    size: 64,
                    color: theme.hintColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    type == 'followers'
                        ? 'No followers yet'
                        : 'Not following anyone yet',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: docs.length,
            separatorBuilder: (_, __) =>
                const Divider(indent: 68, height: 1),
            itemBuilder: (context, i) {
              // Each doc ID is the user ID of the person
              final targetUserId = docs[i].id;
              return _UserListTile(
                userId: targetUserId,
                onTap: () =>
                    context.push('/home/profile/$targetUserId'),
              );
            },
          );
        },
      ),
    );
  }
}

class _UserListTile extends StatelessWidget {
  final String userId;
  final VoidCallback onTap;

  const _UserListTile({required this.userId, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Loading…'),
          );
        }

        final data = snap.data?.data() as Map<String, dynamic>?;
        final displayName = data?['displayName'] as String? ?? 'User';
        final username = data?['username'] as String? ?? '';
        final avatar = data?['profileImage'] as String? ?? '';
        final bio = data?['bio'] as String? ?? '';
        final followers = data?['followersCount'] as int? ?? 0;

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: CircleAvatar(
            radius: 26,
            backgroundImage:
                avatar.isNotEmpty ? NetworkImage(avatar) : null,
            backgroundColor:
                theme.colorScheme.primary.withValues(alpha: 0.15),
            child: avatar.isEmpty
                ? Text(
                    displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          title: Text(displayName,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (username.isNotEmpty)
                Text('@$username',
                    style: TextStyle(
                        fontSize: 12, color: theme.hintColor)),
              if (bio.isNotEmpty)
                Text(
                  bio,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: theme.hintColor),
                ),
            ],
          ),
          trailing: Text(
            _format(followers),
            style: TextStyle(
                fontSize: 12,
                color: theme.hintColor,
                fontWeight: FontWeight.w500),
          ),
          onTap: onTap,
        );
      },
    );
  }

  String _format(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}
