import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StepsWidget extends StatelessWidget {
  final int steps;
  final int goal;

  const StepsWidget({super.key, required this.steps, required this.goal});

  @override
  Widget build(BuildContext context) {
    double progress = steps / goal;

    return GestureDetector(
      onTap: () => context.push('/steps'),
      child: Container(
        padding: const EdgeInsets.all(12.0),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final circularSize = (constraints.maxWidth * 0.8).clamp(
              80.0,
              120.0,
            );
            final fontSize = (constraints.maxWidth * 0.14).clamp(18.0, 22.0);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: circularSize,
                  height: circularSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      FractionallySizedBox(
                        widthFactor: 0.7,
                        heightFactor: 0.7,
                        child: CircularProgressIndicator(
                          value: 1,
                          strokeWidth: 14,
                          valueColor: AlwaysStoppedAnimation(
                            Colors.grey.shade300,
                          ),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: 0.7,
                        heightFactor: 0.7,
                        child: CircularProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          strokeWidth: 14,
                          valueColor: const AlwaysStoppedAnimation(
                            Colors.orange,
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      Text(
                        steps.toString(),
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "$steps / $goal",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: (constraints.maxWidth * 0.09).clamp(12.0, 14.0),
                  ),
                ),
                Text(
                  "Steps Walked",
                  style: TextStyle(
                    fontSize: (constraints.maxWidth * 0.075).clamp(10.0, 12.0),
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
