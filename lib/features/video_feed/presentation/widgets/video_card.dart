import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:reelify/features/video_feed/presentation/providers/video_controller_manager.dart';
import 'package:reelify/core/utils/camera_filters.dart';
import 'package:reelify/features/ai_recommendation/data/interaction_tracker.dart';
import 'package:reelify/features/auth/presentation/providers/auth_provider.dart';
import 'package:reelify/features/video_feed/domain/models/video_model.dart';
import 'package:reelify/features/video_feed/presentation/widgets/video_info_overlay.dart';
import 'package:reelify/features/video_feed/presentation/widgets/action_buttons.dart';

class VideoCard extends ConsumerStatefulWidget {
  final VideoModel video;
  final bool isActive;
  final int index;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onProfile;

  const VideoCard({
    super.key,
    required this.video,
    required this.isActive,
    required this.index,
    this.onLike,
    this.onComment,
    this.onProfile,
  });

  @override
  ConsumerState<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends ConsumerState<VideoCard>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showPlayIcon = false;
  bool _isMuted = false;
  late AnimationController _likeAnimController;
  late Animation<double> _heartScale;
  late Animation<double> _heartOpacity;
  bool _showHeartAnimation = false;
  bool _liked = false;
  DateTime? _watchStart;
  final _tracker = InteractionTracker();

  @override
  void initState() {
    super.initState();
    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _heartScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.easeOutBack)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1).chain(CurveTween(curve: Curves.easeInOut)), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.5).chain(CurveTween(curve: Curves.easeInBack)), weight: 20),
    ]).animate(_likeAnimController);

    _heartOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_likeAnimController);

    _initVideo();
    if (widget.isActive) _watchStart = DateTime.now();
  }

  @override
  void didUpdateWidget(VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.video.type == 'image') return;
    
    if (widget.isActive != oldWidget.isActive) {
      final manager = VideoControllerManager();
      if (widget.isActive) {
        manager.play(widget.index);
        _watchStart = DateTime.now();
      } else {
        manager.pause(widget.index);
        _trackWatchExit(skipped: true);
      }
    }
  }

  Future<void> _initVideo() async {
    if (widget.video.videoUrl.isEmpty) return;
    if (widget.video.type == 'image') {
      if (mounted) setState(() => _isInitialized = true);
      return;
    }
    
    final manager = VideoControllerManager();
    _controller = await manager.getOrCreateController(widget.index, widget.video.videoUrl);
    
    if (mounted) {
      if (_controller != null) {
        setState(() => _isInitialized = true);
        if (widget.isActive) manager.play(widget.index);
      }
    }
  }

  @override
  void dispose() {
    _trackWatchExit();
    // Do NOT dispose controller here; manager handles it
    _likeAnimController.dispose();
    super.dispose();
  }

  void _trackWatchExit({bool skipped = false}) {
    final userId = ref.read(authStateProvider).valueOrNull?.id;
    if (userId == null || _watchStart == null) return;
    final elapsed = DateTime.now().difference(_watchStart!).inSeconds;
    final duration = _controller?.value.duration.inSeconds ?? 1;
    final ratio = duration > 0 ? (elapsed / duration).clamp(0.0, 1.0) : 0.0;
    _watchStart = null;
    
    _tracker.trackWatch(
      userId: userId,
      videoId: widget.video.id,
      category: widget.video.category,
      watchRatio: ratio,
      liked: _liked,
      skipped: skipped && ratio < 0.2,
    );
  }

  void _togglePlay() {
    if (widget.video.type == 'image' || _controller == null) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _showPlayIcon = true;
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) setState(() => _showPlayIcon = false);
        });
      } else {
        _controller!.play();
        _showPlayIcon = false;
      }
    });
  }

  void _toggleMute() {
    if (widget.video.type == 'image') return;
    setState(() {
      _isMuted = !_isMuted;
      _controller?.setVolume(_isMuted ? 0 : 1);
    });
  }

  void _onDoubleTap() {
    HapticFeedback.mediumImpact();
    setState(() => _liked = true);
    widget.onLike?.call();
    setState(() => _showHeartAnimation = true);
    _likeAnimController.forward(from: 0).then((_) {
      if (mounted) setState(() => _showHeartAnimation = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: _togglePlay,
      onDoubleTap: _onDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Black background
          Container(color: Colors.black),

          // Player Widget Construction
          Builder(builder: (context) {
            Widget? playerWidget;
            if (widget.video.type == 'image') {
              playerWidget = Image.network(
                widget.video.videoUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, event) {
                  if (event == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                      strokeWidth: 2,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => 
                  const Center(child: Icon(Icons.error, color: Colors.white54)),
              );
            } else if (_isInitialized && _controller != null) {
              playerWidget = AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              );
            }

            if (playerWidget != null) {
              if (appFilters[widget.video.filterIndex].matrix != null) {
                playerWidget = ColorFiltered(
                  colorFilter: ColorFilter.matrix(appFilters[widget.video.filterIndex].matrix!),
                  child: playerWidget,
                );
              }
              return Center(child: playerWidget);
            }

            return Container(
              color: theme.colorScheme.surface,
              child: Center(
                child: CircularProgressIndicator(
                    color: theme.colorScheme.primary, strokeWidth: 2),
              ),
            );
          }),

          // Gradient overlay (bottom)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Play/Pause icon overlay
          if (_showPlayIcon)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pause_rounded,
                    color: Colors.white, size: 52),
              ),
            ),

          // Custom Heart Animation (double-tap like)
          if (_showHeartAnimation)
            Center(
              child: AnimatedBuilder(
                animation: _likeAnimController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _heartOpacity.value,
                    child: Transform.scale(
                      scale: _heartScale.value,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                        size: 160,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Right side action buttons
          Positioned(
            right: 12,
            bottom: 20,
            child: ActionButtons(
              video: widget.video,
              onLike: widget.onLike,
              onComment: widget.onComment,
              onShare: () {
                Share.share('Check out this video on Reelify! ${widget.video.videoUrl}');
              },
              onProfile: widget.onProfile,
            ),
          ),

          // Bottom info overlay
          Positioned(
            left: 12,
            right: 80,
            bottom: 10,
            child: VideoInfoOverlay(
              video: widget.video,
              onProfile: widget.onProfile,
            ),
          ),

          // Mute button
          if (widget.video.type != 'image')
            Positioned(
              top: 100,
              right: 12,
              child: GestureDetector(
                onTap: _toggleMute,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),

          // Video progress bar
          if (widget.video.type != 'image' && _isInitialized && _controller != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                colors: VideoProgressColors(
                  playedColor: theme.colorScheme.primary,
                  bufferedColor: Colors.white30,
                  backgroundColor: Colors.white10,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
