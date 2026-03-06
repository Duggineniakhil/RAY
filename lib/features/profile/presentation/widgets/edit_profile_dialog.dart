import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reelify/generated/app_localizations.dart';
import 'package:reelify/features/auth/domain/models/user_model.dart';
import 'package:reelify/features/auth/presentation/providers/auth_provider.dart';
import 'package:reelify/core/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' as io;

class EditProfileDialog extends ConsumerStatefulWidget {
  final UserModel user;

  const EditProfileDialog({super.key, required this.user});

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  bool _isLoading = false;
  XFile? _imageFile;
  final _picker = ImagePicker();
  final _storage = StorageService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _bioController = TextEditingController(text: widget.user.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final name = _nameController.text.trim();
      final bio = _bioController.text.trim();

      String? photoUrl;
      if (_imageFile != null) {
        final bytes = await _imageFile!.readAsBytes();
        final extension = _imageFile!.name.split('.').last;
        photoUrl = await _storage.uploadProfileImage(bytes, extension);
      }

      await ref.read(authRepositoryProvider).updateProfile(
            displayName: name.isNotEmpty ? name : null,
            bio: bio,
            photoUrl: photoUrl,
            username: name.isNotEmpty ? name.toLowerCase().replaceAll(' ', '_') : null,
          );

      ref.invalidate(authStateProvider);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    ImageProvider? profileImageProvider;
    if (_imageFile != null) {
      if (kIsWeb) {
        profileImageProvider = NetworkImage(_imageFile!.path);
      } else {
        profileImageProvider = FileImage(io.File(_imageFile!.path));
      }
    } else if (widget.user.profileImage.isNotEmpty) {
      profileImageProvider = NetworkImage(widget.user.profileImage);
    }

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: Text(l10n.editProfile, style: TextStyle(color: theme.colorScheme.onSurface)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    backgroundImage: profileImageProvider,
                    child: profileImageProvider == null
                        ? Icon(Icons.person, size: 40, color: theme.hintColor)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: l10n.displayName,
                labelStyle: TextStyle(color: theme.hintColor),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              style: TextStyle(color: theme.colorScheme.onSurface),
              maxLength: 100,
              decoration: InputDecoration(
                labelText: l10n.bio,
                labelStyle: TextStyle(color: theme.hintColor),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.dividerColor)),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: Text(l10n.cancel, style: TextStyle(color: theme.hintColor)),
        ),
        TextButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary))
              : Text(l10n.save, style: TextStyle(color: theme.colorScheme.primary)),
        ),
      ],
    );
  }
}
