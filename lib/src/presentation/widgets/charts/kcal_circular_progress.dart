import 'package:da1/src/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class KcalCircularProgressCard extends StatelessWidget {
  final int consumed;
  final int needed;
  final int exercise;

  const KcalCircularProgressCard({
    super.key,
    required this.consumed,
    required this.needed,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.backgroundLight,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Macros",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Calories",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 180,
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: 2000,
                  showLabels: false,
                  showTicks: false,
                  axisLineStyle: const AxisLineStyle(
                    thickness: 0.15,
                    cornerStyle: CornerStyle.bothFlat,
                    color: Color(0xFFE0E0E0),
                    thicknessUnit: GaugeSizeUnit.factor,
                  ),
                  annotations: [
                    GaugeAnnotation(
                      widget: Text(
                        consumed.toString(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      positionFactor: 0,
                      angle: 90,
                    ),
                  ],
                  pointers: <GaugePointer>[
                    RangePointer(
                      value: consumed.toDouble(),
                      width: 0.15,
                      sizeUnit: GaugeSizeUnit.factor,
                      color: Colors.blue,
                      cornerStyle: CornerStyle.bothCurve,
                    ),
                    RangePointer(
                      value: needed.toDouble(),
                      width: 0.15,
                      sizeUnit: GaugeSizeUnit.factor,
                      color: Colors.orange,
                      cornerStyle: CornerStyle.bothCurve,
                    ),
                    RangePointer(
                      value: exercise.toDouble(),
                      width: 0.15,
                      sizeUnit: GaugeSizeUnit.factor,
                      color: Colors.pink,
                      cornerStyle: CornerStyle.bothCurve,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegend(color: Colors.blue, label: "Needed", value: needed),
              _buildLegend(
                color: Colors.orange,
                label: "Consumed",
                value: consumed,
              ),
              _buildLegend(
                color: Colors.pink,
                label: "Exercise",
                value: exercise,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend({
    required Color color,
    required String label,
    required int value,
  }) {
    return Row(
      children: [
        Icon(Icons.square, size: 14, color: color),
        const SizedBox(width: 4),
        Text("$label "),
        Text("$value", style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
