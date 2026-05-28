import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/features/user/advisor/data/booking_repository.dart';
import 'package:da1/src/features/user/advisor/domain/booking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyAppointmentsScreen extends StatefulWidget {
  const MyAppointmentsScreen({super.key});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  final BookingRepository _repository = BookingRepository();

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
          if (booking.status == 'pending' || booking.status == 'confirmed') ...[
            const SizedBox(height: 16),
            Divider(height: 1, color: Colors.grey[200]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
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
                  booking.status == 'pending'
                      ? 'Cancel Request'
                      : 'Cancel Appointment',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
