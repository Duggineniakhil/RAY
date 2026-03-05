import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reelify/core/constants/app_constants.dart';
import 'package:reelify/core/theme/app_theme.dart';
import 'package:reelify/generated/app_localizations.dart';
import 'package:reelify/features/auth/domain/models/user_model.dart';
import 'package:reelify/features/auth/presentation/providers/auth_provider.dart';
import 'package:reelify/features/video_feed/domain/models/video_model.dart';
import 'package:reelify/features/video_feed/presentation/providers/video_feed_provider.dart';
import 'package:reelify/features/profile/presentation/widgets/edit_profile_dialog.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;
  UserModel? _profileUser;
  bool _isLoading = true;
  int _totalLikes = 0;
  int _videoCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final currentUser = ref.read(authStateProvider).valueOrNull;
    final doc = await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(widget.userId)
        .get();

    bool isFollowing = false;
    if (currentUser != null && doc.exists) {
      final followDoc = await FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(widget.userId)
          .collection('followers')
          .doc(currentUser.id)
          .get();
      isFollowing = followDoc.exists;
    }

    // Load video count and total likes
    int totalLikes = 0;
    int videoCount = 0;
    try {
      final videosSnap = await FirebaseFirestore.instance
          .collection('videos')
          .where('creatorId', isEqualTo: widget.userId)
          .get();
      videoCount = videosSnap.docs.length;
      for (final vDoc in videosSnap.docs) {
        totalLikes += (vDoc.data()['likes'] as int?) ?? 0;
      }
    } catch (_) {}

    if (doc.exists && mounted) {
      setState(() {
        _profileUser = UserModel.fromFirestore(doc);
        _isFollowing = isFollowing;
        _totalLikes = totalLikes;
        _videoCount = videoCount;
        _isLoading = false;
      });
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    final currentUser = ref.read(authStateProvider).valueOrNull;
    if (currentUser == null) return;

    final wasFollowing = _isFollowing;
    setState(() => _isFollowing = !_isFollowing);

    final batch = FirebaseFirestore.instance.batch();
    final db = FirebaseFirestore.instance;
    final profileRef = db.collection(AppConstants.usersCollection).doc(widget.userId);
    final currentUserRef = db.collection(AppConstants.usersCollection).doc(currentUser.id);

    final followerDocRef = profileRef.collection('followers').doc(currentUser.id);
    final followingDocRef = currentUserRef.collection('following').doc(widget.userId);

    if (!wasFollowing) {
      batch.set(followerDocRef, {'timestamp': FieldValue.serverTimestamp()});
      batch.set(followingDocRef, {'timestamp': FieldValue.serverTimestamp()});
      batch.update(profileRef, {'followersCount': FieldValue.increment(1)});
      batch.update(currentUserRef, {'followingCount': FieldValue.increment(1)});
      
      setState(() {
        if (_profileUser != null) {
          _profileUser = _profileUser!.copyWith(followersCount: _profileUser!.followersCount + 1);
        }
      });
    } else {
      batch.delete(followerDocRef);
      batch.delete(followingDocRef);
      batch.update(profileRef, {'followersCount': FieldValue.increment(-1)});
      batch.update(currentUserRef, {'followingCount': FieldValue.increment(-1)});
      
      setState(() {
        if (_profileUser != null) {
          _profileUser = _profileUser!.copyWith(followersCount: _profileUser!.followersCount > 0 ? _profileUser!.followersCount - 1 : 0);
        }
      });
    }
    
    try {
      await batch.commit();
    } catch (_) {
      if (mounted) {
        setState(() {
          _isFollowing = wasFollowing;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authStateProvider).valueOrNull;
    final isOwnProfile = currentUser?.id == widget.userId;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: theme.colorScheme.primary)),
      );
    }

    final isPrivateAndNotFollowing = (_profileUser?.isPrivate ?? false) && !_isFollowing && !isOwnProfile;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            expandedHeight: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text(_profileUser?.username ?? l10n.profile),
            actions: [
              if (isOwnProfile)
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push('/home/settings'),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: _buildProfileHeader(isOwnProfile, theme, l10n),
          ),
          if (!isPrivateAndNotFollowing)
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: theme.colorScheme.primary,
                  labelColor: theme.colorScheme.onSurface,
                  unselectedLabelColor: theme.hintColor,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on_rounded)),
                    Tab(icon: Icon(Icons.favorite_border_rounded)),
                  ],
                ),
                theme.scaffoldBackgroundColor,
              ),
            ),
        ],
        body: isPrivateAndNotFollowing
            ? _buildPrivateAccountPlaceholder(theme, l10n)
            : TabBarView(
                controller: _tabController,
                children: [
                  _VideoGrid(userId: widget.userId),
                  _VideoGrid(userId: widget.userId, likedOnly: true),
                ],
              ),
      ),
    );
  }

  Widget _buildPrivateAccountPlaceholder(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded, size: 64, color: theme.hintColor),
          const SizedBox(height: 16),
          Text(
            'This Account is Private',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Follow this account to see their videos and likes.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(bool isOwnProfile, ThemeData theme, AppLocalizations l10n) {
    final user = _profileUser;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                  colors: AppColors.primaryGradient),
              image: user?.profileImage.isNotEmpty == true
                  ? DecorationImage(
                      image: NetworkImage(user!.profileImage),
                      fit: BoxFit.cover)
                  : null,
            ),
            child: user?.profileImage.isNotEmpty != true
                ? const Icon(Icons.person_rounded,
                    color: Colors.white, size: 48)
                : null,
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),

          const SizedBox(height: 12),

          Text('@${user?.username ?? 'user'}',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              )),

          if (user?.bio.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(user!.bio,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: theme.hintColor, fontSize: 13)),
          ],

          const SizedBox(height: 16),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatItem(
                  count: user?.followingCount ?? 0, label: l10n.following),
              const SizedBox(width: 24),
              _StatItem(
                  count: user?.followersCount ?? 0, label: l10n.followers),
              const SizedBox(width: 24),
              _StatItem(count: _totalLikes, label: l10n.likes),
              const SizedBox(width: 24),
              _StatItem(count: _videoCount, label: l10n.posts),
            ],
          ),

          const SizedBox(height: 16),

          // Follow/Edit button
          if (!isOwnProfile)
            ElevatedButton(
              onPressed: _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isFollowing ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.primary,
                minimumSize: const Size(160, 42),
              ),
              child: Text(_isFollowing ? l10n.following : l10n.follow),
            )
          else
            OutlinedButton(
              onPressed: () async {
                if (_profileUser == null) return;
                final updated = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => EditProfileDialog(user: _profileUser!),
                );
                if (updated == true) {
                  _loadProfile();
                }
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(160, 42),
              ),
              child: Text(l10n.editProfile),
            ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;
  const _StatItem({required this.count, required this.label});

  String _format(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(_format(count),
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )),
        Text(label,
            style: TextStyle(
                color: theme.hintColor, fontSize: 12)),
      ],
    );
  }
}

class _VideoGrid extends ConsumerWidget {
  final String userId;
  final bool likedOnly;
  const _VideoGrid({required this.userId, this.likedOnly = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(videoRepositoryProvider);
    final theme = Theme.of(context);

    return FutureBuilder<List<VideoModel>>(
      future: repo.getUserVideos(userId, likedOnly: likedOnly),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: theme.colorScheme.primary));
        }
        final videos = snapshot.data ?? [];
        if (videos.isEmpty) {
          return Center(
            child: Text(
              likedOnly ? 'No liked videos' : 'No videos posted yet',
              style: TextStyle(color: theme.hintColor),
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(1),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
            childAspectRatio: 0.6,
          ),
          itemCount: videos.length,
          itemBuilder: (context, i) => GestureDetector(
            onTap: () => context.push('/home/video', extra: videos[i]),
            child: Container(
              color: theme.colorScheme.surface,
              child: videos[i].thumbnail.isNotEmpty
                  ? Image.network(videos[i].thumbnail, fit: BoxFit.cover)
                  : Center(
                      child: Icon(Icons.play_circle_outline_rounded,
                          color: theme.hintColor, size: 32)),
            ),
          ),
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color bgColor;
  _TabBarDelegate(this.tabBar, this.bgColor);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: bgColor, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
