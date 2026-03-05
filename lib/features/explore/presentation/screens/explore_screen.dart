import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reelify/core/theme/app_theme.dart';
import 'package:reelify/features/video_feed/domain/models/video_model.dart';
import 'package:reelify/features/video_feed/presentation/providers/video_feed_provider.dart';
import 'package:reelify/core/constants/app_constants.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Explore', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary),
            onPressed: () => _showSearchBar(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: AppConstants.videoCategories.length,
              itemBuilder: (context, index) {
                final category = AppConstants.videoCategories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                          fontSize: 12,
                        )),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    side: BorderSide(color: isSelected ? AppColors.primary : AppColors.divider),
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = isSelected ? null : category;
                      });
                      if (!isSelected) {
                        ref.read(videoFeedProvider.notifier).filterByCategory(category);
                      } else {
                        ref.read(videoFeedProvider.notifier).refreshFeed();
                      }
                    },
                  ),
                );
              },
            ),
          ),

          const Divider(color: AppColors.divider, height: 1),

          // Video grid
          Expanded(
            child: _ExploreVideoGrid(selectedCategory: _selectedCategory),
          ),
        ],
      ),
    );
  }

  void _showSearchBar(BuildContext context) {
    showSearch(
      context: context,
      delegate: _VideoSearchDelegate(ref),
    );
  }
}

class _ExploreVideoGrid extends ConsumerWidget {
  final String? selectedCategory;
  const _ExploreVideoGrid({this.selectedCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(videoFeedProvider);
    final videos = feedState.videos;

    if (feedState.isLoading && videos.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.video_library_outlined, color: AppColors.textSecondary, size: 64),
            const SizedBox(height: 12),
            Text(
              selectedCategory != null ? 'No videos in $selectedCategory' : 'No videos yet',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
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
      itemBuilder: (context, i) => _VideoGridTile(video: videos[i]),
    );
  }
}

class _VideoGridTile extends StatelessWidget {
  final VideoModel video;
  const _VideoGridTile({required this.video});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        video.thumbnail.isNotEmpty
            ? Image.network(video.thumbnail, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.surface))
            : Container(
                color: AppColors.surface,
                child: const Icon(Icons.play_circle_outline_rounded,
                    color: AppColors.textSecondary, size: 32),
              ),
        // View count overlay
        Positioned(
          bottom: 4,
          left: 4,
          child: Row(
            children: [
              const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14),
              const SizedBox(width: 2),
              Text(
                _format(video.views),
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _format(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _VideoSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;
  _VideoSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) {
    ref.read(videoFeedProvider.notifier).searchVideos(query);
    close(context, query);
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: AppConstants.videoCategories
          .where((c) => c.toLowerCase().contains(query.toLowerCase()))
          .map((c) => ListTile(
                leading: const Icon(Icons.label_outline_rounded, color: AppColors.primary),
                title: Text(c, style: const TextStyle(color: AppColors.textPrimary)),
                onTap: () {
                  query = c;
                  showResults(context);
                },
              ))
          .toList(),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: AppColors.textSecondary),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: AppColors.textPrimary),
      ),
      scaffoldBackgroundColor: AppColors.background,
    );
  }
}
