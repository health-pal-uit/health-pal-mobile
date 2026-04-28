// ignore_for_file: non_constant_identifier_names
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';

part 'fitness_sync_api.g.dart';

// DTOs
@JsonSerializable()
class SyncFitnessRecordDto {
  final String source; // "health_connect"
  final String record_type; // "steps", "exercise_session", "heart_rate", etc.
  final String external_record_id;

  final String? exercise_type;
  final String? start_time;
  final String? end_time;
  final String? recorded_at;

  final int? duration_minutes;
  final int? steps_count;
  final int? distance_meters;
  final double? active_calories_kcal;
  final int? avg_heart_rate_bpm;
  final int? intensity_level;

  final String? device_id;
  final String? timezone;

  SyncFitnessRecordDto({
    required this.source,
    required this.record_type,
    required this.external_record_id,
    this.exercise_type,
    this.start_time,
    this.end_time,
    this.recorded_at,
    this.duration_minutes,
    this.steps_count,
    this.distance_meters,
    this.active_calories_kcal,
    this.avg_heart_rate_bpm,
    this.intensity_level,
    this.device_id,
    this.timezone,
  });

  factory SyncFitnessRecordDto.fromJson(Map<String, dynamic> json) =>
      _$SyncFitnessRecordDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SyncFitnessRecordDtoToJson(this);
}

@JsonSerializable()
class SyncFitnessRecordsBatchDto {
  final List<SyncFitnessRecordDto> records;

  SyncFitnessRecordsBatchDto({required this.records});

  factory SyncFitnessRecordsBatchDto.fromJson(Map<String, dynamic> json) =>
      _$SyncFitnessRecordsBatchDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SyncFitnessRecordsBatchDtoToJson(this);
}

@JsonSerializable()
class SyncResponseDto {
  final int total;
  final int created;
  final int skipped;
  final List<SyncResultDto> results;

  SyncResponseDto({
    required this.total,
    required this.created,
    required this.skipped,
    required this.results,
  });

  factory SyncResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SyncResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SyncResponseDtoToJson(this);
}

@JsonSerializable()
class SyncResultDto {
  final String status; // "created" | "skipped"
  final String? reason;
  final String source;
  final String record_type;
  final String external_record_id;
  final String? activity_record_id;

  SyncResultDto({
    required this.status,
    this.reason,
    required this.source,
    required this.record_type,
    required this.external_record_id,
    this.activity_record_id,
  });

  factory SyncResultDto.fromJson(Map<String, dynamic> json) =>
      _$SyncResultDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SyncResultDtoToJson(this);
}

@JsonSerializable()
class ConnectData {
  final bool? success;
  final bool? connected;

  ConnectData({this.success, this.connected});
  factory ConnectData.fromJson(Map<String, dynamic> json) =>
      _$ConnectDataFromJson(json);
  Map<String, dynamic> toJson() => _$ConnectDataToJson(this);
}

@JsonSerializable()
class ConnectResponse {
  final ConnectData? data; // 👈 Hộp chứa data
  final String? message;
  final int? statusCode;

  ConnectResponse({this.data, this.message, this.statusCode});
  factory ConnectResponse.fromJson(Map<String, dynamic> json) =>
      _$ConnectResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ConnectResponseToJson(this);
}

@JsonSerializable()
class StatusData {
  final bool? connected;
  final String? last_synced_at;

  StatusData({this.connected, this.last_synced_at});
  factory StatusData.fromJson(Map<String, dynamic> json) =>
      _$StatusDataFromJson(json);
  Map<String, dynamic> toJson() => _$StatusDataToJson(this);
}

@JsonSerializable()
class StatusResponse {
  final StatusData? data; // 👈 Hộp chứa data
  final String? message;
  final int? statusCode;

  StatusResponse({this.data, this.message, this.statusCode});
  factory StatusResponse.fromJson(Map<String, dynamic> json) =>
      _$StatusResponseFromJson(json);
  Map<String, dynamic> toJson() => _$StatusResponseToJson(this);
}

@JsonSerializable()
class SyncWrapperResponse {
  final SyncResponseDto? data;
  final String? message;
  final int? statusCode;

  SyncWrapperResponse({this.data, this.message, this.statusCode});
  factory SyncWrapperResponse.fromJson(Map<String, dynamic> json) =>
      _$SyncWrapperResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SyncWrapperResponseToJson(this);
}

// API Service
@RestApi(baseUrl: "http://10.0.2.2:3001") // Dùng IP máy ảo Android
abstract class FitnessSyncApi {
  factory FitnessSyncApi(Dio dio, {String? baseUrl}) = _FitnessSyncApi;

  @POST('/fitness-sync/connect')
  Future<ConnectResponse> connect(@Header('Authorization') String token);

  @GET('/fitness-sync/status')
  Future<StatusResponse> getStatus(@Header('Authorization') String token);

  @DELETE('/fitness-sync/disconnect')
  Future<ConnectResponse> disconnect(@Header('Authorization') String token);

  @POST('/fitness-sync/sync')
  Future<SyncWrapperResponse> syncRecords(
    @Header('Authorization') String token,
    @Body() SyncFitnessRecordsBatchDto batch,
  );
}
