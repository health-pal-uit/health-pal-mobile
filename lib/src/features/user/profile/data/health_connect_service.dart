import 'package:flutter/cupertino.dart';
import 'package:health/health.dart';

enum HealthConnectRecordType {
  steps,
  distance,
  activeCalories,
  heartRate,
  exerciseSession,
}

class HealthConnectService {
  final _health = Health();

  static const _permissions = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WORKOUT,
  ];

  // 1️⃣ Check Health Connect Availability
  Future<bool> isHealthConnectAvailable() async {
    try {
      bool isAvailable = await Health().isHealthConnectAvailable();
      return isAvailable;
    } catch (e) {
      debugPrint('❌ Error checking Health Connect: $e');
      return false;
    }
  }

  // 2️⃣ Request Permissions
  Future<bool> requestPermissions() async {
    try {
      final granted = await _health.requestAuthorization(_permissions);
      return granted;
    } catch (e) {
      debugPrint('❌ Permission request failed: $e');
      return false;
    }
  }

  // 3️⃣ Read Steps Data
  Future<List<HealthDataPoint>> getStepsData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      List<HealthDataPoint> steps = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startDate,
        endTime: endDate,
      );
      return steps;
    } catch (e) {
      debugPrint('❌ Error fetching steps: $e');
      return [];
    }
  }

  // 4️⃣ Read Exercise Data
  Future<List<HealthDataPoint>> getExerciseData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      List<HealthDataPoint> workouts = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT],
        startTime: startDate,
        endTime: endDate,
      );
      return workouts;
    } catch (e) {
      debugPrint('❌ Error fetching exercises: $e');
      return [];
    }
  }

  // 5️⃣ Read Heart Rate Data
  Future<List<HealthDataPoint>> getHeartRateData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      List<HealthDataPoint> heartRates = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: startDate,
        endTime: endDate,
      );
      return heartRates;
    } catch (e) {
      debugPrint('❌ Error fetching heart rate: $e');
      return [];
    }
  }

  // 6️⃣ Read All Activity Data (Last N days)
  Future<Map<String, List<HealthDataPoint>>> getAllActivityData({
    int daysBack = 7,
  }) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: daysBack));

    final results = {
      'steps': await getStepsData(startDate: startDate, endDate: now),
      'exercises': await getExerciseData(startDate: startDate, endDate: now),
      'heartRates': await getHeartRateData(startDate: startDate, endDate: now),
    };

    return results;
  }
}
