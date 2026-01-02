import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/data/repositories/google_fit_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class GoogleFitSyncScreen extends StatefulWidget {
  final GoogleFitRepository googleFitRepository;

  const GoogleFitSyncScreen({super.key, required this.googleFitRepository});

  @override
  State<GoogleFitSyncScreen> createState() => _GoogleFitSyncScreenState();
}

class _GoogleFitSyncScreenState extends State<GoogleFitSyncScreen> {
  bool _isConnected = false;
  bool _isSyncing = false;
  DateTime? _lastSyncTime;

  bool _syncSteps = true;
  bool _syncWorkouts = true;
  bool _syncWeight = true;
  bool _syncWater = false;
  bool _syncSleep = false;
  bool _autoSync = true;

  @override
  void initState() {
    super.initState();
    _checkConnectionStatus();
  }

  Future<void> _checkConnectionStatus() async {
    final result = await widget.googleFitRepository.getConnectionStatus();
    result.fold((failure) {}, (isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
          if (isConnected) {
            _lastSyncTime = DateTime.now();
          }
        });
      }
    });
  }

  Future<void> _connectToGoogleFit() async {
    setState(() => _isSyncing = true);

    try {
      // Get the OAuth URL from the backend
      final result = await widget.googleFitRepository.connectGoogleFit();

      result.fold(
        (failure) {
          // Handle error
          if (mounted) {
            setState(() => _isSyncing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to connect: ${failure.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        (authUrl) async {
          // Launch the OAuth URL in browser
          final uri = Uri.parse(authUrl);

          bool launched = false;

          // Try different launch modes
          try {
            // First try external application
            launched = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
          } catch (e) {
            try {
              // Try platform default
              launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
            } catch (e2) {
              try {
                // Try in-app web view as last resort
                launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
              } catch (e3) {
                // All launch modes failed, launched remains false
              }
            }
          }

          if (launched && mounted) {
            setState(() => _isSyncing = false);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Opening Google authentication. Please sign in and authorize the app. Return to check connection status.',
                ),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 4),
              ),
            );

            // Check status after a delay to allow user to complete OAuth
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) {
                _checkConnectionStatus();
              }
            });
          } else {
            if (mounted) {
              setState(() => _isSyncing = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Could not open Google authentication'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _disconnectFromGoogleFit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Disconnect Google Fit?'),
            content: const Text(
              'This will stop syncing your health data from Google Fit. You can reconnect anytime.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Disconnect'),
              ),
            ],
          ),
    );

    if (confirm == true && mounted) {
      setState(() => _isSyncing = true);

      try {
        final result = await widget.googleFitRepository.disconnectGoogleFit();

        result.fold(
          (failure) {
            if (mounted) {
              setState(() => _isSyncing = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to disconnect: ${failure.message}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          (success) {
            if (mounted && success) {
              setState(() {
                _isConnected = false;
                _lastSyncTime = null;
                _isSyncing = false;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Disconnected from Google Fit'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (mounted) {
              setState(() => _isSyncing = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to disconnect'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
        );
      } catch (e) {
        if (mounted) {
          setState(() => _isSyncing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _syncNow() async {
    if (!_isConnected) return;

    setState(() => _isSyncing = true);

    try {
      final result = await widget.googleFitRepository.syncGoogleFit();

      result.fold(
        (failure) {
          if (mounted) {
            setState(() => _isSyncing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to sync: ${failure.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        (success) {
          if (mounted) {
            setState(() {
              _isSyncing = false;
              _lastSyncTime = DateTime.now();
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data synced successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Google Fit Sync',
          style: AppTypography.headline.copyWith(fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConnectionCard(),
            const SizedBox(height: 20),
            if (_isConnected) ...[
              _buildSyncSettingsCard(),
              const SizedBox(height: 20),
              _buildDataTypesCard(),
              const SizedBox(height: 20),
              _buildInfoCard(),
            ] else
              _buildBenefitsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient:
                  _isConnected
                      ? const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 165, 235, 184),
                          Color.fromARGB(255, 145, 181, 239),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                      : null,
              color: _isConnected ? null : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/google_fit.svg',
                width: 40,
                height: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Google Fit',
            style: AppTypography.headline.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color:
                  _isConnected
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    _isConnected
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _isConnected ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isConnected ? 'Connected' : 'Not Connected',
                  style: AppTypography.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _isConnected ? Colors.green[700] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_lastSyncTime != null)
            Text(
              'Last synced: ${_formatSyncTime(_lastSyncTime!)}',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          const SizedBox(height: 20),
          if (_isConnected)
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSyncing ? null : _syncNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon:
                        _isSyncing
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                            : const Icon(Icons.sync, color: Colors.white),
                    label: Text(
                      _isSyncing ? 'Syncing...' : 'Sync Now',
                      style: AppTypography.headline.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _disconnectFromGoogleFit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Disconnect'),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSyncing ? null : _connectToGoogleFit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon:
                    _isSyncing
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(Icons.link, color: Colors.white),
                label: Text(
                  _isSyncing ? 'Connecting...' : 'Connect to Google Fit',
                  style: AppTypography.headline.copyWith(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSyncSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sync Settings',
            style: AppTypography.headline.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            value: _autoSync,
            onChanged: (value) => setState(() => _autoSync = value),
            title: const Text('Auto Sync'),
            subtitle: const Text('Sync automatically in the background'),
            activeTrackColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildDataTypesCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Types',
            style: AppTypography.headline.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose what data to sync from Google Fit',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          _buildDataTypeToggle(
            icon: LucideIcons.footprints,
            title: 'Steps',
            subtitle: 'Daily step count',
            value: _syncSteps,
            onChanged: (value) => setState(() => _syncSteps = value),
          ),
          const Divider(height: 32),
          _buildDataTypeToggle(
            icon: Icons.fitness_center,
            title: 'Workouts',
            subtitle: 'Exercise activities and calories burned',
            value: _syncWorkouts,
            onChanged: (value) => setState(() => _syncWorkouts = value),
          ),
          const Divider(height: 32),
          _buildDataTypeToggle(
            icon: LucideIcons.weight,
            title: 'Weight',
            subtitle: 'Body weight measurements',
            value: _syncWeight,
            onChanged: (value) => setState(() => _syncWeight = value),
          ),
          const Divider(height: 32),
          _buildDataTypeToggle(
            icon: LucideIcons.droplet,
            title: 'Water Intake',
            subtitle: 'Daily hydration tracking',
            value: _syncWater,
            onChanged: (value) => setState(() => _syncWater = value),
          ),
          const Divider(height: 32),
          _buildDataTypeToggle(
            icon: LucideIcons.moon,
            title: 'Sleep',
            subtitle: 'Sleep duration and quality',
            value: _syncSleep,
            onChanged: (value) => setState(() => _syncSleep = value),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTypeToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.headline.copyWith(fontSize: 16)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About Syncing',
                  style: AppTypography.headline.copyWith(
                    fontSize: 16,
                    color: Colors.blue[900],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your data is synced securely and stored encrypted. You can disconnect at any time to stop syncing.',
                  style: AppTypography.body.copyWith(
                    fontSize: 14,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Benefits of Syncing',
            style: AppTypography.headline.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildBenefitItem(
            icon: Icons.auto_awesome,
            title: 'Automatic Tracking',
            description:
                'Your health data updates automatically without manual entry',
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(
            icon: Icons.insights,
            title: 'Better Insights',
            description: 'Get more accurate health and fitness insights',
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(
            icon: Icons.sync,
            title: 'Stay in Sync',
            description: 'Keep all your fitness data up-to-date across devices',
          ),
          const SizedBox(height: 16),
          _buildBenefitItem(
            icon: Icons.security,
            title: 'Secure & Private',
            description: 'Your data is encrypted and only accessible by you',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.headline.copyWith(fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatSyncTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
