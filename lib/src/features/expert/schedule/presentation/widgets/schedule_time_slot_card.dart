import 'package:flutter/material.dart';

class ScheduleTimeSlotCard extends StatelessWidget {
  final String time;
  final String status;
  final String? name;

  const ScheduleTimeSlotCard({
    super.key,
    required this.time,
    required this.status,
    this.name,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color iconBgColor;

    if (status == 'Requested') {
      backgroundColor = const Color(0xFFFFF7ED);
      borderColor = const Color(0xFFFED7AA);
      iconBgColor = const Color(0xFFEA580C);
    } else if (status == 'Booked') {
      backgroundColor = const Color(0xFFEFF6FF);
      borderColor = const Color(0xFFBEDBFF);
      iconBgColor = const Color(0xFF155DFC);
    } else {
      backgroundColor = const Color(0xFFF0FDF4);
      borderColor = const Color(0xFFB9F8CF);
      iconBgColor = const Color(0xFF00A63E);
    }

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
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: ShapeDecoration(
              color: iconBgColor,
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
