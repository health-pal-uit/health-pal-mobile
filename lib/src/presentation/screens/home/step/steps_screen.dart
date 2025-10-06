import 'package:da1/src/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

class StepsScreen extends StatefulWidget {
  const StepsScreen({super.key});

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> {
  int selectedTab = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: Colors.black,
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "STEPS",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTabs(),
            const SizedBox(height: 16),
            _buildChartCard(),
            const SizedBox(height: 16),
            _buildSummaryRow(),
            const SizedBox(height: 16),
            _buildGoalCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    final labels = ["D", "W", "M", "Y"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(labels.length, (index) {
        final isSelected = index == selectedTab;
        return GestureDetector(
          onTap: () => setState(() => selectedTab = index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 60,
            height: 35,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 5,
                        ),
                      ]
                      : [],
            ),
            alignment: Alignment.center,
            child: Text(
              labels[index],
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black54,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildChartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Avg", style: TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          const Text(
            "1617",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
          const Text(
            "Steps/day",
            style: TextStyle(color: Colors.black87, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            "July 16 - Aug 14",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                gridData: FlGridData(show: true, horizontalInterval: 5000),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, interval: 5000),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final days = [
                          "16/07",
                          "23/07",
                          "30/07",
                          "06/08",
                          "13/08",
                        ];
                        int index = value.toInt();
                        if (index < 0 || index >= days.length) {
                          return const SizedBox();
                        }
                        return Text(
                          days[index],
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _barGroup(0, 2000),
                  _barGroup(1, 4000),
                  _barGroup(2, 10000),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _barGroup(int x, double value) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          width: 12,
          borderRadius: BorderRadius.circular(6),
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildSummaryRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _SummaryItem(label: "Distance", value: "14.41"),
          _SummaryItem(label: "Duration", value: "03:22:00"),
          _SummaryItem(label: "Calories", value: "1361"),
        ],
      ),
    );
  }

  Widget _buildGoalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, const Color(0xFFF5F6FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Reached goal",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          SizedBox(height: 12),
          _GoalRow(label: "Total days reaching the goal", value: "4 d"),
          _GoalRow(label: "Consecutive days reaching the goal", value: "2 d"),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}

class _GoalRow extends StatelessWidget {
  final String label;
  final String value;
  const _GoalRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black87)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
