import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reelify/core/theme/app_theme.dart';
import 'package:reelify/features/auth/domain/models/user_model.dart';
import 'package:reelify/features/auth/presentation/providers/auth_provider.dart';

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

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final name = _nameController.text.trim();
      final bio = _bioController.text.trim();

      await ref.read(authRepositoryProvider).updateProfile(
            displayName: name.isNotEmpty ? name : null,
            bio: bio,
            // Updating username optionally mapping it directly from displayName to keep it simple
            username: name.isNotEmpty ? name.toLowerCase().replaceAll(' ', '_') : null,
          );

      if (mounted) {
        Navigator.pop(context, true); // Return true indicating success
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
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text('Edit Profile', style: TextStyle(color: AppColors.textPrimary)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Display Name',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bioController,
            style: const TextStyle(color: AppColors.textPrimary),
            maxLength: 100,
            decoration: const InputDecoration(
              labelText: 'Bio',
              labelStyle: TextStyle(color: AppColors.textSecondary),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
              : const Text('Save', style: TextStyle(color: AppColors.primary)),
        ),
      ],
    );
  }
}
