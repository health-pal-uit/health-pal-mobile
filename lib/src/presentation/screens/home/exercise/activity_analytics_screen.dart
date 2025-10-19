import 'package:da1/src/config/theme/typography.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class ActivityAnalyticsScreen extends StatefulWidget {
  const ActivityAnalyticsScreen({super.key});

  @override
  State<ActivityAnalyticsScreen> createState() =>
      _ActivityAnalyticsScreenState();
}

class _ActivityAnalyticsScreenState extends State<ActivityAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const _Header(),
                const SizedBox(height: 24),
                const _TimeFrameTabs(),
                const SizedBox(height: 16),
                const _StatsGrid(),
                const SizedBox(height: 16),
                const _WeeklyGoalProgress(),
                const SizedBox(height: 24),
                const _ChartSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(LucideIcons.chevronLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        Text('Activity Analytics', style: AppTypography.headline),
        const SizedBox(width: 40),
      ],
    );
  }
}

class _TimeFrameTabs extends StatefulWidget {
  const _TimeFrameTabs();

  @override
  State<_TimeFrameTabs> createState() => _TimeFrameTabsState();
}

class _TimeFrameTabsState extends State<_TimeFrameTabs> {
  int _selectedIndex = 0;
  final List<String> _tabs = ['Week', 'Month', 'Year'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_tabs.length, (index) {
        final isSelected = _selectedIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFA9500) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border:
                    isSelected ? null : Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _tabs[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF0A0A0A),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department,
                title: 'Calories',
                value: '2970',
                subtitle: 'kcal burned',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.timer,
                title: 'Duration',
                value: '6h 45m',
                subtitle: 'total time',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.directions_run,
                title: 'Distance',
                value: '35.6 km',
                subtitle: 'covered',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.calendar_today,
                title: 'Avg/Day',
                value: '424',
                subtitle: 'kcal',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF717182), size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(color: Color(0xFF717182), fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0A0A0A),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF717182), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _WeeklyGoalProgress extends StatelessWidget {
  const _WeeklyGoalProgress();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Goal Progress',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '85%',
                  style: TextStyle(
                    color: Color(0xFFFA9500),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.85,
              minHeight: 8,
              backgroundColor: Color(0x33FA9500),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFA9500)),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Great job! You're almost there!",
            style: TextStyle(color: Color(0xFF717182), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  const _ChartSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ChartTabs(),
          const SizedBox(height: 16),
          const Text(
            'Calories Burned',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Last 7 days',
            style: TextStyle(color: Color(0xFF717182), fontSize: 16),
          ),
          const SizedBox(height: 24),
          const _BarChart(),
        ],
      ),
    );
  }
}

class _ChartTabs extends StatefulWidget {
  const _ChartTabs();

  @override
  State<_ChartTabs> createState() => _ChartTabsState();
}

class _ChartTabsState extends State<_ChartTabs> {
  int _selectedIndex = 0;
  final List<String> _tabs = ['Charts', 'Breakdown', 'History'];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFECECF0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.all(3),
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _tabs[index],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF0A0A0A),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _BarChart extends StatelessWidget {
  const _BarChart();

  @override
  Widget build(BuildContext context) {
    final List<double> weeklyData = [0.8, 0.5, 0.9, 0.4, 0.7, 0.6, 0.85];
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return SizedBox(
      height: 180,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 12,
                height: 150 * weeklyData[Random().nextInt(weeklyData.length)],
                decoration: BoxDecoration(
                  color: const Color(0xFFFA9500),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                days[index],
                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
              ),
            ],
          );
        }),
      ),
    );
  }
}
