import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/core/bloc/auth/auth.dart';
import 'package:da1/src/features/expert/dashboard/presentation/widgets/expert_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ExpertSettingsScreen extends StatefulWidget {
  const ExpertSettingsScreen({super.key});

  @override
  State<ExpertSettingsScreen> createState() => _ExpertSettingsScreenState();
}

class _ExpertSettingsScreenState extends State<ExpertSettingsScreen> {
  int _bottomNavIndex = 3; // Settings is at index 3
  double _consultationRate = 5.0;
  bool _offerFreeSessions = true;
  int _freeSessions = 2;
  final List<String> _uploadedDocs = [
    'Medical_Degree_2018.pdf',
    'Board_Certification.pdf',
  ];

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
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Orange Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(left: 24, top: 16, bottom: 16),
                decoration: const BoxDecoration(color: Color(0xFFFA9500)),
                child: const Text(
                  'Profile & Fee Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Verification Status
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        border: Border.all(
                          color: const Color(0xFFB9F8CF),
                          width: 1.25,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Color(0xFF00A63E),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Professionally Verified ✓',
                                style: TextStyle(
                                  color: Color(0xFF0D542B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Your credentials have been verified',
                                style: TextStyle(
                                  color: Color(0xFF008236),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Professional Details Section
                    const Text(
                      'Professional Details',
                      style: TextStyle(
                        color: Color(0xFF101828),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      'Medical Specialty',
                      'Cardiology',
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      'Years of Experience',
                      '12',
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    _buildInputField(
                      'Current Workplace',
                      'City General Hospital',
                      enabled: false,
                    ),
                    const SizedBox(height: 24),
                    // Consultation Fee Setup Section
                    const Text(
                      'Consultation Fee Setup',
                      style: TextStyle(
                        color: Color(0xFF101828),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [const Color(0xFFFFF7ED), Colors.white],
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
                              color: Color(0xFF364153),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: _consultationRate,
                                  min: 1,
                                  max: 10,
                                  divisions: 9,
                                  activeColor: const Color(0xFF030213),
                                  inactiveColor: const Color(0xFFECECF0),
                                  onChanged: (value) {
                                    setState(() => _consultationRate = value);
                                  },
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
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${_consultationRate.toInt()} T/min',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Patients will be charged 5 tokens per minute during video consultations.',
                            style: TextStyle(
                              color: Color(0xFF6A7282),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: const Color(0xFFFFEDD4),
                                  width: 1.25,
                                ),
                              ),
                            ),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text:
                                        'Estimated earnings for 30-min consultation: ',
                                    style: TextStyle(
                                      color: Color(0xFF364153),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '${(_consultationRate * 30).toInt()} Tokens',
                                    style: const TextStyle(
                                      color: Color(0xFFFA9500),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Free Sessions Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        border: Border.all(
                          color: const Color(0xFFDBEAFE),
                          width: 1.25,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Offer Free Initial Sessions',
                                      style: TextStyle(
                                        color: Color(0xFF101828),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Attract new patients with complimentary consultations',
                                      style: TextStyle(
                                        color: Color(0xFF4A5565),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Switch(
                                value: _offerFreeSessions,
                                activeThumbColor: const Color(0xFF030213),
                                onChanged: (value) {
                                  setState(() => _offerFreeSessions = value);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (_offerFreeSessions) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: const Color(0xFFBEDBFF),
                                    width: 1.25,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Number of Free Sessions',
                                    style: TextStyle(
                                      color: Color(0xFF364153),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF3F3F5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '$_freeSessions',
                                            style: const TextStyle(
                                              color: Color(0xFF0A0A0A),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            if (_freeSessions > 1) {
                                              setState(() => _freeSessions--);
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add, size: 20),
                                          onPressed: () {
                                            setState(() => _freeSessions++);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'New patients will receive $_freeSessions free consultation session(s)',
                                    style: const TextStyle(
                                      color: Color(0xFF4A5565),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Certificate Upload Section
                    const Text(
                      'Certificate Upload',
                      style: TextStyle(
                        color: Color(0xFF101828),
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        border: Border.all(
                          color: const Color(0xFFD1D5DC),
                          width: 1.25,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.cloud_upload_outlined,
                            size: 48,
                            color: Color(0xFFD1D5DC),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Upload Medical Certificates',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF364153),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Drag and drop files here or click to browse',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF6A7282),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0A0A0A),
                              side: BorderSide(
                                color: Colors.black.withValues(alpha: 0.10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Select Files',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Uploaded Documents
                    const Text(
                      'Uploaded Documents',
                      style: TextStyle(
                        color: Color(0xFF364153),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildUploadedDocuments(),
                    const SizedBox(height: 24),
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Profile changes saved successfully!',
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save Profile Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
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
            setState(() {
              _bottomNavIndex = index;
            });
            _handleNavigation(context, index);
          },
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String value, {bool enabled = true}) {
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
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F3F5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF717182),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildUploadedDocuments() {
    return _uploadedDocs.map((doc) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          border: Border.all(color: const Color(0xFFFFEDD4), width: 1.25),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'PDF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc,
                    style: const TextStyle(
                      color: Color(0xFF101828),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Uploaded successfully',
                    style: TextStyle(
                      color: Color(0xFF6A7282),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                setState(() => _uploadedDocs.remove(doc));
              },
            ),
          ],
        ),
      );
    }).toList();
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
        // Already on settings
        break;
    }
  }
}
