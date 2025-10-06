import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      onTap: () => context.push('/steps'),
      child: Container(
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _decrease,
                  icon: const Icon(Icons.remove_circle, color: Colors.blueGrey),
                  iconSize: 32,
                ),
                Container(
                  width: 60,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400, width: 2),
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
                IconButton(
                  onPressed: _increase,
                  icon: const Icon(Icons.add_circle, color: Colors.teal),
                  iconSize: 32,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "${liters.toStringAsFixed(1)} liters",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text("Daily Water Intake"),
          ],
        ),
      ),
    );
  }
}
