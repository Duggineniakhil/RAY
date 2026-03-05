import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:reelify/core/constants/app_constants.dart';
import 'package:reelify/features/auth/presentation/providers/auth_provider.dart';
import 'package:reelify/features/upload_video/presentation/screens/camera_screen.dart';

class PostDetailsScreen extends ConsumerStatefulWidget {
  final String type;
  final String path;
  final int filterIndex;
  final CaptureMode mode;

  const PostDetailsScreen({
    super.key,
    required this.type,
    required this.path,
    required this.filterIndex,
    this.mode = CaptureMode.photo,
  });

  @override
  ConsumerState<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends ConsumerState<PostDetailsScreen> {
  final _captionController = TextEditingController();
  final _locationController = TextEditingController();
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  List<String> _extractHashtags(String text) {
    final regex = RegExp(r'#(\w+)');
    return regex.allMatches(text).map((m) => m.group(1)!).toList();
  }

  Future<void> _sharePost() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    final messenger = ScaffoldMessenger.of(context);
    try {
      final videoId = _uuid.v4();
      const cloudName = 'dejnbfenr'; 
      const uploadPreset = 'videos'; // Assuming this works for all or replace if needed
      
      final resourceType = widget.type == 'image' ? 'image' : 'video';
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload');
      
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..fields['public_id'] = 'reelify/${user.id}/$videoId'
        ..files.add(await http.MultipartFile.fromPath('file', widget.path));

      final httpClient = http.Client();
      final streamedResponse = await httpClient.send(request);
      
      setState(() {
         _uploadProgress = 0.5;
      });

      final response = await http.Response.fromStream(streamedResponse);
      httpClient.close();

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Cloudinary upload failed: ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body);
      final mediaUrl = jsonResponse['secure_url'];

      setState(() {
         _uploadProgress = 1.0;
      });

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection(AppConstants.videosCollection)
          .doc(videoId)
          .set({
        'videoUrl': mediaUrl,
        'thumbnail': widget.type == 'image' ? mediaUrl : '', 
        'creatorId': user.id,
        'creatorName': user.username,
        'creatorAvatar': user.profileImage,
        'mode': widget.mode == CaptureMode.boomerang ? 'boomerang' : 'normal',
        'category': 'General', 
        'caption': _captionController.text.trim(),
        'hashtags': _extractHashtags(_captionController.text),
        'likes': 0,
        'commentsCount': 0,
        'views': 0,
        'shares': 0,
        'uploadTime': FieldValue.serverTimestamp(),
        'duration': jsonResponse['duration'] ?? 0,
        'type': widget.type,
      });

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('${widget.type == 'image' ? 'Post' : 'Short'} uploaded successfully!')),
        );
        // Navigate all the way back to home
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('New Post', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Minimal preview
                Container(
                  width: 80,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                    image: widget.type == 'image' 
                        ? DecorationImage(
                            image: FileImage(File(widget.path)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: widget.type == 'video' 
                      ? const Center(child: Icon(Icons.videocam, color: Colors.white54))
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _captionController,
                    maxLines: 5,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Write a caption...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 32),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on_outlined, color: Colors.white),
              title: TextField(
                controller: _locationController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Add location',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
              ),
            ),
            const Divider(color: Colors.white24, height: 32),
            if (_isUploading) ...[
              const SizedBox(height: 20),
              LinearProgressIndicator(value: _uploadProgress, color: Colors.blueAccent),
              const SizedBox(height: 8),
              const Text('Uploading...', style: TextStyle(color: Colors.white54)),
            ],
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _sharePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Share', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
