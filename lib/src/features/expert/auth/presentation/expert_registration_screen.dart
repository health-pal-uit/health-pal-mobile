import 'dart:io';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ExpertRegistrationScreen extends StatefulWidget {
  const ExpertRegistrationScreen({super.key});

  @override
  State<ExpertRegistrationScreen> createState() =>
      _ExpertRegistrationScreenState();
}

class _ExpertRegistrationScreenState extends State<ExpertRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _licenseIdController = TextEditingController();
  final _bioController = TextEditingController();
  final _feeController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _selectedRoleId;
  File? _licensePhoto;
  final bool _isLoading = false;

  final List<Map<String, String>> _expertRoles = [
    {'id': 'role-uuid-1', 'name': 'Nutritionist'},
    {'id': 'role-uuid-2', 'name': 'Fitness Coach'},
    {'id': 'role-uuid-3', 'name': 'Therapist'},
  ];

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _licensePhoto = File(image.path);
      });
    }
  }

  @override
  void dispose() {
    _licenseIdController.dispose();
    _bioController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_licensePhoto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload your license/certificate photo.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // TODO: Put AuthBloc / ExpertBloc to call API POST /experts/me
      // print("Ready to submit to backend!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text('Expert Profile', style: AppTypography.headline),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Complete your professional profile to start helping users.",
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 30),

                //expert_role_id
                _buildLabel("Area of Expertise"),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRoleId,
                  decoration: _inputDecoration(hint: "Select your specialty"),
                  items:
                      _expertRoles.map((role) {
                        return DropdownMenuItem(
                          value: role['id'],
                          child: Text(role['name']!),
                        );
                      }).toList(),
                  onChanged: (val) => setState(() => _selectedRoleId = val),
                  validator:
                      (val) => val == null ? "Please select a specialty" : null,
                ),
                const SizedBox(height: 24),

                //license_id
                _buildLabel("Professional License ID"),
                TextFormField(
                  controller: _licenseIdController,
                  decoration: _inputDecoration(
                    hint: "Enter your license number",
                  ),
                  validator:
                      (val) => val!.isEmpty ? "License ID is required" : null,
                ),
                const SizedBox(height: 24),

                //bio
                _buildLabel("Professional Bio"),
                TextFormField(
                  controller: _bioController,
                  maxLines: 4,
                  decoration: _inputDecoration(
                    hint: "Tell users about your experience and methodology...",
                  ),
                  validator: (val) => val!.isEmpty ? "Bio is required" : null,
                ),
                const SizedBox(height: 24),

                //token_per_minute
                _buildLabel("Consultation Fee (Tokens/min)"),
                TextFormField(
                  controller: _feeController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(hint: "e.g., 50"),
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Fee is required";
                    if (int.tryParse(val) == null) {
                      return "Must be a valid number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                //license_photo
                _buildLabel("Upload License/Certificate"),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child:
                        _licensePhoto == null
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  LucideIcons.imagePlus,
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Tap to upload photo",
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ],
                            )
                            : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _licensePhoto!,
                                fit: BoxFit.cover,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: _isLoading ? null : _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            "Submit Application",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: AppColors.backgroundLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
