import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../models/event_model.dart';

class EventApiService {
  late final Dio _dio;

  EventApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "http://10.0.2.2:8080/api/v1",
        connectTimeout: const Duration(seconds: 8),
        receiveTimeout: const Duration(seconds: 8),
        responseType: ResponseType.json,
      ),
    );
    _dio.interceptors.add(
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
  }

  Future<List<EventModel>> getEvents({
    String? status,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final query = <String, dynamic>{};
      if (status != null && status.isNotEmpty && status != "Tất cả trạng thái") {
        query["status"] = status;
      }
      if (from != null) {
        query["from"] =
            "${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}";
      }
      if (to != null) {
        query["to"] =
            "${to.year}-${to.month.toString().padLeft(2, '0')}-${to.day.toString().padLeft(2, '0')}";
      }
      final response = await _dio.get("/events", queryParameters: query);
      final raw = response.data?["data"];
      if (raw == null || raw is! List) return [];
      return raw.map((e) => EventModel.fromJson(e)).toList();
    } on DioException catch (e) {
      final msg = e.response?.data?["error"] ?? e.message ?? "Không xác định";
      throw Exception("Lỗi tải danh sách sự kiện: $msg");
    }
  }

  Future<Map<String, dynamic>> createEventWithImages(
      EventModel event, List<File> images) async {
    try {
      final formData = FormData.fromMap({
        "name": event.name,
        "location": event.location,
        "status": event.status,
        "description": event.description ?? "",
        "max_guests": event.maxGuests ?? 0,
        "type": event.type,
        "start_date": event.startDate.toUtc().toIso8601String(),
        "end_date": event.endDate.toUtc().toIso8601String(),
        "images": [
          for (final img in images)
            await MultipartFile.fromFile(img.path, filename: path.basename(img.path))
        ],
      });

      final res = await _dio.post("/events/",
          data: formData,
          options: Options(
              responseType: ResponseType.plain, headers: {"Accept": "application/json"}));

      if (res.data is String) {
        try {
          final map = res.data.isEmpty ? <String, dynamic>{} : (jsonDecode(res.data) as Map);
          return Map<String, dynamic>.from(map);
        } catch (_) {
          return {"message": res.data};
        }
      }
      if (res.data is Map) return Map<String, dynamic>.from(res.data);
      throw Exception("Phản hồi không hợp lệ: ${res.data.runtimeType}");
    } on DioException catch (e) {
      final data = e.response?.data;
      String msg;
      if (data is String) {
        try {
          final m = jsonDecode(data);
          msg = m is Map && m["error"] != null ? m["error"].toString() : data;
        } catch (_) {
          msg = data;
        }
      } else if (data is Map && data["error"] != null) {
        msg = data["error"].toString();
      } else {
        msg = e.message ?? "Không xác định";
      }
      throw Exception("Tạo sự kiện thất bại: $msg");
    } catch (e) {
      throw Exception("Lỗi không xác định: $e");
    }
  }

  /// ✅ Cập nhật sự kiện (FIXED)
  /// Gửi đi JSON. Nếu thành công, trả về chính object event đã gửi đi.
  Future<EventModel> updateEvent(EventModel event) async {
    try {
      // Chỉ cần đợi API thực thi, không cần dùng kết quả trả về từ BE
      await _dio.put("/events/${event.id}", data: event.toJson());

      // Vì BE không trả về object đã update, FE sẽ tự trả về object đã gửi đi
      // để cập nhật state trong ứng dụng.
      return event;
    } on DioException catch (e) {
      final data = e.response?.data;
      String msg;
      if (data is Map && data["error"] != null) {
        msg = data["error"].toString();
      } else {
        msg = e.message ?? "Không xác định";
      }
      throw Exception("Cập nhật thất bại: $msg");
    }
  }

  Future<EventModel> getEventById(String id) async {
    try {
      final res = await _dio.get("/events/$id");
      final raw = res.data?['data'];
      if (raw == null) throw Exception("Không có dữ liệu");
      return EventModel.fromJson(raw);
    } on DioException catch (e) {
      final msg = e.response?.data?["error"] ?? e.message ?? "Không xác định";
      throw Exception("Lỗi tải chi tiết sự kiện: $msg");
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _dio.delete("/events/$id");
    } on DioException catch (e) {
      throw Exception("Xoá thất bại: ${e.response?.data ?? e.message}");
    }
  }

  Future<Map<String, int>> getGuestStats(String eventId) async {
    try {
      final response = await _dio.get("/analytics/events/$eventId/guests");
      final raw = response.data?['data'];
      if (raw is! Map) {
        return {};
      }
      final stats = <String, int>{};
      raw.forEach((key, value) {
        if (value is num) {
          stats[key.toString()] = value.toInt();
        }
      });
      return stats;
    } on DioException catch (e) {
      final msg = e.response?.data?["error"] ?? e.message ?? "Không xác định";
      throw Exception("Lỗi tải thống kê: $msg");
    } catch (e) {
      throw Exception("Lỗi xử lý dữ liệu thống kê: $e");
    }
  }
}
