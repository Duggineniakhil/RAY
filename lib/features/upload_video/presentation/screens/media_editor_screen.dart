import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:reelify/core/utils/camera_filters.dart';
import 'dart:io';
import 'package:reelify/features/upload_video/presentation/screens/camera_screen.dart';

class MediaEditorScreen extends StatefulWidget {
  final String type;
  final String path;
  final int initialFilterIndex;
  final CaptureMode mode;

  const MediaEditorScreen({
    super.key,
    required this.type,
    required this.path,
    this.initialFilterIndex = 0,
    this.mode = CaptureMode.photo,
  });

  @override
  State<MediaEditorScreen> createState() => _MediaEditorScreenState();
}

class _MediaEditorScreenState extends State<MediaEditorScreen> {
  late int _filterIndex;
  late String _currentPath;

  // Video properties
  final Trimmer _trimmer = Trimmer();
  bool _isVideoLoaded = false;
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _filterIndex = widget.initialFilterIndex;
    _currentPath = widget.path;
    if (widget.type == 'video') {
      _loadVideo();
    }
    // Boomerang-specific logic can be initialized here if needed
    if (widget.mode == CaptureMode.boomerang) {
      debugPrint('Boomerang mode active in Editor');
    }
  }

  Future<void> _loadVideo() async {
    await _trimmer.loadVideo(videoFile: File(_currentPath));
    if (mounted) setState(() => _isVideoLoaded = true);
  }

  @override
  void dispose() {
    _trimmer.dispose();
    super.dispose();
  }

  Future<void> _cropImage() async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _currentPath,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Crop Image',
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _currentPath = croppedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text('Edit', style: TextStyle(color: Colors.white)),
        actions: [
          if (widget.type == 'image')
            IconButton(
              icon: const Icon(Icons.crop, color: Colors.white),
              onPressed: _cropImage,
            ),
          TextButton(
            onPressed: _isExporting
                ? null
                : () async {
                    if (widget.type == 'video') {
                      // If the user didn't touch the trim handles, skip unnecessary trimming 
                      // which would otherwise output a 0-second empty file.
                      if (_startValue == 0.0 && _endValue == 0.0) {
                        context.push('/home/post_details', extra: {
                          'type': widget.type,
                          'path': _currentPath,
                          'filterIndex': _filterIndex,
                          'mode': widget.mode,
                        });
                        return;
                      }

                      setState(() => _isExporting = true);
                      await _trimmer.saveTrimmedVideo(
                        startValue: _startValue,
                        endValue: _endValue,
                        onSave: (String? outputPath) {
                          if (mounted) setState(() => _isExporting = false);
                          if (outputPath != null && mounted) {
                            context.push('/home/post_details', extra: {
                              'type': widget.type,
                              'path': outputPath,
                              'filterIndex': _filterIndex,
                              'mode': widget.mode,
                            });
                          }
                        },
                      );
                    } else {
                      context.push('/home/post_details', extra: {
                        'type': widget.type,
                        'path': _currentPath,
                        'filterIndex': _filterIndex,
                        'mode': widget.mode,
                      });
                    }
                  },
            child: _isExporting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Next', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: widget.type == 'image'
                  ? _buildImagePreview()
                  : _buildVideoPlaceholder(),
            ),
          ),
          _buildFilterScroll(),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    final originalImage = Image.file(File(_currentPath), fit: BoxFit.contain);
    if (appFilters[_filterIndex].matrix != null) {
      return ColorFiltered(
        colorFilter: ColorFilter.matrix(appFilters[_filterIndex].matrix!),
        child: originalImage,
      );
    }
    return originalImage;
  }

  Widget _buildVideoPlaceholder() {
    if (!_isVideoLoaded) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    
    // Apply visual filter if possible, otherwise just trimmer viewer.
    // VideoViewer doesn't natively support ColorFiltered overlay if it blocks touches, 
    // but we can wrap it if we ignore pointers conditionally.
    Widget viewer = VideoViewer(trimmer: _trimmer);
    
    if (appFilters[_filterIndex].matrix != null) {
      viewer = ColorFiltered(
        colorFilter: ColorFilter.matrix(appFilters[_filterIndex].matrix!),
        child: viewer,
      );
    }

    return Column(
      children: [
        Expanded(
          child: viewer,
        ),
        const SizedBox(height: 12),
        TrimViewer(
          trimmer: _trimmer,
          viewerHeight: 50,
          viewerWidth: MediaQuery.of(context).size.width - 40,
          maxVideoLength: const Duration(seconds: 60),
          onChangeStart: (value) => _startValue = value,
          onChangeEnd: (value) => _endValue = value,
          onChangePlaybackState: (value) {
            if (mounted) setState(() => _isPlaying = value);
          },
        ),
        TextButton.icon(
          icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
          label: Text(_isPlaying ? "Pause" : "Play", style: const TextStyle(color: Colors.white)),
          onPressed: () async {
            final playbackState = await _trimmer.videoPlaybackControl(
              startValue: _startValue,
              endValue: _endValue,
            );
            if (mounted) setState(() => _isPlaying = playbackState);
          },
        ),
      ],
    );
  }

  Widget _buildFilterScroll() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: appFilters.length,
        itemBuilder: (context, index) {
          final filter = appFilters[index];
          final isSelected = _filterIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _filterIndex = index),
            child: Container(
              width: 70,
              margin: const EdgeInsets.only(left: 16),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white24,
                        width: isSelected ? 3 : 2,
                      ),
                      color: Colors.grey[800],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: filter.matrix != null
                        ? ColorFiltered(
                            colorFilter: ColorFilter.matrix(filter.matrix!),
                            child: Image.asset('assets/images/default_avatar.png', fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.color_lens, color: Colors.white54)),
                          )
                        : const Icon(Icons.not_interested, color: Colors.white54, size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    filter.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
