import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MealScanScreen extends StatefulWidget {
  const MealScanScreen({super.key});

  @override
  State<MealScanScreen> createState() => _MealScanScreenState();
}

class _MealScanScreenState extends State<MealScanScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  File? _capturedImage;
  bool _isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing camera: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile image = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = File(image.path);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking picture: $e')),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e')),
        );
      }
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
    });
  }

  Future<void> _analyzeMeal() async {
    if (_capturedImage == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    // Simulate API call for meal analysis
    // TODO: Replace with actual API call to analyze meal
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
      });

      // Navigate to results screen or show results dialog
      // TODO: Navigate to meal analysis results screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal analysis complete! (Feature coming soon)'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera or Image Preview
            _capturedImage != null
                ? _buildImagePreview()
                : _buildCameraView(),

            // Top Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(),
            ),

            // Bottom Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _cameraController!.value.previewSize!.height,
          height: _cameraController!.value.previewSize!.width,
          child: CameraPreview(_cameraController!),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return SizedBox.expand(
      child: Image.file(
        _capturedImage!,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => context.pop(),
          ),
          const Spacer(),
          Text(
            'Meal Scan',
            style: AppTypography.headline.copyWith(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: _capturedImage != null
          ? _buildPreviewControls()
          : _buildCameraControls(),
    );
  }

  Widget _buildCameraControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Gallery Button
        IconButton(
          onPressed: _pickImageFromGallery,
          icon: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.photo_library,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),

        // Capture Button
        GestureDetector(
          onTap: _takePicture,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        // Placeholder for symmetry
        const SizedBox(width: 50),
      ],
    );
  }

  Widget _buildPreviewControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Analyze Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isAnalyzing ? null : _analyzeMeal,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isAnalyzing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.analytics_outlined, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Analyze Meal',
                        style: AppTypography.headline.copyWith(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // Action Buttons Row
        Row(
          children: [
            // Retake Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _retakePhoto,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  'Retake',
                  style: AppTypography.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Gallery Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library, color: Colors.white),
                label: Text(
                  'Gallery',
                  style: AppTypography.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
