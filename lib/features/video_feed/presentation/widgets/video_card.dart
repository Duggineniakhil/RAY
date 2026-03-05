import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:reelify/core/theme/app_theme.dart';
import 'package:reelify/features/video_feed/domain/models/video_model.dart';
import 'package:reelify/features/video_feed/presentation/widgets/video_info_overlay.dart';
import 'package:reelify/features/video_feed/presentation/widgets/action_buttons.dart';

class VideoCard extends StatefulWidget {
  final VideoModel video;
  final bool isActive;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onProfile;

  const VideoCard({
    super.key,
    required this.video,
    required this.isActive,
    this.onLike,
    this.onComment,
    this.onProfile,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showPlayIcon = false;
  bool _isMuted = false;
  late AnimationController _likeAnimController;
  bool _showHeartAnimation = false;

  @override
  void initState() {
    super.initState();
    _likeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _initVideo();
  }

  @override
  void didUpdateWidget(VideoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller?.play();
      } else {
        _controller?.pause();
      }
    }
  }

  Future<void> _initVideo() async {
    if (widget.video.videoUrl.isEmpty) return;
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.video.videoUrl),
    );
    await _controller!.initialize();
    _controller!.setLooping(true);
    if (widget.isActive) _controller!.play();
    if (mounted) setState(() => _isInitialized = true);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _likeAnimController.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller == null) return;
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
    setState(() {
      _isMuted = !_isMuted;
      _controller?.setVolume(_isMuted ? 0 : 1);
    });
  }

  void _onDoubleTap() {
    HapticFeedback.mediumImpact();
    widget.onLike?.call();
    setState(() => _showHeartAnimation = true);
    _likeAnimController.forward(from: 0).then((_) {
      if (mounted) setState(() => _showHeartAnimation = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlay,
      onDoubleTap: _onDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Black background
          Container(color: Colors.black),

          // Video Player
          if (_isInitialized && _controller != null)
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            )
          else
            // Thumbnail / Loading placeholder
            Container(
              color: AppColors.surface,
              child: const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2),
              ),
            ),

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
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.75),
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
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pause_rounded,
                    color: Colors.white, size: 52),
              ),
            ),

          // Double-tap Heart Animation
          if (_showHeartAnimation)
            Center(
              child: AnimatedBuilder(
                animation: _likeAnimController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + _likeAnimController.value * 0.5,
                    child: Opacity(
                      opacity: 1 - _likeAnimController.value,
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.heart,
                        size: 120,
                      ),
                    ),
                  );
                },
              ),
            ),

          // Right side action buttons
          Positioned(
            right: 12,
            bottom: 100,
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
            bottom: 90,
            child: VideoInfoOverlay(video: widget.video),
          ),

          // Mute button
          Positioned(
            top: 100,
            right: 12,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
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
          if (_isInitialized && _controller != null)
            Positioned(
              bottom: 82,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _controller!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: AppColors.primary,
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
