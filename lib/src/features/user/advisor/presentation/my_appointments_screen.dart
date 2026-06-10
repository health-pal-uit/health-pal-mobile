import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/features/shared/auth/data/datasources/auth_local_data_source.dart';
import 'package:da1/src/features/shared/wallet/data/wallet_repository.dart';
import 'package:da1/src/features/user/advisor/data/booking_repository.dart';
import 'package:da1/src/features/user/advisor/domain/booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:da1/src/core/bloc/auth/auth.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final BookingRepository _repository = BookingRepository();
  final WalletRepository _walletRepository = WalletRepository();

  bool _isLoading = true;
  List<Booking> _upcomingBookings = [];
  List<Booking> _pastBookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final allBookings = await _repository.fetchMyBookings();
      final now = DateTime.now();

      if (!mounted) return;
      setState(() {
        _upcomingBookings =
            allBookings
                .where(
                  (b) =>
                      (b.status == 'pending' || b.status == 'confirmed') &&
                      b.scheduledAt.isAfter(now),
                )
                .toList();

        _upcomingBookings.sort(
          (a, b) => a.scheduledAt.compareTo(b.scheduledAt),
        );

        _pastBookings =
            allBookings
                .where(
                  (b) =>
                      b.status == 'cancelled' ||
                      b.status == 'completed' ||
                      b.scheduledAt.isBefore(now),
                )
                .toList();

        _pastBookings.sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint('Error: $e');
    }
  }

  Future<void> _cancelBooking(Booking booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Cancellation'),
            content: const Text('Do you want to cancel this appointment?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Yes, Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _repository.cancelBooking(
        bookingId: booking.id,
        status: booking.status,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment cancelled successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      _fetchBookings();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleJoinCallClick(Booking booking) async {
    final int requiredTokenPerMinute = 6;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          ),
    );

    try {
      final wallet = await _walletRepository.getWalletBalance();

      if (!mounted) return;
      Navigator.pop(context);

      final currentBalance = wallet?.balance ?? 0;

      if (currentBalance < requiredTokenPerMinute) {
        _showInsufficientFundsDialog(currentBalance, requiredTokenPerMinute);
      } else {
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated) {
          final localDataSource = AuthLocalDataSourceImpl(
            storage: const FlutterSecureStorage(),
          );
          final token = await localDataSource.getToken() ?? '';
          if (mounted) {
            context.push(
              '/video-call',
              extra: {
                'consultationId': booking.consultationId,
                'userId': authState.user.id,
                'role': 'patient',
                'token': token,
              },
            );
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking balance: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleSeeDetailClick(String consultationId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final data = await _repository.fetchConsultationDetails(consultationId);
      if (!mounted) return;
      Navigator.pop(context);

      _showConsultationBottomSheet(data);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showConsultationBottomSheet(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final endedAtStr =
            data['ended_at'] != null
                ? DateFormat(
                  'MMM d, yyyy - hh:mm a',
                ).format(DateTime.parse(data['ended_at']).toLocal())
                : 'N/A';
        final rating = data['expert_rating'];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Consultation Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                _buildDetailRow(
                  'Status',
                  data['status']?.toString().toUpperCase() ?? 'N/A',
                  color:
                      data['status'] == 'completed'
                          ? Colors.green
                          : Colors.black87,
                ),
                _buildDetailRow('Ended At', endedAtStr),
                _buildDetailRow(
                  'Duration',
                  '${data['duration_minutes'] ?? 0} mins',
                ),
                _buildDetailRow(
                  'Tokens Charged',
                  '${data['tokens_charged'] ?? 0} tokens',
                  color: AppColors.primary,
                  isBold: true,
                ),

                const SizedBox(height: 8),
                const Text(
                  'Diagnosis / Result',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    data['result']?.toString().isNotEmpty == true
                        ? data['result']
                        : 'No result provided.',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                if (rating != null) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Rating',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (index) => Icon(
                          index < (rating['score'] as num).toInt()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  if (rating['comment']?.toString().isNotEmpty == true) ...[
                    const SizedBox(height: 8),
                    Text(
                      '"${rating['comment']}"',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                fontSize: 15,
                color: color ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'My Appointments',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
          ),
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                  children: [
                    _buildList(_upcomingBookings, isPast: false),
                    _buildList(_pastBookings, isPast: true),
                  ],
                ),
      ),
    );
  }

  Widget _buildList(List<Booking> bookings, {required bool isPast}) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPast ? Icons.history : Icons.event_busy,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isPast ? 'No past appointments' : 'No upcoming appointments',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (booking.status) {
      case 'pending':
        badgeColor = Colors.orange;
        badgeText = 'Pending';
        badgeIcon = Icons.hourglass_empty;
        break;
      case 'confirmed':
        badgeColor = Colors.green;
        badgeText = 'Confirmed';
        badgeIcon = Icons.check_circle;
        break;
      case 'cancelled':
        badgeColor = Colors.red;
        badgeText = 'Cancelled';
        badgeIcon = Icons.cancel;
        break;
      default:
        badgeColor = Colors.grey;
        badgeText = 'Completed';
        badgeIcon = Icons.done_all;
    }

    final dateStr = DateFormat('EEE, MMM d, yyyy').format(booking.scheduledAt);
    final timeStr = DateFormat('hh:mm a').format(booking.scheduledAt);

    final localTime = booking.scheduledAt.toLocal();
    final timeDifference = localTime.difference(DateTime.now()).inMinutes;
    final canJoinCall = timeDifference <= 10 && timeDifference >= -60;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(badgeIcon, size: 14, color: badgeColor),
                    const SizedBox(width: 4),
                    Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(
                    booking.callType == 'video'
                        ? Icons.videocam
                        : booking.callType == 'chat'
                        ? Icons.chat
                        : Icons.call,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    booking.callType.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage:
                    booking.expertAvatarUrl != null
                        ? NetworkImage(booking.expertAvatarUrl!)
                        : null,
                child:
                    booking.expertAvatarUrl == null
                        ? Icon(Icons.person, color: AppColors.primary)
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.expertName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.expertRole,
                      style: TextStyle(fontSize: 13, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  dateStr,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                const Icon(Icons.access_time, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  timeStr,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // --- LOGIC HIỂN THỊ NÚT CHO TỪNG TRẠNG THÁI ---
          if (booking.status == 'pending' || booking.status == 'confirmed') ...[
            const SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey[200]),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _cancelBooking(booking),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      booking.status == 'pending' ? 'Cancel Request' : 'Cancel',
                    ),
                  ),
                ),
                if (booking.status == 'confirmed') ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          canJoinCall
                              ? () => _handleJoinCallClick(booking)
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            canJoinCall ? AppColors.primary : Colors.grey[300],
                        foregroundColor:
                            canJoinCall ? Colors.white : Colors.grey[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Join Call'),
                    ),
                  ),
                ],
              ],
            ),
          ] else if (booking.status == 'completed' &&
              booking.consultationId != null) ...[
            const SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey[200]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _handleSeeDetailClick(booking.consultationId!),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('See Detail'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showInsufficientFundsDialog(int currentBalance, int requiredToken) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Column(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 48,
                  color: Colors.orange,
                ),
                SizedBox(height: 16),
                Text(
                  'Tokens not enough!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ],
            ),
            content: Text(
              'You currently have $currentBalance Token.\n\nTo call this expert, your wallet needs at least $requiredToken Token (equivalent to 1 minute of consultation).\n\nPlease top up to continue.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actionsPadding: const EdgeInsets.only(
              bottom: 20,
              left: 20,
              right: 20,
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        foregroundColor: Colors.grey.shade700,
                      ),
                      child: const Text(
                        'Later',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/topup');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Top Up Now',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
    );
  }
}
