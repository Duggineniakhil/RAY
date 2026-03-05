import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reelify/core/constants/app_constants.dart';
import 'package:reelify/generated/app_localizations.dart';
import 'package:reelify/features/auth/presentation/providers/auth_provider.dart';
import 'package:reelify/widgets/gradient_button.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  final _captionController = TextEditingController();
  File? _videoFile;
  String _selectedCategory = AppConstants.videoCategories.first;
  double _uploadProgress = 0;
  bool _isUploading = false;
  final _uuid = const Uuid();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _videoFile = File(result.files.single.path!));
    }
  }

  Future<void> _uploadVideo() async {
    if (_videoFile == null) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      final videoId = _uuid.v4();
      
      // Cloudinary Setup
      const cloudName = 'dejnbfenr'; 
      const uploadPreset = 'videos'; 
      
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/video/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..fields['public_id'] = 'reelify/${user.id}/$videoId'
        ..files.add(await http.MultipartFile.fromPath('file', _videoFile!.path));

      // Stream the upload progress
      final httpClient = http.Client();
      final streamedResponse = await httpClient.send(request);
      
      // We don't have exact progress tracking with basic http streamedResponse easily without an interceptor,
      // so we simulate progress for UX, or just show an indeterminate indicator in the UI.
      setState(() {
         _uploadProgress = 0.5; // Simulate progress
      });

      final response = await http.Response.fromStream(streamedResponse);
      httpClient.close();

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Cloudinary upload failed: ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body);
      final videoUrl = jsonResponse['secure_url'];

      setState(() {
         _uploadProgress = 1.0;
      });

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection(AppConstants.videosCollection)
          .doc(videoId)
          .set({
        'videoUrl': videoUrl,
        'thumbnail': '',
        'creatorId': user.id,
        'creatorName': user.username,
        'creatorAvatar': user.profileImage,
        'category': _selectedCategory,
        'caption': _captionController.text.trim(),
        'hashtags': _extractHashtags(_captionController.text),
        'likes': 0,
        'commentsCount': 0,
        'views': 0,
        'shares': 0,
        'uploadTime': FieldValue.serverTimestamp(),
        'duration': jsonResponse['duration'] ?? 0,
        'type': 'video',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Video uploaded successfully! 🎬')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  List<String> _extractHashtags(String text) {
    final regex = RegExp(r'#(\w+)');
    return regex.allMatches(text).map((m) => m.group(1)!).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.uploadVideo),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video picker
            GestureDetector(
              onTap: _isUploading ? null : _pickVideo,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _videoFile != null
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                    width: 2,
                  ),
                ),
                child: _videoFile != null
                    ? Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Center(
                              child: Icon(Icons.videocam_rounded,
                                  color: theme.colorScheme.primary, size: 64),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            child: Text(
                              _videoFile!.path.split('/').last,
                              style: TextStyle(
                                  color: theme.hintColor,
                                  fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary.withValues(alpha: 0.15),
                            ),
                            child: Icon(Icons.cloud_upload_outlined,
                                color: theme.colorScheme.primary, size: 40),
                          ),
                          const SizedBox(height: 12),
                          Text(l10n.selectVideo,
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600)),
                          Text('MP4, MOV up to 100MB',
                              style: TextStyle(
                                  color: theme.hintColor, fontSize: 12)),
                        ],
                      ),
              ),
            ).animate().fadeIn().scale(),

            const SizedBox(height: 20),

            // Category
            Text(l10n.selectCategory,
                style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                dropdownColor: theme.colorScheme.surface,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: InputBorder.none,
                ),
                items: AppConstants.videoCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedCategory = v ?? _selectedCategory),
              ),
            ),

            const SizedBox(height: 16),

            // Caption
            Text(l10n.caption,
                style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _captionController,
              maxLines: 3,
              maxLength: 150,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: const InputDecoration(
                hintText:
                    'Write a caption... #hashtags encouraged!',
              ),
            ),

            const SizedBox(height: 24),

            if (_isUploading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: theme.dividerColor,
                  color: theme.colorScheme.primary,
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${l10n.uploading} ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                style: TextStyle(color: theme.hintColor),
              ),
              const SizedBox(height: 16),
            ],

            GradientButton(
              label: l10n.uploadVideo,
              onPressed: (_isUploading || _videoFile == null)
                  ? null
                  : _uploadVideo,
              isLoading: _isUploading,
              icon: Icons.upload_rounded,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
