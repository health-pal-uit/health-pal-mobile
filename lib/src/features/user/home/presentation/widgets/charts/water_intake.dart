import 'package:flutter/material.dart';

class WaterIntakeWidget extends StatefulWidget {
  const WaterIntakeWidget({super.key});

  @override
  State<WaterIntakeWidget> createState() => _WaterIntakeWidgetState();
}

class _WaterIntakeWidgetState extends State<WaterIntakeWidget> {
  int _glasses = 3;
  final int _maxGlasses = 8;

  void _increase() {
    if (_glasses < _maxGlasses) {
      setState(() => _glasses++);
    }
  }

  void _decrease() {
    if (_glasses > 0) {
      setState(() => _glasses--);
    }
  }

  @override
  Widget build(BuildContext context) {
    double liters = _glasses * 0.25;

    return GestureDetector(
      onTap: null,
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
            final glassHeight = (constraints.maxWidth * 0.8).clamp(80.0, 120.0);
            final iconSize = (constraints.maxWidth * 0.18).clamp(22.0, 28.0);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _decrease,
                      icon: const Icon(
                        Icons.remove_circle,
                        color: Colors.blueGrey,
                      ),
                      iconSize: iconSize,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    SizedBox(width: constraints.maxWidth * 0.05),
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth * 0.5,
                        ),
                        height: glassHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children:
                              List.generate(_maxGlasses, (index) {
                                final isFilled = index < _glasses;
                                return Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 1,
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isFilled
                                              ? Colors.teal
                                              : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                );
                              }).reversed.toList(),
                        ),
                      ),
                    ),
                    SizedBox(width: constraints.maxWidth * 0.05),
                    IconButton(
                      onPressed: _increase,
                      icon: const Icon(Icons.add_circle, color: Colors.teal),
                      iconSize: iconSize,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "${liters.toStringAsFixed(1)} liters",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: (constraints.maxWidth * 0.09).clamp(12.0, 14.0),
                  ),
                ),
                Text(
                  "Daily Water Intake",
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
