import 'package:da1/src/config/env.dart';
import 'package:da1/src/features/user/profile/data/fitness_sync_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Thêm để dùng debugPrint
import 'package:workmanager/workmanager.dart';
import 'health_connect_service.dart';
import 'health_data_transformer.dart';

@pragma('vm:entry-point') // Rất quan trọng cho Workmanager
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final healthService = HealthConnectService();
      final token = inputData?['token'] as String?;
      final baseUrl = inputData?['baseUrl'] as String?;

      if (token == null || baseUrl == null) return false;

      final apiService = FitnessSyncApi(Dio(), baseUrl: baseUrl);

      // Không cần biến startDate nữa vì getAllActivityData đã tự tính
      final allData = await healthService.getAllActivityData(daysBack: 1);
      final records = HealthDataTransformer.transformAllData(allData);

      if (records.isNotEmpty) {
        final batch = SyncFitnessRecordsBatchDto(records: records);
        await apiService.syncRecords('Bearer $token', batch);
        debugPrint('✅ Background sync completed');
      }

      return true;
    } catch (e) {
      debugPrint('❌ Background sync failed: $e');
      return false;
    }
  });
}

class BackgroundSyncService {
  static Future<void> initializeBackgroundSync() async {
    // Phiên bản mới đã bỏ isInDebugMode ở đây
    await Workmanager().initialize(callbackDispatcher);
  }

  static Future<void> startPeriodicSync(String token) async {
    await Workmanager().registerPeriodicTask(
      'health_sync_task', // Unique name
      'healthSync', // Task name
      frequency: const Duration(hours: 1),
      inputData: {'token': token, 'baseUrl': Env.backendApiUrl},
      constraints: Constraints(
        // Cập nhật các biến cho đúng với bản Workmanager mới nhất
        networkType: NetworkType.connected, // Yêu cầu có mạng
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  static Future<void> stopPeriodicSync() async {
    await Workmanager().cancelByUniqueName('health_sync_task');
  }
}
