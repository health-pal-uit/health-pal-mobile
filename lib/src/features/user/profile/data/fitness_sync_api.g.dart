// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fitness_sync_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncFitnessRecordDto _$SyncFitnessRecordDtoFromJson(
  Map<String, dynamic> json,
) => SyncFitnessRecordDto(
  source: json['source'] as String,
  record_type: json['record_type'] as String,
  external_record_id: json['external_record_id'] as String,
  exercise_type: json['exercise_type'] as String?,
  start_time: json['start_time'] as String?,
  end_time: json['end_time'] as String?,
  recorded_at: json['recorded_at'] as String?,
  duration_minutes: (json['duration_minutes'] as num?)?.toInt(),
  steps_count: (json['steps_count'] as num?)?.toInt(),
  distance_meters: (json['distance_meters'] as num?)?.toInt(),
  active_calories_kcal: (json['active_calories_kcal'] as num?)?.toDouble(),
  avg_heart_rate_bpm: (json['avg_heart_rate_bpm'] as num?)?.toInt(),
  intensity_level: (json['intensity_level'] as num?)?.toInt(),
  device_id: json['device_id'] as String?,
  timezone: json['timezone'] as String?,
);

Map<String, dynamic> _$SyncFitnessRecordDtoToJson(
  SyncFitnessRecordDto instance,
) => <String, dynamic>{
  'source': instance.source,
  'record_type': instance.record_type,
  'external_record_id': instance.external_record_id,
  'exercise_type': instance.exercise_type,
  'start_time': instance.start_time,
  'end_time': instance.end_time,
  'recorded_at': instance.recorded_at,
  'duration_minutes': instance.duration_minutes,
  'steps_count': instance.steps_count,
  'distance_meters': instance.distance_meters,
  'active_calories_kcal': instance.active_calories_kcal,
  'avg_heart_rate_bpm': instance.avg_heart_rate_bpm,
  'intensity_level': instance.intensity_level,
  'device_id': instance.device_id,
  'timezone': instance.timezone,
};

SyncFitnessRecordsBatchDto _$SyncFitnessRecordsBatchDtoFromJson(
  Map<String, dynamic> json,
) => SyncFitnessRecordsBatchDto(
  records:
      (json['records'] as List<dynamic>)
          .map((e) => SyncFitnessRecordDto.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$SyncFitnessRecordsBatchDtoToJson(
  SyncFitnessRecordsBatchDto instance,
) => <String, dynamic>{'records': instance.records};

SyncResponseDto _$SyncResponseDtoFromJson(Map<String, dynamic> json) =>
    SyncResponseDto(
      total: (json['total'] as num).toInt(),
      created: (json['created'] as num).toInt(),
      skipped: (json['skipped'] as num).toInt(),
      results:
          (json['results'] as List<dynamic>)
              .map((e) => SyncResultDto.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$SyncResponseDtoToJson(SyncResponseDto instance) =>
    <String, dynamic>{
      'total': instance.total,
      'created': instance.created,
      'skipped': instance.skipped,
      'results': instance.results,
    };

SyncResultDto _$SyncResultDtoFromJson(Map<String, dynamic> json) =>
    SyncResultDto(
      status: json['status'] as String,
      reason: json['reason'] as String?,
      source: json['source'] as String,
      record_type: json['record_type'] as String,
      external_record_id: json['external_record_id'] as String,
      activity_record_id: json['activity_record_id'] as String?,
    );

Map<String, dynamic> _$SyncResultDtoToJson(SyncResultDto instance) =>
    <String, dynamic>{
      'status': instance.status,
      'reason': instance.reason,
      'source': instance.source,
      'record_type': instance.record_type,
      'external_record_id': instance.external_record_id,
      'activity_record_id': instance.activity_record_id,
    };

ConnectData _$ConnectDataFromJson(Map<String, dynamic> json) => ConnectData(
  success: json['success'] as bool?,
  connected: json['connected'] as bool?,
);

Map<String, dynamic> _$ConnectDataToJson(ConnectData instance) =>
    <String, dynamic>{
      'success': instance.success,
      'connected': instance.connected,
    };

ConnectResponse _$ConnectResponseFromJson(Map<String, dynamic> json) =>
    ConnectResponse(
      data:
          json['data'] == null
              ? null
              : ConnectData.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ConnectResponseToJson(ConnectResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'message': instance.message,
      'statusCode': instance.statusCode,
    };

StatusData _$StatusDataFromJson(Map<String, dynamic> json) => StatusData(
  connected: json['connected'] as bool?,
  last_synced_at: json['last_synced_at'] as String?,
);

Map<String, dynamic> _$StatusDataToJson(StatusData instance) =>
    <String, dynamic>{
      'connected': instance.connected,
      'last_synced_at': instance.last_synced_at,
    };

StatusResponse _$StatusResponseFromJson(Map<String, dynamic> json) =>
    StatusResponse(
      data:
          json['data'] == null
              ? null
              : StatusData.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StatusResponseToJson(StatusResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'message': instance.message,
      'statusCode': instance.statusCode,
    };

SyncWrapperResponse _$SyncWrapperResponseFromJson(Map<String, dynamic> json) =>
    SyncWrapperResponse(
      data:
          json['data'] == null
              ? null
              : SyncResponseDto.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
      statusCode: (json['statusCode'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SyncWrapperResponseToJson(
  SyncWrapperResponse instance,
) => <String, dynamic>{
  'data': instance.data,
  'message': instance.message,
  'statusCode': instance.statusCode,
};

// dart format off

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers,unused_element,unnecessary_string_interpolations,unused_element_parameter,avoid_unused_constructor_parameters,unreachable_from_main,avoid_redundant_argument_values

class _FitnessSyncApi implements FitnessSyncApi {
  _FitnessSyncApi(this._dio, {this.baseUrl, this.errorLogger});

  final Dio _dio;

  String? baseUrl;

  final ParseErrorLogger? errorLogger;

  @override
  Future<ConnectResponse> connect(String token) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ConnectResponse>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/fitness-sync/connect',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ConnectResponse _value;
    try {
      _value = ConnectResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<StatusResponse> getStatus(String token) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<StatusResponse>(
      Options(method: 'GET', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/fitness-sync/status',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late StatusResponse _value;
    try {
      _value = StatusResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<ConnectResponse> disconnect(String token) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    const Map<String, dynamic>? _data = null;
    final _options = _setStreamType<ConnectResponse>(
      Options(method: 'DELETE', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/fitness-sync/disconnect',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late ConnectResponse _value;
    try {
      _value = ConnectResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  @override
  Future<SyncWrapperResponse> syncRecords(
    String token,
    SyncFitnessRecordsBatchDto batch,
  ) async {
    final _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'Authorization': token};
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    _data.addAll(batch.toJson());
    final _options = _setStreamType<SyncWrapperResponse>(
      Options(method: 'POST', headers: _headers, extra: _extra)
          .compose(
            _dio.options,
            '/fitness-sync/sync',
            queryParameters: queryParameters,
            data: _data,
          )
          .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
    );
    final _result = await _dio.fetch<Map<String, dynamic>>(_options);
    late SyncWrapperResponse _value;
    try {
      _value = SyncWrapperResponse.fromJson(_result.data!);
    } on Object catch (e, s) {
      errorLogger?.logError(e, s, _options, response: _result);
      rethrow;
    }
    return _value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}

// dart format on
