import 'package:da1/src/config/routes.dart';
import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _kcalController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fiberController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isCreating = false;
  final List<String> _selectedTags = [];
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  final List<String> _availableTags = [
    'vegetarian',
    'vegan',
    'gluten-free',
    'dairy-free',
    'high-protein',
    'low-carb',
    'keto',
    'paleo',
    'meat',
    'seafood',
    'dessert',
    'snack',
    'breakfast',
    'lunch',
    'dinner',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _kcalController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    _fiberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error selecting image: $e')));
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_selectedImage != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Remove Photo'),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                      });
                    },
                  ),
              ],
            ),
          ),
    );
  }

  Future<void> _createRecipe() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isCreating = true);

    final repository = AppRoutes.getMealRepository();
    if (repository == null) {
      setState(() => _isCreating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Repository not initialized')),
        );
      }
      return;
    }

    final data = {
      'name': _nameController.text.trim(),
      'kcal_per_100gr': double.parse(_kcalController.text),
      'protein_per_100gr': double.parse(_proteinController.text),
      'fat_per_100gr': double.parse(_fatController.text),
      'carbs_per_100gr': double.parse(_carbsController.text),
      'fiber_per_100gr': double.parse(_fiberController.text),
      'notes': _notesController.text.trim(),
      'tags': _selectedTags,
      'type': 'meal',
      'opt': 'new',
    };

    final result = await repository.createMealContribution(
      data,
      _selectedImage?.path,
    );

    if (mounted) {
      setState(() => _isCreating = false);

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create recipe: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (recipe) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Recipe "${_nameController.text}" created successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate success
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Create Recipe',
          style: AppTypography.headline.copyWith(fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Text(
                'Recipe Image (Optional)',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child:
                      _selectedImage != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(_selectedImage!, fit: BoxFit.cover),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: _showImageSourceDialog,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to add a photo',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                ),
              ),

              const SizedBox(height: 24),

              // Recipe Name
              Text(
                'Recipe Name',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g., Grilled Chicken Salad',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a recipe name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Nutritional Information
              Text(
                'Nutritional Information (per 100g)',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),

              // Calories
              _buildNutrientField(
                controller: _kcalController,
                label: 'Calories (kcal)',
                hint: 'e.g., 120',
                icon: Icons.local_fire_department,
                color: Colors.orange,
              ),

              const SizedBox(height: 12),

              // Protein
              _buildNutrientField(
                controller: _proteinController,
                label: 'Protein (g)',
                hint: 'e.g., 10',
                icon: Icons.fitness_center,
                color: Colors.red,
              ),

              const SizedBox(height: 12),

              // Fat
              _buildNutrientField(
                controller: _fatController,
                label: 'Fat (g)',
                hint: 'e.g., 5',
                icon: Icons.water_drop,
                color: Colors.yellow[700]!,
              ),

              const SizedBox(height: 12),

              // Carbs
              _buildNutrientField(
                controller: _carbsController,
                label: 'Carbs (g)',
                hint: 'e.g., 8',
                icon: Icons.grain,
                color: Colors.brown,
              ),

              const SizedBox(height: 12),

              // Fiber
              _buildNutrientField(
                controller: _fiberController,
                label: 'Fiber (g)',
                hint: 'e.g., 2',
                icon: Icons.eco,
                color: Colors.green,
              ),

              const SizedBox(height: 24),

              // Tags
              Text(
                'Tags',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    _availableTags.map((tag) {
                      final isSelected = _selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTags.add(tag);
                            } else {
                              _selectedTags.remove(tag);
                            }
                          });
                        },
                        selectedColor: AppColors.primary.withValues(alpha: 0.2),
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color:
                              isSelected ? AppColors.primary : Colors.grey[700],
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 24),

              // Notes
              Text(
                'Notes (Optional)',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add any additional notes about your recipe...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _createRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isCreating
                          ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Create Recipe',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Required';
              }
              if (double.tryParse(value) == null) {
                return 'Invalid number';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
