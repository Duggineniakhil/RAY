import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:reelify/core/utils/camera_filters.dart';

enum CaptureMode {
  photo,
  short,
  boomerang,
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  bool _isInit = false;
  bool _isRecording = false;
  FlashMode _flashMode = FlashMode.off;
  CaptureMode _captureMode = CaptureMode.photo;
  int _selectedFilterIndex = 0;
  final List<Map<String, dynamic>> _textOverlays = [];

  // Recording progress
  Timer? _recordTimer;
  int _recordDuration = 0;
  final int _maxRecordDuration = 60; // 60 seconds limit

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      // Default to back camera (index 0); front camera is for selfies only
      _selectedCameraIndex = _cameras!.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
      if (_selectedCameraIndex == -1) _selectedCameraIndex = 0;
      await _setupCameraController();
    }
  }

  Future<void> _setupCameraController() async {
    if (_cameras == null || _cameras!.isEmpty) return;
    
    final oldController = _cameraController;
    _cameraController = CameraController(
      _cameras![_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController!.initialize();
      await _cameraController!.setFlashMode(_flashMode);
      if (mounted) {
        setState(() => _isInit = true);
      }
    } catch (e) {
      debugPrint('Error initializing camera $e');
    }
    
    if (oldController != null) {
      oldController.dispose();
    }
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    if (_cameraController == null) return;
    setState(() {
      if (_flashMode == FlashMode.off) {
        _flashMode = FlashMode.always;
      } else if (_flashMode == FlashMode.always) {
        _flashMode = FlashMode.auto;
      } else {
        _flashMode = FlashMode.off;
      }
    });
    _cameraController!.setFlashMode(_flashMode);
  }

  void _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    setState(() => _isInit = false);
    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    await _setupCameraController();
  }

  Future<void> _takePicture() async {
    if (!_isInit || _cameraController == null || _cameraController!.value.isTakingPicture) return;
    try {
      final file = await _cameraController!.takePicture();
      if (mounted) {
        context.push('/home/editor', extra: {
          'type': 'image', 
          'path': file.path, 
          'filterIndex': _selectedFilterIndex,
          'mode': _captureMode,
        });
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
    }
  }

  Future<void> _startRecording() async {
    if (!_isInit || _cameraController == null || _cameraController!.value.isRecordingVideo) return;
    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordDuration = 0;
      });
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordDuration++;
          final limit = _captureMode == CaptureMode.boomerang ? 2 : _maxRecordDuration;
          if (_recordDuration >= limit) {
            _stopRecording();
          }
        });
      });
    } catch (e) {
      debugPrint('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (!_isInit || _cameraController == null || !_cameraController!.value.isRecordingVideo) return;
    try {
      _recordTimer?.cancel();
      final file = await _cameraController!.stopVideoRecording();
      setState(() {
        _isRecording = false;
        _recordDuration = 0;
      });
      if (mounted) {
        context.push('/home/editor', extra: {
          'type': 'video', 
          'path': file.path,
          'filterIndex': _selectedFilterIndex,
          'mode': _captureMode,
        });
      }
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
  }

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickMedia();
    if (file != null && mounted) {
      final isVideo = file.path.toLowerCase().endsWith('.mp4') || file.path.toLowerCase().endsWith('.mov');
      final type = isVideo ? 'video' : 'image';
      context.push('/home/editor', extra: {
        'type': type, 
        'path': file.path,
        'filterIndex': 0,
        'mode': CaptureMode.photo, // Default for gallery picks
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.only(top: 60, bottom: 120),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(24),
                ),
                clipBehavior: Clip.hardEdge,
                child: _isInit && _cameraController != null
                    ? Transform.scale(
                        scale: _cameraController!.value.aspectRatio < 1 ? 1 / _cameraController!.value.aspectRatio : _cameraController!.value.aspectRatio,
                        child: Center(
                          child: appFilters[_selectedFilterIndex].matrix != null
                             ? ColorFiltered(
                                 colorFilter: ColorFilter.matrix(appFilters[_selectedFilterIndex].matrix!),
                                 child: CameraPreview(_cameraController!),
                               )
                             : CameraPreview(_cameraController!),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
              ),
            ),
            
            // Top UI
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 32),
                    onPressed: () => context.pop(),
                  ),
                  if (_cameras != null && 
                      _cameras![_selectedCameraIndex].lensDirection == CameraLensDirection.back)
                    IconButton(
                      icon: Icon(
                        _flashMode == FlashMode.always 
                            ? Icons.flash_on 
                            : _flashMode == FlashMode.auto 
                                ? Icons.flash_auto 
                                : Icons.flash_off, 
                        color: Colors.white, size: 28),
                      onPressed: _toggleFlash,
                    ),
                ],
              ),
            ),

            // Left Sidebar Tools
            Positioned(
              left: 16,
              top: MediaQuery.of(context).size.height * 0.4,
              child: Column(
                children: [
                  _buildToolIcon(Icons.title, 'Text', onPressed: _addTextOverlay),
                  const SizedBox(height: 20),
                  _buildToolIcon(Icons.all_inclusive, 'Loop', onPressed: () {
                    setState(() => _captureMode = CaptureMode.boomerang);
                  }),
                  const SizedBox(height: 20),
                  _buildToolIcon(Icons.auto_awesome, 'Effects', onPressed: () {}),
                  const SizedBox(height: 20),
                  _buildToolIcon(Icons.keyboard_arrow_down, 'More', onPressed: () {}),
                ],
              ),
            ),

            // Text Overlays
            ..._textOverlays.map((overlay) => Positioned(
              left: overlay['position'].dx,
              top: overlay['position'].dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    overlay['position'] += details.delta;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    overlay['text'],
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )),

            // Filter row
            Positioned(
              bottom: 180,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: _isRecording,
                child: SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: appFilters.length,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemBuilder: (context, index) {
                      final filter = appFilters[index];
                      final isSelected = _selectedFilterIndex == index;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilterIndex = index;
                          });
                        },
                        child: Container(
                          width: 70,
                          margin: const EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.white24, 
                                    width: isSelected ? 3 : 2
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
                              const SizedBox(height: 6),
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
                ),
              ),
            ),

            // Capture Row: Gallery, Capture Button, Flip
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Gallery Button
                  GestureDetector(
                    onTap: _pickMedia,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white54, width: 1),
                      ),
                      child: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 24),
                    ),
                  ),

                  // Capture Button
                  GestureDetector(
                    onTap: () {
                      if (_captureMode == CaptureMode.photo) {
                        _takePicture();
                      } else {
                        if (_isRecording) {
                          _stopRecording();
                        } else {
                          _startRecording();
                        }
                      }
                    },
                    onLongPress: _startRecording,
                    onLongPressEnd: (_) => _stopRecording(),
                    onLongPressCancel: () => _stopRecording(),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Progress Ring
                        if (_isRecording)
                          SizedBox(
                            width: 86,
                            height: 86,
                            child: CircularProgressIndicator(
                              value: _recordDuration / _maxRecordDuration,
                              color: Colors.red,
                              strokeWidth: 4,
                            ),
                          ),
                        // Outer ring
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                        ),
                        // Inner button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _isRecording ? 40 : 66,
                          height: _isRecording ? 40 : 66,
                          decoration: BoxDecoration(
                            color: _isRecording ? Colors.red : Colors.white,
                            borderRadius: BorderRadius.circular(_isRecording ? 8 : 40),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Flip Camera
                  IconButton(
                    icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 36),
                    onPressed: _switchCamera,
                  ),
                ],
              ),
            ),

            // Bottom Nav Modes
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildModeSelector('POST', CaptureMode.photo),
                      const SizedBox(width: 24),
                      _buildModeSelector('SHORT', CaptureMode.short),
                      const SizedBox(width: 24),
                      _buildModeSelector('BOOMERANG', CaptureMode.boomerang),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector(String label, CaptureMode mode) {
    final isSelected = _captureMode == mode;
    return GestureDetector(
      onTap: () {
        if (_isRecording) return;
        setState(() => _captureMode = mode);
      },
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white54,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildToolIcon(IconData icon, String tooltip, {VoidCallback? onPressed}) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: 30),
      onPressed: onPressed ?? () {},
      tooltip: tooltip,
      style: IconButton.styleFrom(
        shadowColor: Colors.black45,
        elevation: 4,
      ),
    );
  }

  void _addTextOverlay() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Text'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter text...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Add')),
        ],
      ),
    );

    if (text != null && text.isNotEmpty) {
      setState(() {
        _textOverlays.add({
          'text': text,
          'position': const Offset(100, 200),
          'style': 'basic',
        });
      });
    }
  }
}
