import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../models/analytics_model.dart';
import '../../models/event_model.dart';
import '../../models/event_type_guest_stat_model.dart';
import '../../models/guest_model.dart';
import '../../models/guest_model.dart';

class CacheDatabase {
  CacheDatabase._internal();

  static final CacheDatabase instance = CacheDatabase._internal();

  Database? _db;
  bool _disabled = false;

  Future<Database?> get database async {
    if (kIsWeb || _disabled) {
      return null;
    }
    if (_db != null) return _db;

    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'event_manager_cache.db');

    Database? opened;
    try {
      opened = await openDatabase(path, version: 1, onCreate: _createTables);
    } on MissingPluginException {
      try {
        sqfliteFfiInit();
        final factory = databaseFactoryFfi;
        opened = await factory.openDatabase(
          path,
          options: OpenDatabaseOptions(version: 1, onCreate: _createTables),
        );
      } catch (_) {
        _disabled = true;
        opened = null;
      }
    }

    _db = opened;
    return _db;
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events(
        id TEXT PRIMARY KEY,
        name TEXT,
        location TEXT,
        status TEXT,
        type TEXT,
        description TEXT,
        max_guests INTEGER,
        start_date TEXT,
        end_date TEXT,
        image_urls TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE guests(
        id TEXT PRIMARY KEY,
        full_name TEXT,
        email TEXT,
        phone TEXT,
        event_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE event_guest_stats(
        event_id TEXT PRIMARY KEY,
        event_name TEXT,
        location TEXT,
        total_guests INTEGER,
        checked_in INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE event_type_stats(
        event_type TEXT PRIMARY KEY,
        total_guests INTEGER,
        checked_in INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE participation_trend(
        period TEXT PRIMARY KEY,
        total_guests INTEGER,
        checked_in INTEGER
      )
    ''');
  }

  Future<void> cacheEvents(List<EventModel> events) async {
    final db = await database;
    if (db == null) return;
    await db.transaction((txn) async {
      await txn.delete('events');
      for (final event in events) {
        await txn.insert('events', {
          'id': event.id,
          'name': event.name,
          'location': event.location,
          'status': event.status,
          'type': event.type,
          'description': event.description,
          'max_guests': event.maxGuests,
          'start_date': event.startDate.toIso8601String(),
          'end_date': event.endDate.toIso8601String(),
          'image_urls': jsonEncode(event.imageUrls),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<void> cacheEvent(EventModel event) async {
    final db = await database;
    if (db == null) return;
    await db.insert('events', {
      'id': event.id,
      'name': event.name,
      'location': event.location,
      'status': event.status,
      'type': event.type,
      'description': event.description,
      'max_guests': event.maxGuests,
      'start_date': event.startDate.toIso8601String(),
      'end_date': event.endDate.toIso8601String(),
      'image_urls': jsonEncode(event.imageUrls),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> cacheGuestStats(List<EventGuestStatModel> stats) async {
    final db = await database;
    if (db == null) return;
    await db.transaction((txn) async {
      await txn.delete('event_guest_stats');
      for (final stat in stats) {
        await txn.insert('event_guest_stats', {
          'event_id': stat.eventId,
          'event_name': stat.eventName,
          'location': stat.location,
          'total_guests': stat.totalGuests,
          'checked_in': stat.checkedIn,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<void> cacheEventTypeStats(List<EventTypeGuestStatModel> stats) async {
    final db = await database;
    if (db == null) return;
    await db.transaction((txn) async {
      await txn.delete('event_type_stats');
      for (final stat in stats) {
        await txn.insert('event_type_stats', {
          'event_type': stat.eventType,
          'total_guests': stat.totalGuests,
          'checked_in': stat.checkedIn,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<void> cacheParticipationTrend(
    List<ParticipationTrendPoint> points,
  ) async {
    final db = await database;
    if (db == null) return;
    await db.transaction((txn) async {
      await txn.delete('participation_trend');
      for (final point in points) {
        await txn.insert('participation_trend', {
          'period': point.period.toIso8601String(),
          'total_guests': point.totalGuests,
          'checked_in': point.checkedIn,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<List<EventModel>> getCachedEvents() async {
    final db = await database;
    if (db == null) return const [];
    final rows = await db.query('events', orderBy: 'start_date ASC');
    return rows.map(_mapEvent).toList();
  }

  Future<EventModel?> getCachedEventById(String id) async {
    final db = await database;
    if (db == null) return null;
    final rows = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _mapEvent(rows.first);
  }

  EventModel _mapEvent(Map<String, Object?> row) {
    List<String> parseImages(String? raw) {
      if (raw == null || raw.isEmpty) return const [];
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
      return const [];
    }

    return EventModel(
      id: (row['id'] ?? '').toString(),
      name: (row['name'] ?? '').toString(),
      location: (row['location'] ?? '').toString(),
      status: (row['status'] ?? '').toString(),
      type: (row['type'] ?? '').toString(),
      description: row['description']?.toString(),
      maxGuests: row['max_guests'] as int?,
      startDate:
          DateTime.tryParse(row['start_date'] as String? ?? '') ??
          DateTime.now(),
      endDate:
          DateTime.tryParse(row['end_date'] as String? ?? '') ?? DateTime.now(),
      imageUrls: parseImages(row['image_urls'] as String?),
    );
  }

  Future<List<EventGuestStatModel>> getCachedGuestStats() async {
    final db = await database;
    if (db == null) return const [];
    final rows = await db.query('event_guest_stats');
    return rows
        .map(
          (row) => EventGuestStatModel(
            eventId: row['event_id'] as String? ?? '',
            eventName: row['event_name'] as String? ?? '',
            location: row['location'] as String?,
            totalGuests: row['total_guests'] as int? ?? 0,
            checkedIn: row['checked_in'] as int? ?? 0,
          ),
        )
        .toList();
  }

  Future<EventGuestStatModel?> getCachedGuestStatsByEvent(
    String eventId,
  ) async {
    final db = await database;
    if (db == null) return null;
    final rows = await db.query(
      'event_guest_stats',
      where: 'event_id = ?',
      whereArgs: [eventId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return EventGuestStatModel(
      eventId: row['event_id'] as String? ?? '',
      eventName: row['event_name'] as String? ?? '',
      location: row['location'] as String?,
      totalGuests: row['total_guests'] as int? ?? 0,
      checkedIn: row['checked_in'] as int? ?? 0,
    );
  }

  Future<List<EventTypeGuestStatModel>> getCachedEventTypeStats() async {
    final db = await database;
    if (db == null) return const [];
    final rows = await db.query('event_type_stats');
    return rows
        .map(
          (row) => EventTypeGuestStatModel(
            eventType: row['event_type'] as String? ?? '',
            totalGuests: row['total_guests'] as int? ?? 0,
            checkedIn: row['checked_in'] as int? ?? 0,
          ),
        )
        .toList();
  }

  Future<List<ParticipationTrendPoint>> getCachedParticipationTrend() async {
    final db = await database;
    if (db == null) return const [];
    final rows = await db.query('participation_trend', orderBy: 'period ASC');
    return rows
        .map(
          (row) => ParticipationTrendPoint(
            period:
                DateTime.tryParse(row['period'] as String? ?? '') ??
                DateTime.now(),
            totalGuests: row['total_guests'] as int? ?? 0,
            checkedIn: row['checked_in'] as int? ?? 0,
          ),
        )
        .toList();
  }

  Future<void> cacheGuests(List<GuestModel> guests) async {
    final db = await database;
    if (db == null) return;
    await db.transaction((txn) async {
      await txn.delete('guests');
      for (final guest in guests) {
        await txn.insert('guests', {
          'id': guest.id,
          'full_name': guest.fullName,
          'email': guest.email,
          'phone': guest.phone,
          'event_id': guest.eventId,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<List<GuestModel>> getCachedGuests() async {
    final db = await database;
    if (db == null) return const [];
    final rows = await db.query('guests');
    return rows
        .map(
          (row) => GuestModel(
            id: (row['id'] ?? '').toString(),
            fullName: (row['full_name'] ?? '').toString(),
            email: row['email']?.toString(),
            phone: row['phone']?.toString(),
            eventId: row['event_id']?.toString(),
          ),
        )
        .toList();
  }
}
