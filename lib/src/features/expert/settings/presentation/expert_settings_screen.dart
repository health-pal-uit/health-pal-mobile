import 'dart:io';

import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/core/bloc/auth/auth.dart';
import 'package:da1/src/features/expert/dashboard/presentation/widgets/expert_bottom_nav.dart';
import 'package:da1/src/features/expert/settings/data/expert_settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ExpertSettingsScreen extends StatefulWidget {
  const ExpertSettingsScreen({super.key});

  @override
  State<ExpertSettingsScreen> createState() => _ExpertSettingsScreenState();
}

class _ExpertSettingsScreenState extends State<ExpertSettingsScreen> {
  final ExpertSettingsRepository _repository = ExpertSettingsRepository();
  int _bottomNavIndex = 3;

  bool _isLoading = true;
  bool _isSaving = false;
  String _expertId = '';
  bool _isVerified = false;
  String _roleName = 'Loading...';
  String? _currentAvatarUrl;
  File? _newAvatarFile;

  // Controllers
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  double _consultationRate = 5.0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    try {
      final data = await _repository.getMyExpertProfile();
      if (data != null && mounted) {
        setState(() {
          _expertId = data['id'] ?? '';
          _isVerified = data['is_verified'] ?? false;

          // Lấy token_per_minute, ép kiểu an toàn
          final tokenVal = data['token_per_minute'] ?? 5;
          _consultationRate = double.tryParse(tokenVal.toString()) ?? 5.0;

          _roleName = data['expert_role']?['name'] ?? 'Expert';
          _bioController.text = data['bio'] ?? '';

          // Dùng toán tử ?? '' để tránh lỗi khi backend trả về null
          _fullnameController.text = data['user']?['fullname'] ?? '';
          _phoneController.text = data['user']?['phone'] ?? '';
          _currentAvatarUrl = data['user']?['avatar_url'];

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _newAvatarFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    if (_expertId.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      await _repository.updateSettings(
        expertId: _expertId,
        fullname: _fullnameController.text.trim(),
        phone: _phoneController.text.trim(),
        bio: _bioController.text.trim(),
        tokenPerMinute: _consultationRate.toInt(),
        avatarPath: _newAvatarFile?.path,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go('/welcome');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
                : SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          left: 24,
                          top: 48,
                          bottom: 16,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFA9500),
                        ),
                        child: const Text(
                          'Profile & Fee Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    _isVerified
                                        ? const Color(0xFFF0FDF4)
                                        : Colors.orange.shade50,
                                border: Border.all(
                                  color:
                                      _isVerified
                                          ? const Color(0xFFB9F8CF)
                                          : Colors.orange.shade200,
                                  width: 1.25,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isVerified
                                        ? Icons.check_circle
                                        : Icons.pending_actions,
                                    color:
                                        _isVerified
                                            ? const Color(0xFF00A63E)
                                            : Colors.orange,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _isVerified
                                              ? 'Professionally Verified ✓'
                                              : 'Verification Pending',
                                          style: TextStyle(
                                            color:
                                                _isVerified
                                                    ? const Color(0xFF0D542B)
                                                    : Colors.orange.shade800,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _isVerified
                                              ? 'Your credentials have been verified.'
                                              : 'Your profile is under review by admin.',
                                          style: TextStyle(
                                            color:
                                                _isVerified
                                                    ? const Color(0xFF008236)
                                                    : Colors.orange.shade700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Thông tin cá nhân
                            const Text(
                              'Personal & Professional Details',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            Center(
                              child: Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      shape: BoxShape.circle,
                                      image:
                                          _newAvatarFile != null
                                              ? DecorationImage(
                                                image: FileImage(
                                                  _newAvatarFile!,
                                                ),
                                                fit: BoxFit.cover,
                                              )
                                              : (_currentAvatarUrl != null &&
                                                      _currentAvatarUrl!
                                                          .isNotEmpty
                                                  ? DecorationImage(
                                                    image: NetworkImage(
                                                      _currentAvatarUrl!,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                  : null),
                                    ),
                                    child:
                                        (_newAvatarFile == null &&
                                                (_currentAvatarUrl == null ||
                                                    _currentAvatarUrl!.isEmpty))
                                            ? Icon(
                                              Icons.person,
                                              size: 50,
                                              color: Colors.grey.shade400,
                                            )
                                            : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            _buildReadonlyField('Expert Role', _roleName),
                            const SizedBox(height: 16),

                            _buildEditableField(
                              'Full Name',
                              _fullnameController,
                            ),
                            const SizedBox(height: 16),
                            _buildEditableField(
                              'Phone Number',
                              _phoneController,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            _buildEditableField(
                              'Professional Bio',
                              _bioController,
                              maxLines: 4,
                            ),
                            const SizedBox(height: 24),

                            // Setup Phí (Slider)
                            const Text(
                              'Consultation Fee Setup',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFFFF7ED), Colors.white],
                                ),
                                border: Border.all(
                                  color: const Color(0xFFFFEDD4),
                                  width: 1.25,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Consultation Rate (Tokens/Minute)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Slider(
                                          value: _consultationRate.clamp(
                                            1,
                                            50,
                                          ), // Tránh lỗi crash nếu data vượt rào
                                          min: 1,
                                          max:
                                              50, // Bạn có thể tăng giảm tùy limit hệ thống
                                          divisions: 49,
                                          activeColor: AppColors.primary,
                                          inactiveColor: const Color(
                                            0xFFECECF0,
                                          ),
                                          onChanged:
                                              (value) => setState(
                                                () => _consultationRate = value,
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          '${_consultationRate.toInt()} T/min',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Estimated earnings for a 30-min session: ${(_consultationRate * 30).toInt()} Tokens',
                                    style: const TextStyle(
                                      color: Color(0xFFFA9500),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Nút Lưu
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveSettings,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child:
                                    _isSaving
                                        ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : const Text(
                                          'Save Profile Changes',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        bottomNavigationBar: ExpertBottomNav(
          currentIndex: _bottomNavIndex,
          onTap: (index) {
            setState(() => _bottomNavIndex = index);
            _handleNavigation(context, index);
          },
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF364153),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadonlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF364153),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            value,
            style: const TextStyle(color: Color(0xFF717182), fontSize: 16),
          ),
        ),
      ],
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/expert/dashboard');
        break;
      case 1:
        context.go('/expert/schedule');
        break;
      case 2:
        context.go('/expert/wallet');
        break;
      case 3:
        break;
    }
  }
}
