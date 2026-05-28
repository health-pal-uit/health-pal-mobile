import 'package:da1/src/config/theme/app_colors.dart';
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
                                if (slot['status'] != 'Available') {
                                  // TODO: Mở BottomSheet khi bấm vào lịch có người đặt
                                  // _showBookingDetailsBottomSheet(slot['bookingData']);
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
}
