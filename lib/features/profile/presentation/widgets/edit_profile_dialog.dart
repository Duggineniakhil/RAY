import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reelify/generated/app_localizations.dart';
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      title: Text(l10n.editProfile, style: TextStyle(color: theme.colorScheme.onSurface)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context, false),
          child: Text(l10n.cancel, style: TextStyle(color: theme.hintColor)),
        ),
        TextButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary))
              : Text(l10n.save, style: TextStyle(color: theme.colorScheme.primary)),
        ),
      ],
    );
  }
}
