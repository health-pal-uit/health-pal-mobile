import 'package:health/health.dart';
import 'fitness_sync_api.dart';

class HealthDataTransformer {
  // Transform steps to SyncFitnessRecordDto
  static SyncFitnessRecordDto transformSteps(HealthDataPoint point) {
    // Ép kiểu value về NumericHealthValue để lấy số
    final numericValue = point.value as NumericHealthValue;

    return SyncFitnessRecordDto(
      source: 'health_connect',
      record_type: 'steps',
      external_record_id: 'hc:steps:${point.dateFrom.millisecondsSinceEpoch}',
      start_time: point.dateFrom.toIso8601String(),
      end_time: point.dateTo.toIso8601String(),
      steps_count: numericValue.numericValue.toInt(),
      duration_minutes: _calculateDuration(point.dateFrom, point.dateTo),
      device_id: point.sourceId, // Lấy ID nguồn từ Health Connect
      timezone: DateTime.now().timeZoneName,
    );
  }

  // Transform exercise to SyncFitnessRecordDto
  static SyncFitnessRecordDto transformExercise(HealthDataPoint point) {
    // Phiên bản mới dùng WorkoutHealthValue thay vì Workout
    final workout = point.value as WorkoutHealthValue;

    return SyncFitnessRecordDto(
      source: 'health_connect',
      record_type: 'exercise_session',
      external_record_id:
          'hc:exercise:${point.dateFrom.millisecondsSinceEpoch}',
      exercise_type: workout.workoutActivityType.name.toLowerCase(),
      start_time: point.dateFrom.toIso8601String(),
      end_time: point.dateTo.toIso8601String(),
      duration_minutes: _calculateDuration(point.dateFrom, point.dateTo),
      active_calories_kcal: _extractCalories(workout),
      intensity_level: _calculateIntensity(workout),
      device_id: point.sourceId,
      timezone: DateTime.now().timeZoneName,
    );
  }

  // Transform heart rate to SyncFitnessRecordDto
  static SyncFitnessRecordDto transformHeartRate(HealthDataPoint point) {
    final numericValue = point.value as NumericHealthValue;

    return SyncFitnessRecordDto(
      source: 'health_connect',
      record_type: 'heart_rate',
      external_record_id:
          'hc:heart_rate:${point.dateFrom.millisecondsSinceEpoch}',
      start_time: point.dateFrom.toIso8601String(),
      end_time: point.dateTo.toIso8601String(),
      avg_heart_rate_bpm: numericValue.numericValue.toInt(),
      duration_minutes: _calculateDuration(point.dateFrom, point.dateTo),
      device_id: point.sourceId,
      timezone: DateTime.now().timeZoneName,
    );
  }

  // Helper: Calculate duration in minutes
  static int _calculateDuration(DateTime start, DateTime end) {
    return end.difference(start).inMinutes;
  }

  // Helper: Extract calories (Từ WorkoutHealthValue)
  static double? _extractCalories(WorkoutHealthValue workout) {
    // Health package mới có thể lưu lượng calo trong một thuộc tính khác (nếu có hỗ trợ)
    // Tạm thời trả về null hoặc lấy thuộc tính totalEnergyBurned (nếu library vẫn giữ)
    return workout.totalEnergyBurned?.toDouble();
  }

  // Helper: Calculate intensity (1-5 scale)
  static int _calculateIntensity(WorkoutHealthValue workout) {
    switch (workout.workoutActivityType) {
      case HealthWorkoutActivityType.WALKING:
      case HealthWorkoutActivityType.YOGA:
        return 1;
      case HealthWorkoutActivityType.RUNNING:
      case HealthWorkoutActivityType.SWIMMING:
        return 4;
      case HealthWorkoutActivityType.HIGH_INTENSITY_INTERVAL_TRAINING:
      case HealthWorkoutActivityType.BOXING:
        return 5;
      default:
        return 3;
    }
  }

  // Convert all health data points
  static List<SyncFitnessRecordDto> transformAllData(
    Map<String, List<HealthDataPoint>> allData,
  ) {
    final records = <SyncFitnessRecordDto>[];

    // Transform steps
    for (var point in allData['steps'] ?? []) {
      records.add(transformSteps(point));
    }

    // Transform exercises
    for (var point in allData['exercises'] ?? []) {
      records.add(transformExercise(point));
    }

    // Transform heart rates
    for (var point in allData['heartRates'] ?? []) {
      records.add(transformHeartRate(point));
    }

    return records;
  }
}
