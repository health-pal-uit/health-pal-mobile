import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/core/bloc/auth/auth.dart';
import 'package:da1/src/features/expert/dashboard/data/booking_model.dart';
import 'package:da1/src/features/expert/dashboard/data/booking_repository.dart';
import 'package:da1/src/features/expert/dashboard/presentation/widgets/expert_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'widgets/schedule_calendar_picker.dart';
import 'widgets/schedule_statistics_card.dart';
import 'widgets/schedule_time_slot_card.dart';

class ScheduleManagementScreen extends StatefulWidget {
  const ScheduleManagementScreen({super.key});

  @override
  State<ScheduleManagementScreen> createState() =>
      _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  late DateTime _selectedDate;
  int _bottomNavIndex = 1;

  bool _isLoading = true;
  List<BookingModel> _allBookings = [];

  final BookingRepository _bookingRepository = BookingRepository();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadAllBookings();
  }

  Future<void> _loadAllBookings() async {
    setState(() => _isLoading = true);
    try {
      final data = await _bookingRepository.getAllBookings();
      setState(() {
        _allBookings = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAcceptBooking(String bookingId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await _bookingRepository.acceptBooking(bookingId);
      if (mounted) Navigator.pop(context);
      await _loadAllBookings();
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  Future<void> _handleDeclineBooking(String bookingId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await _bookingRepository.declineBooking(bookingId);
      if (mounted) Navigator.pop(context);
      await _loadAllBookings();
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  List<Map<String, dynamic>> _generateTimeSlotsForSelectedDate() {
    final List<Map<String, dynamic>> slots = [];

    for (int hour = 8; hour <= 16; hour++) {
      final bookingInSlot =
          _allBookings.where((b) {
            final localTime = b.scheduledAt.toLocal();
            return localTime.year == _selectedDate.year &&
                localTime.month == _selectedDate.month &&
                localTime.day == _selectedDate.day &&
                localTime.hour == hour;
          }).firstOrNull;

      String status = 'Available';
      String? name;

      if (bookingInSlot != null) {
        name = bookingInSlot.clientName;
        if (bookingInSlot.status == 'pending') {
          status = 'Requested';
        } else if (bookingInSlot.status == 'confirmed') {
          status = 'Booked';
        }
      }

      final startStr = "${hour.toString().padLeft(2, '0')}:00";
      final endStr = "${(hour + 1).toString().padLeft(2, '0')}:00";

      slots.add({
        'time': '$startStr - $endStr',
        'status': status,
        'name': name,
        'bookingData': bookingInSlot,
      });
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final slotsToday = _generateTimeSlotsForSelectedDate();
    final pendingCount =
        slotsToday.where((s) => s['status'] == 'Requested').length;
    final bookedCount = slotsToday.where((s) => s['status'] == 'Booked').length;
    final totalSlotsCount = slotsToday.length;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) context.go('/welcome');
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            'Schedule Management',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScheduleCalendarPicker(
                          selectedDate: _selectedDate,
                          allBookings: _allBookings,
                          onDateSelected: (date) {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: ScheduleStatisticsCard(
                                icon: Icons.pending_actions,
                                iconColor: const Color(0xFFFFF7ED),
                                iconBgColor: const Color(0xFFEA580C),
                                count: pendingCount.toString(),
                                label: 'Pending',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ScheduleStatisticsCard(
                                icon: Icons.event_available,
                                iconColor: const Color(0xFFDBEAFE),
                                iconBgColor: const Color(0xFF155DFC),
                                count: bookedCount.toString(),
                                label: 'Booked',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ScheduleStatisticsCard(
                                icon: Icons.view_week,
                                iconColor: const Color(0xFFF3E8FF),
                                iconBgColor: const Color(0xFFA855F7), // Tím
                                count: totalSlotsCount.toString(),
                                label: 'Total Slots',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Text(
                          'Slots for ${_formatDate(_selectedDate)}',
                          style: const TextStyle(
                            color: Color(0xFF364153),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 12),

                        ...slotsToday.map((slot) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GestureDetector(
                              onTap: () {
                                if (slot['status'] != 'Available' &&
                                    slot['bookingData'] != null) {
                                  _showBookingDetailsBottomSheet(
                                    slot['bookingData'],
                                  );
                                }
                              },
                              child: ScheduleTimeSlotCard(
                                time: slot['time'] as String,
                                status: slot['status'] as String,
                                name: slot['name'] as String?,
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        bottomNavigationBar: ExpertBottomNav(
          currentIndex: _bottomNavIndex,
          onTap: (index) {
            setState(() => _bottomNavIndex = index);
            switch (index) {
              case 0:
                context.go('/expert/dashboard');
                break;
              case 1:
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

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _showBookingDetailsBottomSheet(BookingModel booking) async {
    final localTime = booking.scheduledAt.toLocal();
    final timeStr =
        "${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}";
    final dateStr =
        "${localTime.day.toString().padLeft(2, '0')}/${localTime.month.toString().padLeft(2, '0')}/${localTime.year}";
    final isPending = booking.status == 'pending';

    final action = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Booking Details',
                      style: AppTypography.headline.copyWith(fontSize: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isPending
                                ? Colors.orange.shade100
                                : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isPending ? 'Pending' : 'Confirmed',
                        style: TextStyle(
                          color:
                              isPending
                                  ? Colors.orange.shade800
                                  : Colors.blue.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          booking.clientAvatar.isNotEmpty
                              ? NetworkImage(booking.clientAvatar)
                              : null,
                      child:
                          booking.clientAvatar.isEmpty
                              ? const Icon(Icons.person, color: Colors.grey)
                              : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.clientName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                booking.callType == 'video'
                                    ? Icons.videocam
                                    : Icons.call,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '$timeStr • $dateStr',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(),
                ),

                const Text(
                  'Client Notes:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    (booking.clientNote == null ||
                            booking.clientNote!.trim().isEmpty)
                        ? 'No notes available.'
                        : booking.clientNote!,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, 'decline'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(isPending ? 'Decline' : 'Cancel Booking'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (isPending) {
                            Navigator.pop(context, 'accept');
                          } else {
                            // TODO: Điều hướng vào Room Call
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Connecting to Call room...'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor:
                              isPending ? Colors.green : AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          isPending ? 'Accept' : 'Join Call',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (action == 'accept') {
      _handleAcceptBooking(booking.id);
    } else if (action == 'decline') {
      _handleDeclineBooking(booking.id);
    }
  }
}
