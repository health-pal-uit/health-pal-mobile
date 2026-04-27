import 'package:flutter/material.dart';

class ScheduleTimeSlotCard extends StatelessWidget {
  final String time;
  final String status;
  final bool isAvailable;
  final String? name;

  const ScheduleTimeSlotCard({
    super.key,
    required this.time,
    required this.status,
    required this.isAvailable,
    this.name,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isAvailable ? const Color(0xFFF0FDF4) : const Color(0xFFEFF6FF);

    final borderColor =
        isAvailable ? const Color(0xFFB9F8CF) : const Color(0xFFBEDBFF);

    final iconBgColor =
        isAvailable ? const Color(0xFF00A63E) : const Color(0xFF155DFC);

    final statusBgColor =
        isAvailable ? const Color(0xFF00A63E) : const Color(0xFF155DFC);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.25, color: borderColor),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time and Name
          Expanded(
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.access_time, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),

                // Time and Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          color: Color(0xFF101828),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (name != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          name!,
                          style: const TextStyle(
                            color: Color(0xFF4A5565),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: ShapeDecoration(
              color: statusBgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: Text(
              status,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
