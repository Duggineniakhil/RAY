import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reelify/core/constants/app_constants.dart';
import 'package:reelify/core/theme/app_theme.dart';
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

    if (doc.exists && mounted) {
      setState(() {
        _profileUser = UserModel.fromFirestore(doc);
        _isFollowing = isFollowing;
        _isLoading = false;
      });
    } else {
      if(mounted) setState(() => _isLoading = false);
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

    if (_isLoading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            backgroundColor: AppColors.background,
            expandedHeight: 0,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
            title: Text(_profileUser?.username ?? 'Profile'),
            actions: [
              if (isOwnProfile)
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => context.push('/home/settings'),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: _buildProfileHeader(isOwnProfile),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textSecondary,
                tabs: const [
                  Tab(icon: Icon(Icons.grid_on_rounded)),
                  Tab(icon: Icon(Icons.favorite_border_rounded)),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _VideoGrid(userId: widget.userId),
            _VideoGrid(userId: widget.userId, likedOnly: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isOwnProfile) {
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
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              )),

          if (user?.bio.isNotEmpty == true) ...[
            const SizedBox(height: 6),
            Text(user!.bio,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
          ],

          const SizedBox(height: 16),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StatItem(
                  count: user?.followingCount ?? 0, label: 'Following'),
              const SizedBox(width: 32),
              _StatItem(
                  count: user?.followersCount ?? 0, label: 'Followers'),
              const SizedBox(width: 32),
              const _StatItem(count: 0, label: 'Likes'),
            ],
          ),

          const SizedBox(height: 16),

          // Follow/Edit button
          if (!isOwnProfile)
            ElevatedButton(
              onPressed: _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isFollowing ? AppColors.surfaceVariant : AppColors.primary,
                minimumSize: const Size(160, 42),
              ),
              child: Text(_isFollowing ? 'Following' : 'Follow'),
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
              child: const Text('Edit Profile'),
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
    return Column(
      children: [
        Text(_format(count),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            )),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
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

    return FutureBuilder<List<VideoModel>>(
      future: repo.getUserVideos(userId, likedOnly: likedOnly),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }
        final videos = snapshot.data ?? [];
        if (videos.isEmpty) {
          return Center(
            child: Text(
              likedOnly ? 'No liked videos' : 'No videos posted yet',
              style: const TextStyle(color: AppColors.textSecondary),
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
          itemBuilder: (context, i) => Container(
            color: AppColors.surface,
            child: videos[i].thumbnail.isNotEmpty
                ? Image.network(videos[i].thumbnail, fit: BoxFit.cover)
                : const Center(
                    child: Icon(Icons.play_circle_outline_rounded,
                        color: AppColors.textSecondary, size: 32)),
          ),
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppColors.background, child: tabBar);
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
