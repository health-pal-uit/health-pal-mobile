import 'package:flutter/material.dart';

class StepsWidget extends StatelessWidget {
  final int steps;
  final int goal;

  const StepsWidget({super.key, required this.steps, required this.goal});

  @override
  Widget build(BuildContext context) {
    double progress = steps / goal;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 150,
            height: 140,
            child: Stack(
              alignment: Alignment.center,
              children: [
                FractionallySizedBox(
                  widthFactor: 0.7,
                  heightFactor: 0.7,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 14,
                    valueColor: AlwaysStoppedAnimation(Colors.grey.shade300),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: 0.7,
                  heightFactor: 0.7,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 14,
                    valueColor: const AlwaysStoppedAnimation(Colors.orange),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                Text(
                  steps.toString(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Steps Walked",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
