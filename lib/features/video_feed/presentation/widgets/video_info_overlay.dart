import 'package:flutter/material.dart';
import 'package:reelify/features/video_feed/domain/models/video_model.dart';

class VideoInfoOverlay extends StatelessWidget {
  final VideoModel video;

  const VideoInfoOverlay({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Creator name
        Row(
          children: [
            Text(
              '@${video.creatorName.isNotEmpty ? video.creatorName : 'creator'}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
              ),
            ),
            if (video.category.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white30),
                ),
                child: Text(
                  video.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 6),

        // Caption
        if (video.caption.isNotEmpty)
          Text(
            video.caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
            ),
          ),

        const SizedBox(height: 6),

        // Hashtags
        if (video.hashtags.isNotEmpty)
          Text(
            video.hashtags.map((h) => '#$h').join(' '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF80DFFF),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
            ),
          ),

        const SizedBox(height: 8),

        // Music note (decorative)
        Row(
          children: [
            const Icon(Icons.music_note_rounded,
                color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              'Original Sound',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                shadows: [Shadow(blurRadius: 4, color: Colors.black87)],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
