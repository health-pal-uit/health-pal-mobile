import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/core/bloc/auth/auth.dart';
import 'package:da1/src/features/expert/dashboard/data/booking_model.dart';
import 'package:da1/src/features/expert/dashboard/data/booking_repository.dart';
import 'package:da1/src/features/expert/dashboard/data/wallet_repository.dart';
import 'package:da1/src/features/expert/dashboard/presentation/widgets/expert_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ExpertDashboardScreen extends StatefulWidget {
  const ExpertDashboardScreen({super.key});

  @override
  State<ExpertDashboardScreen> createState() => _ExpertDashboardScreenState();
}

class _ExpertDashboardScreenState extends State<ExpertDashboardScreen> {
  bool _isOnline = false;
  int _bottomNavIndex = 0;

  bool _isLoading = true;
  String? _processingBookingId;
  List<BookingModel> _pendingBookings = [];
  List<BookingModel> _upcomingBookings = [];
  String _walletBalance = "0";

  final BookingRepository _bookingRepository = BookingRepository();
  final WalletRepository _walletRepository = WalletRepository();

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _bookingRepository.getPendingBookings(),
        _walletRepository.getWalletBalance(),
      ]);

      setState(() {
        _pendingBookings = results[0] as List<BookingModel>;
        _walletBalance = results[1] as String;

        _upcomingBookings = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _handleAcceptBooking(String bookingId) async {
    setState(() => _processingBookingId = bookingId);
    try {
      await _bookingRepository.acceptBooking(bookingId);
      await _loadDashboardData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _processingBookingId = null);
    }
  }

  Future<void> _handleDeclineBooking(String bookingId) async {
    setState(() => _processingBookingId = bookingId);
    try {
      await _bookingRepository.declineBooking(bookingId);
      await _loadDashboardData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _processingBookingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) context.go('/welcome');
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: RefreshIndicator(
          onRefresh: _loadDashboardData,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverPadding(
                padding: const EdgeInsets.all(24.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildWalletCard(),
                    const SizedBox(height: 32),

                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      _buildPendingRequests(),
                      const SizedBox(height: 32),
                      _buildUpcomingAppointments(),
                    ],

                    const SizedBox(height: 32),
                    _buildPerformanceMetrics(),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: ExpertBottomNav(
          currentIndex: _bottomNavIndex,
          onTap: (index) {
            setState(() => _bottomNavIndex = index);
            switch (index) {
              case 1:
                context.go('/expert/schedule');
                break;
              case 2:
                context.go('/expert/wallet');
                break;
              case 3:
                context.go('/expert/settings');
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String displayName = 'Guest';
        if (state is Authenticated) {
          displayName = state.user.fullName ?? state.user.username ?? 'Expert';
        }

        return Container(
          padding: const EdgeInsets.only(
            top: 60,
            left: 24,
            right: 24,
            bottom: 32,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFA9500), Color(0xFFFF8C00)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $displayName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Welcome back to your dashboard',
                          style: TextStyle(
                            color: const Color(0xFFFFEDD4),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap:
                        () => context.read<AuthBloc>().add(SignOutRequested()),
                    child: const CircleAvatar(
                      backgroundColor: Colors.white24,
                      radius: 20,
                      child: Icon(Icons.logout, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consultation Status',
                          style: TextStyle(
                            color: const Color(0xFFFFEDD4),
                            fontSize: 14,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isOnline ? 'Online' : 'Offline',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _isOnline,
                      onChanged: (value) {
                        setState(() {
                          _isOnline = value;
                        });
                      },
                      activeThumbColor: Colors.greenAccent,
                      inactiveThumbColor: Colors.white70,
                      inactiveTrackColor: Colors.black26,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Token Wallet',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Text(
                'Today\'s Earnings',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: _walletBalance,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: ' Tokens',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                '+150 Tokens',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                context.go('/expert/wallet');
              },
              child: Text(
                'View Wallet Details',
                style: AppTypography.captionLink.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Metrics',
          style: AppTypography.headline.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200, width: 1.25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total Consults', '1,245'),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              _buildStatItem('Answer Rate', '98%'),
              Container(width: 1, height: 40, color: Colors.grey.shade300),
              _buildStatItem('Avg Rating', '4.8', isRating: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, {bool isRating = false}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isRating) ...[
              const SizedBox(width: 4),
              const Icon(Icons.star, color: AppColors.primary, size: 18),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildPendingRequests() {
    if (_pendingBookings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.notifications_active,
              color: Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Pending Requests (${_pendingBookings.length})',
              style: AppTypography.headline.copyWith(fontSize: 18),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _pendingBookings.length,
            separatorBuilder: (context, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final booking = _pendingBookings[index];
              final isProcessing = _processingBookingId == booking.id;
              final localTime = booking.scheduledAt.toLocal();
              final timeStr =
                  "${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}";
              final dateStr =
                  "${localTime.day.toString().padLeft(2, '0')}/${localTime.month.toString().padLeft(2, '0')}";
              final noteText =
                  (booking.clientNote == null ||
                          booking.clientNote!.trim().isEmpty)
                      ? 'No note provided.'
                      : booking.clientNote!;

              return Container(
                width: 280,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade200, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[200],
                          child: const Icon(Icons.person),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking.clientName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '$timeStr - $dateStr • ${booking.callType.toUpperCase()}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      noteText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                isProcessing
                                    ? null
                                    : () => _handleDeclineBooking(booking.id),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Decline'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                isProcessing
                                    ? null
                                    : () => _handleAcceptBooking(booking.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child:
                                isProcessing
                                    ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text(
                                      'Accept',
                                      style: TextStyle(color: Colors.white),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingAppointments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Appointments',
          style: AppTypography.headline.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        if (_upcomingBookings.isEmpty)
          const Text(
            "No upcoming appointments.",
            style: TextStyle(color: Colors.grey),
          )
        else
          ..._upcomingBookings
              .take(3)
              .map(
                (booking) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildAppointmentCard(booking),
                ),
              ),
      ],
    );
  }

  Widget _buildAppointmentCard(BookingModel booking) {
    final localTime = booking.scheduledAt.toLocal();
    final timeStr =
        "${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}";
    final dateStr =
        "${localTime.day.toString().padLeft(2, '0')}/${localTime.month.toString().padLeft(2, '0')}";
    final initials =
        booking.clientName.isNotEmpty
            ? booking.clientName.substring(0, 2).toUpperCase()
            : 'US';

    final timeDifference = localTime.difference(DateTime.now()).inMinutes;
    final canJoinCall = timeDifference <= 10 && timeDifference >= -60;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1.25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFFFEDD4),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.clientName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        booking.callType == 'video'
                            ? Icons.videocam
                            : Icons.call,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$timeStr • $dateStr',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            onPressed:
                canJoinCall
                    ? () {
                      // TODO: Điều hướng vào Room
                    }
                    : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  canJoinCall ? AppColors.primary : Colors.grey[300],
              foregroundColor: canJoinCall ? Colors.white : Colors.grey[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
            ),
            child: const Text(
              'Join Call',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
