import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoControllerManager {
  static final VideoControllerManager _instance = VideoControllerManager._internal();
  factory VideoControllerManager() => _instance;
  VideoControllerManager._internal();

  final Map<int, VideoPlayerController> _controllers = {};

  Future<VideoPlayerController?> getOrCreateController(int index, String url) async {
    // If controller exists, return it
    if (_controllers.containsKey(index)) {
      return _controllers[index];
    }

    // Otherwise create new one
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await controller.initialize();
      controller.setLooping(true);
      _controllers[index] = controller;
      
      // Cleanup far away controllers (maintain a buffer of 3: current, prev, next)
      _cleanupControllers(index);
      
      return controller;
    } catch (e) {
      debugPrint('Error initializing video controller for index $index: $e');
      return null;
    }
  }

  void _cleanupControllers(int activeIndex) {
    final keysToRemove = <int>[];
    _controllers.forEach((index, controller) {
      if ((index - activeIndex).abs() > 1) {
        keysToRemove.add(index);
      }
    });

    for (final key in keysToRemove) {
      _controllers[key]?.dispose();
      _controllers.remove(key);
      debugPrint('Disposed video controller at index $key');
    }
  }

  void play(int index) {
    
    _controllers.forEach((idx, controller) {
      if (idx == index) {
        controller.play();
      } else {
        controller.pause();
      }
    });
  }

  void pause(int index) {
    _controllers[index]?.pause();
  }

  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    _controllers.clear();
  }
}
