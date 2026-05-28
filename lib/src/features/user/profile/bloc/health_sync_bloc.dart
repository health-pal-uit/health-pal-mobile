import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/health_connect_service.dart';
import '../data/fitness_sync_api.dart';
import '../data/health_data_transformer.dart';

// --- EVENTS ---
abstract class HealthSyncEvent extends Equatable {
  const HealthSyncEvent();
  @override
  List<Object?> get props => [];
}

class CheckStatusRequested extends HealthSyncEvent {}

class ConnectHealthRequested extends HealthSyncEvent {}

class SyncDataRequested extends HealthSyncEvent {}

class DisconnectHealthRequested extends HealthSyncEvent {}

// --- STATES ---
abstract class HealthSyncState extends Equatable {
  const HealthSyncState();
  @override
  List<Object?> get props => [];
}

class HealthSyncInitial extends HealthSyncState {}

class HealthSyncLoading extends HealthSyncState {}

class HealthSyncData extends HealthSyncState {
  final bool connected;
  final DateTime? lastSyncedAt;
  final int totalSynced;

  const HealthSyncData({
    required this.connected,
    this.lastSyncedAt,
    this.totalSynced = 0,
  });

  HealthSyncData copyWith({
    bool? connected,
    DateTime? lastSyncedAt,
    int? totalSynced,
  }) {
    return HealthSyncData(
      connected: connected ?? this.connected,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      totalSynced: totalSynced ?? this.totalSynced,
    );
  }

  @override
  List<Object?> get props => [connected, lastSyncedAt, totalSynced];
}

class HealthSyncError extends HealthSyncState {
  final String message;
  const HealthSyncError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLOC ---
class HealthSyncBloc extends Bloc<HealthSyncEvent, HealthSyncState> {
  final HealthConnectService healthService;
  final FitnessSyncApi apiService;

  final _storage = const FlutterSecureStorage();

  HealthSyncBloc({required this.healthService, required this.apiService})
    : super(HealthSyncInitial()) {
    on<CheckStatusRequested>(_onCheckStatus);
    on<ConnectHealthRequested>(_onConnect);
    on<SyncDataRequested>(_onSyncData);
    on<DisconnectHealthRequested>(_onDisconnect);
  }

  Future<String> _getToken() async {
    return await _storage.read(key: 'auth_token') ?? '';
  }

  Future<void> _onCheckStatus(
    CheckStatusRequested event,
    Emitter<HealthSyncState> emit,
  ) async {
    emit(HealthSyncLoading());
    try {
      final token = await _getToken();
      final response = await apiService.getStatus('Bearer $token');
      emit(
        HealthSyncData(
          connected: response.data?.connected ?? false,
          lastSyncedAt:
              response.data?.last_synced_at != null
                  ? DateTime.parse(response.data!.last_synced_at!)
                  : null,
        ),
      );
    } catch (e) {
      emit(HealthSyncError(e.toString()));
    }
  }

  Future<void> _onConnect(
    ConnectHealthRequested event,
    Emitter<HealthSyncState> emit,
  ) async {
    emit(HealthSyncLoading());
    try {
      final available = await healthService.isHealthConnectAvailable();
      if (!available) {
        throw Exception('Health Connect not available on this device');
      }
      final granted = await healthService.requestPermissions();
      if (!granted) throw Exception('Health Connect permissions denied');
      final token = await _getToken();
      final response = await apiService.connect('Bearer $token');
      emit(HealthSyncData(connected: response.data?.connected ?? false));
    } catch (e) {
      emit(HealthSyncError(e.toString()));
    }
  }

  Future<void> _onSyncData(
    SyncDataRequested event,
    Emitter<HealthSyncState> emit,
  ) async {
    if (state is! HealthSyncData) return;
    final currentState = state as HealthSyncData;

    emit(HealthSyncLoading());
    try {
      final allData = await healthService.getAllActivityData(daysBack: 7);
      final records = HealthDataTransformer.transformAllData(allData);

      if (records.isEmpty) {
        emit(currentState.copyWith(totalSynced: 0));
        return;
      }

      final token = await _getToken();
      final batch = SyncFitnessRecordsBatchDto(records: records);
      final response = await apiService.syncRecords('Bearer $token', batch);

      emit(
        currentState.copyWith(
          connected: true,
          lastSyncedAt: DateTime.now(),
          totalSynced: response.data?.created ?? 0,
        ),
      );
    } catch (e) {
      emit(HealthSyncError(e.toString()));
    }
  }

  Future<void> _onDisconnect(
    DisconnectHealthRequested event,
    Emitter<HealthSyncState> emit,
  ) async {
    emit(HealthSyncLoading());
    try {
      final token = await _getToken();
      await apiService.disconnect('Bearer $token');
      emit(const HealthSyncData(connected: false));
    } catch (e) {
      emit(HealthSyncError(e.toString()));
    }
  }
}
