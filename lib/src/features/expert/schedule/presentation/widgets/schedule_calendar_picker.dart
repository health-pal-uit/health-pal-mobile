import 'package:da1/src/features/expert/dashboard/data/booking_model.dart';
import 'package:flutter/material.dart';

class ScheduleCalendarPicker extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final List<BookingModel> allBookings;

  const ScheduleCalendarPicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.allBookings,
  });

  @override
  State<ScheduleCalendarPicker> createState() => _ScheduleCalendarPickerState();
}

class _ScheduleCalendarPickerState extends State<ScheduleCalendarPicker> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
    );
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7;

    final monthNames = [
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1.25,
            color: Colors.black.withValues(alpha: 0.10),
          ),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Header
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(
                        _currentMonth.year,
                        _currentMonth.month - 1,
                      );
                    });
                  },
                  icon: const Icon(Icons.chevron_left),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
                Text(
                  '${monthNames[_currentMonth.month - 1]} ${_currentMonth.year}',
                  style: const TextStyle(
                    color: Color(0xFF0A0A0A),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _currentMonth = DateTime(
                        _currentMonth.year,
                        _currentMonth.month + 1,
                      );
                    });
                  },
                  icon: const Icon(Icons.chevron_right),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          // Day Headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _DayHeader('Su'),
              _DayHeader('Mo'),
              _DayHeader('Tu'),
              _DayHeader('We'),
              _DayHeader('Th'),
              _DayHeader('Fr'),
              _DayHeader('Sa'),
            ],
          ),
          const SizedBox(height: 24),

          // Calendar Grid
          GridView.count(
            crossAxisCount: 7,
            childAspectRatio: 1,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(42, (index) {
              final day = index - firstDayOfMonth + 1;

              if (day <= 0 || day > daysInMonth) {
                return Container();
              }

              final isSelected =
                  widget.selectedDate.day == day &&
                  widget.selectedDate.month == _currentMonth.month &&
                  widget.selectedDate.year == _currentMonth.year;

              final date = DateTime(
                _currentMonth.year,
                _currentMonth.month,
                day,
              );

              bool hasPending = false;
              bool hasConfirmed = false;

              for (var booking in widget.allBookings) {
                final localTime = booking.scheduledAt.toLocal();
                if (localTime.year == date.year &&
                    localTime.month == date.month &&
                    localTime.day == date.day) {
                  if (booking.status == 'pending') hasPending = true;
                  if (booking.status == 'confirmed') hasConfirmed = true;
                }
              }

              return GestureDetector(
                onTap: () {
                  widget.onDateSelected(date);
                  setState(() {});
                },
                child: Container(
                  decoration: ShapeDecoration(
                    color:
                        isSelected
                            ? const Color(0xFF030213)
                            : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFF0A0A0A),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (hasPending || hasConfirmed) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (hasConfirmed)
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1.5,
                                ),
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (hasPending)
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1.5,
                                ),
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final String label;

  const _DayHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF717182),
            fontSize: 12.80,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
