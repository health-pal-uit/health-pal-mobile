import 'package:da1/src/config/api_config.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/data/datasources/post_remote_data_source.dart';
import 'package:da1/src/data/models/user_model.dart';
import 'package:da1/src/presentation/widgets/community/attachment_selection_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CreatePostBottomSheet extends StatefulWidget {
  final UserModel? currentUser;
  final VoidCallback? onPostCreated;

  const CreatePostBottomSheet({
    super.key,
    this.currentUser,
    this.onPostCreated,
  });

  @override
  State<CreatePostBottomSheet> createState() => _CreatePostBottomSheetState();

  static void show(
    BuildContext context,
    UserModel? currentUser, {
    VoidCallback? onPostCreated,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => CreatePostBottomSheet(
            currentUser: currentUser,
            onPostCreated: onPostCreated,
          ),
    );
  }
}

class _CreatePostBottomSheetState extends State<CreatePostBottomSheet> {
  final _contentController = TextEditingController();
  String? _selectedAttachType;
  String? _selectedAttachId;
  String? _selectedAttachName;
  bool _isCreating = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder:
          (context, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUserInfo(),
                        const SizedBox(height: 16),
                        _buildContentInput(),
                        const SizedBox(height: 16),
                        _buildAttachTypeSelector(),
                        const SizedBox(height: 24),
                        _buildPostButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const Text(
            'Create Post',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    final avatarUrl = widget.currentUser?.avatarUrl;
    final displayName =
        widget.currentUser?.fullName ?? widget.currentUser?.username ?? 'User';

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage:
              avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
          backgroundColor: Colors.grey,
          child:
              avatarUrl == null || avatarUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 28)
                  : null,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'Share your fitness journey',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContentInput() {
    return TextField(
      controller: _contentController,
      maxLines: 8,
      decoration: InputDecoration(
        hintText: 'What\'s on your mind?',
        hintStyle: TextStyle(color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildAttachTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attach Content (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildTypeChip('meal', 'Meal', Icons.restaurant),
            _buildTypeChip('challenge', 'Challenge', Icons.emoji_events),
            _buildTypeChip('medal', 'Medal', Icons.military_tech),
            _buildTypeChip('ingredient', 'Ingredient', Icons.set_meal),
          ],
        ),
        if (_selectedAttachName != null) ...[
          const SizedBox(height: 12),
          _buildSelectedAttachment(),
        ],
      ],
    );
  }

  Widget _buildSelectedAttachment() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getIconForType(_selectedAttachType),
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected ${_selectedAttachType?.replaceAll('_', ' ').toUpperCase()}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedAttachName!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              setState(() {
                _selectedAttachId = null;
                _selectedAttachName = null;
                _selectedAttachType = null;
              });
            },
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String? type) {
    switch (type) {
      case 'meal':
        return Icons.restaurant;
      case 'challenge':
        return Icons.emoji_events;
      case 'medal':
        return Icons.military_tech;
      case 'ingredient':
        return Icons.set_meal;
      default:
        return Icons.attach_file;
    }
  }

  Widget _buildTypeChip(String value, String label, IconData icon) {
    final isSelected = _selectedAttachType == value;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) async {
        if (selected) {
          // Navigate to selection screen
          final result = await Navigator.push<Map<String, dynamic>>(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AttachmentSelectionScreen(attachmentType: value),
            ),
          );

          if (result != null && mounted) {
            setState(() {
              _selectedAttachType = value;
              _selectedAttachId = result['id'];
              _selectedAttachName = result['name'];
            });
          }
        } else {
          setState(() {
            _selectedAttachType = null;
            _selectedAttachId = null;
            _selectedAttachName = null;
          });
        }
      },
      selectedColor: AppColors.primary,
      backgroundColor: const Color(0x19FA9500),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.primary,
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(
        color:
            isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.3),
        width: 1,
      ),
    );
  }

  Widget _buildPostButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isCreating ? null : _createPost,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child:
            _isCreating
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Text(
                  'Post',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
      ),
    );
  }

  Future<void> _createPost() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some content'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final token = await const FlutterSecureStorage().read(key: 'auth_token');
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final dataSource = PostRemoteDataSourceImpl(dio: dio);
      await dataSource.createPost(
        content: content,
        attachType: _selectedAttachType,
        attachId: _selectedAttachId,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onPostCreated?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
