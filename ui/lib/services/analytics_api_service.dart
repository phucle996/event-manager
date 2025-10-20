import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../models/event_type_guest_stat_model.dart';
import '../models/analytics_model.dart';

class AnalyticsApiService {
  final Dio _dio;

  AnalyticsApiService({Dio? dio})
    : _dio =
          dio ??
                Dio(
                  BaseOptions(
                    baseUrl: 'http://10.0.2.2:8080/api/v1',
                    connectTimeout: const Duration(seconds: 8),
                    receiveTimeout: const Duration(seconds: 8),
                    responseType: ResponseType.json,
                  ),
                )
            ..interceptors.add(
              PrettyDioLogger(
                requestHeader: true,
                requestBody: true,
                responseHeader: false,
                responseBody: true,
                error: true,
                compact: true,
                maxWidth: 90,
              ),
            );

  Future<List<EventGuestStatModel>> getGuestStatsByEvent() async {
    try {
      final response = await _dio.get('/analytics/events');
      final raw = _normalizeBody(response.data);
      final data = raw is Map<String, dynamic> ? raw['data'] : raw;
      if (data is! List) {
        return const [];
      }
      return data
          .whereType<Map>()
          .map(
            (e) => EventGuestStatModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? e.message ?? 'Unknown';
      throw Exception('Failed to load guest stats by event: $message');
    }
  }

  Future<List<EventTypeGuestStatModel>> getGuestStatsByEventType() async {
    try {
      final response = await _dio.get('/analytics/event-types');
      final raw = _normalizeBody(response.data);
      final data = raw is Map<String, dynamic> ? raw['data'] : raw;
      if (data is! List) {
        return const [];
      }
      return data
          .whereType<Map>()
          .map(
            (e) =>
                EventTypeGuestStatModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? e.message ?? 'Unknown';
      throw Exception('Failed to load event type stats: $message');
    }
  }

  Future<List<ParticipationTrendPoint>> getParticipationTrend({
    DateTime? from,
    DateTime? to,
    String granularity = 'month',
  }) async {
    try {
      final query = <String, dynamic>{'granularity': granularity};
      if (from != null) {
        query['from'] = from.toUtc().toIso8601String();
      }
      if (to != null) {
        query['to'] = to.toUtc().toIso8601String();
      }

      final response = await _dio.get(
        '/analytics/participation',
        queryParameters: query,
      );

      final raw = _normalizeBody(response.data);
      final data = raw is Map<String, dynamic> ? raw['data'] : raw;
      if (data is! List) {
        return const [];
      }

      return data
          .whereType<Map>()
          .map(
            (e) =>
                ParticipationTrendPoint.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? e.message ?? 'Unknown';
      throw Exception('Failed to load participation trend: $message');
    }
  }

  dynamic _normalizeBody(dynamic body) {
    if (body is String) {
      if (body.isEmpty) return {};
      return jsonDecode(body);
    }
    return body;
  }
}
