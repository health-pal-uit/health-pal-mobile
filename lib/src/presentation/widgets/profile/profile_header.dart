import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileHeader extends StatelessWidget {
  final User? user;
  final Function(String imagePath)? onAvatarChanged;

  const ProfileHeader({super.key, this.user, this.onAvatarChanged});

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    }

    final result = await permission.request();
    return result.isGranted;
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    // Show bottom sheet to choose between camera or gallery
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    // Request appropriate permission
    bool hasPermission = false;
    if (source == ImageSource.camera) {
      hasPermission = await _requestPermission(Permission.camera);
      if (!hasPermission && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to take photos'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      // For gallery, request photos permission
      hasPermission = await _requestPermission(Permission.photos);
      if (!hasPermission) {
        // Try storage permission for older Android versions
        hasPermission = await _requestPermission(Permission.storage);
      }
      if (!hasPermission && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission is required to access photos'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && onAvatarChanged != null) {
        onAvatarChanged!(image.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundImage:
                  user?.avatarUrl != null
                      ? NetworkImage(user!.avatarUrl!)
                      : const NetworkImage('https://placehold.co/84x84'),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _pickImage(context),
                child: CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.black.withValues(alpha: 0.8),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => context.push('/personal-profile'),
                child: Text(
                  user?.fullName ?? user?.username ?? 'User',
                  style: AppTypography.body,
                ),
              ),
              const SizedBox(height: 5),
              Text(user?.email ?? 'No email', style: AppTypography.caption),
              const SizedBox(height: 5),
              GestureDetector(
                onTap: () => context.push('/personal-profile'),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
