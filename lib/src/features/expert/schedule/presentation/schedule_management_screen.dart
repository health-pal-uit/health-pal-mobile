import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/core/bloc/auth/auth.dart';
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
  int _bottomNavIndex = 1; // Schedule is at index 1

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: 5));
  }

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
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            'Schedule Management',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 36,
                height: 32,
                decoration: ShapeDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Calendar Picker
                ScheduleCalendarPicker(
                  selectedDate: _selectedDate,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Statistics Cards
                Row(
                  children: [
                    Expanded(
                      child: ScheduleStatisticsCard(
                        icon: Icons.check_circle,
                        iconColor: const Color(0xFFDCFCE7),
                        iconBgColor: const Color(0xFF00A63E),
                        count: '3',
                        label: 'Available',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ScheduleStatisticsCard(
                        icon: Icons.calendar_today,
                        iconColor: const Color(0xFFDBEAFE),
                        iconBgColor: const Color(0xFF155DFC),
                        count: '3',
                        label: 'Booked',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ScheduleStatisticsCard(
                        icon: Icons.view_week,
                        iconColor: const Color(0xFFF3E8FF),
                        iconBgColor: const Color(0xFFA855F7),
                        count: '6',
                        label: 'Total Slots',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Slots for Date
                Text(
                  'Slots for ${_formatDate(_selectedDate)}',
                  style: const TextStyle(
                    color: Color(0xFF364153),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),

                // Time Slots List
                ..._buildTimeSlots(),

                const SizedBox(height: 24),

                // Tip Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFF9FAFB),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1.25,
                        color: Colors.black.withValues(alpha: 0.10),
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: '💡 ',
                          style: TextStyle(
                            color: Color(0xFF4A5565),
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: 'Tip: ',
                          style: TextStyle(
                            color: Color(0xFF4A5565),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text:
                              'Keep your availability updated to receive more consultation requests. Patients can book available slots or request instant calls when you\'re online.',
                          style: TextStyle(
                            color: Color(0xFF4A5565),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: ExpertBottomNav(
          currentIndex: _bottomNavIndex,
          onTap: (index) {
            setState(() {
              _bottomNavIndex = index;
            });
            // Handle navigation
            switch (index) {
              case 0:
                context.go('/expert/dashboard');
                break;
              case 1:
                // Already on schedule
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
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  List<Widget> _buildTimeSlots() {
    final slots = [
      {
        'time': '09:00 AM - 10:00 AM',
        'status': 'Available',
        'isAvailable': true,
      },
      {
        'time': '10:00 AM - 11:00 AM',
        'status': 'Booked',
        'isAvailable': false,
        'name': 'Sarah Johnson',
      },
      {
        'time': '11:30 AM - 12:30 PM',
        'status': 'Booked',
        'isAvailable': false,
        'name': 'Michael Chen',
      },
      {
        'time': '02:00 PM - 03:00 PM',
        'status': 'Booked',
        'isAvailable': false,
        'name': 'Emily Davis',
      },
      {
        'time': '03:00 PM - 04:00 PM',
        'status': 'Available',
        'isAvailable': true,
      },
      {
        'time': '04:00 PM - 05:00 PM',
        'status': 'Available',
        'isAvailable': true,
      },
    ];

    return List.generate(slots.length, (index) {
      final slot = slots[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: ScheduleTimeSlotCard(
          time: slot['time'] as String,
          status: slot['status'] as String,
          isAvailable: slot['isAvailable'] as bool,
          name: slot['name'] as String?,
        ),
      );
    });
  }
}
