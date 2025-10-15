import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../models/guest_model.dart';

class GuestApiService {
  final Dio _dio;

  GuestApiService({Dio? dio})
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

  Future<List<GuestModel>> getGuests({String? keyword}) async {
    try {
      final params = <String, dynamic>{};
      if (keyword != null && keyword.trim().isNotEmpty) {
        params['keyword'] = keyword.trim();
      }

      final response = await _dio.get('/guests/', queryParameters: params);
      final raw = _normalizeBody(response.data);
      final data = raw is Map<String, dynamic> ? raw['data'] : raw;
      if (data is! List) {
        return const [];
      }
      return data
          .whereType<Map>()
          .map((e) => GuestModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? e.message ?? 'Unknown';
      throw Exception('Failed to load guests: $message');
    }
  }

  Future<GuestModel> createGuest({
    required String fullName,
    String? email,
    String? phone,
    String? eventId,
  }) async {
    try {
      final response = await _dio.post(
        '/guests/',
        data: {
          'full_name': fullName,
          'email': email,
          'phone': phone,
          'event_id': eventId,
        },
      );
      final raw = _normalizeBody(response.data);
      final data = raw is Map<String, dynamic>
          ? raw['data'] as Map<String, dynamic>?
          : null;
      if (data == null) {
        throw const FormatException('Invalid response from server');
      }
      return GuestModel.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? e.message ?? 'Unknown';
      throw Exception('Failed to create guest: $message');
    }
  }

  Future<void> updateGuest(GuestModel guest) async {
    try {
      await _dio.put(
        '/guests/${guest.id}',
        data: {
          'full_name': guest.fullName,
          'email': guest.email,
          'phone': guest.phone,
        },
      );
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? e.message ?? 'Unknown';
      throw Exception('Failed to update guest: $message');
    }
  }

  Future<void> deleteGuest(String id) async {
    try {
      await _dio.delete('/guests/$id');
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? e.message ?? 'Unknown';
      throw Exception('Failed to delete guest: $message');
    }
  }

  Future<GuestModel> getGuestById(String id) async {
    try {
      final response = await _dio.get('/guests/$id');
      final raw = _normalizeBody(response.data);
      final data = raw is Map<String, dynamic>
          ? raw['data'] as Map<String, dynamic>?
          : null;
      if (data == null) {
        throw const FormatException('Invalid response from server');
      }
      return GuestModel.fromJson(data);
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? e.message ?? 'Unknown';
      throw Exception('Failed to load guest: $message');
    }
  }

  Future<GuestModel?> findGuestByContact({String? email, String? phone}) async {
    try {
      final params = <String, dynamic>{};
      if (email != null && email.trim().isNotEmpty) {
        params['email'] = email.trim();
      }
      if (phone != null && phone.trim().isNotEmpty) {
        params['phone'] = phone.trim();
      }
      if (params.isEmpty) return null;

      final response = await _dio.get(
        '/guests/search',
        queryParameters: params,
      );
      final raw = _normalizeBody(response.data);
      final data = raw is Map<String, dynamic>
          ? raw['data'] as Map<String, dynamic>?
          : null;
      if (data == null) return null;
      return GuestModel.fromJson(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      final message = e.response?.data?['error'] ?? e.message ?? 'Unknown';
      throw Exception('Failed to search guest: $message');
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
