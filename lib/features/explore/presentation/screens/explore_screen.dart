import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:reelify/generated/app_localizations.dart';
import 'package:reelify/features/video_feed/domain/models/video_model.dart';
import 'package:reelify/features/explore/presentation/providers/explore_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:reelify/core/constants/app_constants.dart';
import 'package:reelify/core/services/dummy_data_service.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  const ExploreScreen({super.key, this.initialQuery});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(exploreProvider.notifier).search(widget.initialQuery!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(l10n.explore, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.auto_fix_high_rounded, color: theme.colorScheme.primary),
            tooltip: 'Seed Dummy Data',
            onPressed: () async {
              await DummyDataService.seedVideos();
              ref.read(exploreProvider.notifier).loadTrending();
              if (!context.mounted) return;
      if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dummy videos seeded!')),
                );
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.search_rounded, color: theme.colorScheme.onSurface),
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
                          color: isSelected ? theme.colorScheme.onPrimary : theme.textTheme.bodyMedium?.color,
                          fontSize: 12,
                        )),
                    selected: isSelected,
                    selectedColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.surface,
                    side: BorderSide(color: isSelected ? theme.colorScheme.primary : theme.dividerColor),
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = isSelected ? null : category;
                      });
                      if (!isSelected) {
                        ref.read(exploreProvider.notifier).loadTrending(category: category);
                      } else {
                        ref.read(exploreProvider.notifier).loadTrending();
                      }
                    },
                  ),
                );
              },
            ),
          ),

          Divider(color: theme.dividerColor, height: 1),

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
  final List<VideoModel>? searchResults;

  const _ExploreVideoGrid({this.selectedCategory, this.searchResults});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exploreState = ref.watch(exploreProvider);
    final videos = searchResults ?? exploreState.trendingVideos;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (exploreState.isLoading && videos.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      );
    }

    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_library_outlined, color: theme.hintColor, size: 64),
            const SizedBox(height: 8),
            Text(
              selectedCategory != null
                  ? 'No videos in $selectedCategory yet'
                  : l10n.noVideosYet,
              style: TextStyle(color: theme.hintColor),
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
      itemBuilder: (context, i) => _VideoGridTile(
        videos: videos,
        index: i,
      ),
    );
  }
}

class _VideoGridTile extends StatelessWidget {
  final List<VideoModel> videos;
  final int index;

  const _VideoGridTile({required this.videos, required this.index});

  @override
  Widget build(BuildContext context) {
    final video = videos[index];
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push('/home/video', extra: {
        'videos': videos,
        'initialIndex': index,
      }),
      child: Stack(
        fit: StackFit.expand,
        children: [
          video.thumbnail.isNotEmpty
              ? Image.network(video.thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: theme.colorScheme.surface))
              : Container(
                  color: theme.colorScheme.surface,
                  child: Icon(Icons.play_circle_outline_rounded,
                      color: theme.hintColor, size: 32),
                ),
          // View count overlay
          Positioned(
            bottom: 4,
            left: 4,
            child: Row(
              children: [
                const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 14),
                const SizedBox(width: 2),
                Text(
                  _format(video.views),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
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
    if (query.trim().isEmpty) return const SizedBox();
    
    // Trigger the search
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exploreProvider.notifier).search(query);
    });

    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(exploreProvider);
        return _ExploreVideoGrid(searchResults: state.trendingVideos);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: AppConstants.videoCategories
          .where((c) => c.toLowerCase().contains(query.toLowerCase()))
          .map((c) => ListTile(
                leading: Icon(Icons.label_outline_rounded, color: theme.colorScheme.primary),
                title: Text(c, style: TextStyle(color: theme.colorScheme.onSurface)),
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
    final theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: theme.hintColor),
      ),
      textTheme: theme.textTheme.copyWith(
        titleLarge: TextStyle(color: theme.colorScheme.onSurface),
      ),
      scaffoldBackgroundColor: theme.scaffoldBackgroundColor,
    );
  }
}
