import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ballot_access_pro/models/territory_houses.dart';
import 'package:ballot_access_pro/models/lead_model.dart';

class DatabaseService {
  static Database? _database;
  static const String _databaseName = 'ballot_access_pro.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _housesTable = 'houses';
  static const String _leadsTable = 'leads';
  static const String _syncOperationsTable = 'sync_operations';
  static const String _territoriesTable = 'territories';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_housesTable(
        id TEXT PRIMARY KEY,
        petitioner_id TEXT,
        petitioner_first_name TEXT,
        petitioner_last_name TEXT,
        territory TEXT,
        status TEXT,
        status_color TEXT,
        address TEXT,
        notes TEXT,
        registered_voters INTEGER,
        longitude REAL,
        latitude REAL,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0,
        needs_sync INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $_leadsTable(
        id TEXT PRIMARY KEY,
        address TEXT,
        first_name TEXT,
        last_name TEXT,
        email TEXT,
        phone TEXT,
        note TEXT,
        petitioner_id TEXT,
        petitioner_first_name TEXT,
        petitioner_last_name TEXT,
        petitioner_email TEXT,
        petitioner_country TEXT,
        petitioner_address TEXT,
        petitioner_picture TEXT,
        petitioner_phone TEXT,
        created_at TEXT,
        updated_at TEXT,
        visit_id TEXT,
        visit_status TEXT,
        visit_long REAL,
        visit_lat REAL,
        is_synced INTEGER DEFAULT 0,
        needs_sync INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $_syncOperationsTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation_type TEXT,
        table_name TEXT,
        record_id TEXT,
        data TEXT,
        created_at TEXT,
        retry_count INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $_territoriesTable(
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        priority TEXT,
        estimated_houses INTEGER,
        petitioners TEXT,
        boundary_type TEXT,
        boundary_label TEXT,
        boundary_paths TEXT,
        status TEXT,
        progress INTEGER,
        total_houses_signed INTEGER,
        total_houses_visited INTEGER,
        created_at TEXT,
        updated_at TEXT,
        is_synced INTEGER DEFAULT 0
      )
    ''');

    debugPrint('Database tables created successfully');
  }

  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades if needed
    debugPrint('Database upgraded from version $oldVersion to $newVersion');
  }

  // House operations
  static Future<int> insertHouse(HouseVisit house) async {
    final db = await database;

    final data = {
      'id': house.id,
      'petitioner_id': house.petitioner.id,
      'petitioner_first_name': house.petitioner.firstName,
      'petitioner_last_name': house.petitioner.lastName,
      'territory': house.territory,
      'status': house.status,
      'status_color': house.statusColor,
      'address': house.address,
      'notes': house.notes,
      'registered_voters': house.registeredVoters,
      'longitude': house.long,
      'latitude': house.lat,
      'created_at': house.createdAt.toIso8601String(),
      'updated_at': house.updatedAt.toIso8601String(),
      'is_synced': 1,
      'needs_sync': 0,
    };

    return await db.insert(
      _housesTable,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<HouseVisit>> getAllHouses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_housesTable);

    return List.generate(maps.length, (i) {
      try {
        return HouseVisit(
          id: maps[i]['id'] ?? '',
          petitioner: Petitioner(
            id: maps[i]['petitioner_id'] ?? '',
            firstName: maps[i]['petitioner_first_name'] ?? '',
            lastName: maps[i]['petitioner_last_name'] ?? '',
          ),
          territory: maps[i]['territory'] ?? '',
          status: maps[i]['status'] ?? '',
          statusColor: maps[i]['status_color'] ?? '',
          address: maps[i]['address'] ?? '',
          notes: maps[i]['notes'] ?? '',
          registeredVoters: maps[i]['registered_voters'] ?? 0,
          long: maps[i]['longitude'] ?? 0.0,
          lat: maps[i]['latitude'] ?? 0.0,
          createdAt:
              DateTime.tryParse(maps[i]['created_at'] ?? '') ?? DateTime.now(),
          updatedAt:
              DateTime.tryParse(maps[i]['updated_at'] ?? '') ?? DateTime.now(),
        );
      } catch (e) {
        debugPrint('Error parsing house from database: $e');
        // Return a placeholder house visit in case of error
        return HouseVisit(
          id: 'error_${DateTime.now().millisecondsSinceEpoch}',
          petitioner:
              Petitioner(id: '', firstName: 'Error', lastName: 'Loading'),
          territory: '',
          status: 'error',
          statusColor: 'red',
          address: 'Error loading address',
          notes: '',
          registeredVoters: 0,
          long: 0.0,
          lat: 0.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }
    });
  }

  // Alias for consistency with HouseRepository
  static Future<List<HouseVisit>> getHouses() async {
    return await getAllHouses();
  }

  static Future<int> updateHouse(HouseVisit house,
      {bool needsSync = true}) async {
    final db = await database;

    final data = {
      'petitioner_id': house.petitioner.id,
      'petitioner_first_name': house.petitioner.firstName,
      'petitioner_last_name': house.petitioner.lastName,
      'territory': house.territory,
      'status': house.status,
      'status_color': house.statusColor,
      'address': house.address,
      'notes': house.notes,
      'registered_voters': house.registeredVoters,
      'longitude': house.long,
      'latitude': house.lat,
      'updated_at': DateTime.now().toIso8601String(),
      'needs_sync': needsSync ? 1 : 0,
    };

    return await db.update(
      _housesTable,
      data,
      where: 'id = ?',
      whereArgs: [house.id],
    );
  }

  static Future<int> insertNewHouse(Map<String, dynamic> houseData) async {
    final db = await database;

    // Generate a temporary ID for offline operations
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final data = {
      'id': tempId,
      ...houseData,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
      'needs_sync': 1,
    };

    // Also add to sync operations
    await addSyncOperation(
      operationType: 'CREATE',
      tableName: _housesTable,
      recordId: tempId,
      data: jsonEncode(houseData),
    );

    return await db.insert(_housesTable, data);
  }

  // Lead operations
  static Future<int> insertLead(LeadModel lead) async {
    final db = await database;

    final data = {
      'id': lead.id,
      'address': lead.address,
      'first_name': lead.firstName,
      'last_name': lead.lastName,
      'email': lead.email,
      'phone': lead.phone,
      'note': lead.note,
      'petitioner_id': lead.petitioner.id,
      'petitioner_first_name': lead.petitioner.firstName,
      'petitioner_last_name': lead.petitioner.lastName,
      'petitioner_email': lead.petitioner.email,
      'petitioner_country': lead.petitioner.country,
      'petitioner_address': lead.petitioner.address,
      'petitioner_picture': lead.petitioner.picture,
      'petitioner_phone': lead.petitioner.phone,
      'created_at': lead.createdAt.toIso8601String(),
      'updated_at': lead.updatedAt.toIso8601String(),
      'visit_id': lead.visit?.id,
      'visit_status': lead.visit?.status,
      'visit_long': lead.visit?.long,
      'visit_lat': lead.visit?.lat,
      'is_synced': 1,
      'needs_sync': 0,
    };

    return await db.insert(
      _leadsTable,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<LeadModel>> getAllLeads() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_leadsTable);

    return List.generate(maps.length, (i) {
      return LeadModel(
        id: maps[i]['id'],
        address: maps[i]['address'],
        firstName: maps[i]['first_name'],
        lastName: maps[i]['last_name'],
        email: maps[i]['email'],
        phone: maps[i]['phone'],
        note: maps[i]['note'],
        petitioner: LeadPetitioner(
          id: maps[i]['petitioner_id'],
          firstName: maps[i]['petitioner_first_name'],
          lastName: maps[i]['petitioner_last_name'],
          email: maps[i]['petitioner_email'],
          country: maps[i]['petitioner_country'],
          address: maps[i]['petitioner_address'],
          picture: maps[i]['petitioner_picture'],
          phone: maps[i]['petitioner_phone'],
        ),
        createdAt: DateTime.parse(maps[i]['created_at']),
        updatedAt: DateTime.parse(maps[i]['updated_at']),
        visit: maps[i]['visit_id'] != null
            ? LeadVisit(
                id: maps[i]['visit_id'],
                status: maps[i]['visit_status'],
                long: maps[i]['visit_long'],
                lat: maps[i]['visit_lat'],
              )
            : null,
      );
    });
  }

  static Future<int> insertNewLead(Map<String, dynamic> leadData) async {
    final db = await database;

    // Generate a temporary ID for offline operations
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final data = {
      'id': tempId,
      ...leadData,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'is_synced': 0,
      'needs_sync': 1,
    };

    // Also add to sync operations
    await addSyncOperation(
      operationType: 'CREATE',
      tableName: _leadsTable,
      recordId: tempId,
      data: jsonEncode(leadData),
    );

    return await db.insert(_leadsTable, data);
  }

  // Sync operations
  static Future<int> addSyncOperation({
    required String operationType,
    required String tableName,
    required String recordId,
    required String data,
  }) async {
    final db = await database;

    return await db.insert(_syncOperationsTable, {
      'operation_type': operationType,
      'table_name': tableName,
      'record_id': recordId,
      'data': data,
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
    });
  }

  static Future<List<Map<String, dynamic>>> getPendingSyncOperations() async {
    final db = await database;
    return await db.query(
      _syncOperationsTable,
      orderBy: 'created_at ASC',
    );
  }

  static Future<int> deleteSyncOperation(int id) async {
    final db = await database;
    return await db.delete(
      _syncOperationsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> updateSyncOperationRetryCount(
      int id, int retryCount) async {
    final db = await database;
    return await db.update(
      _syncOperationsTable,
      {'retry_count': retryCount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Territory operations
  static Future<int> insertTerritory(Map<String, dynamic> territory) async {
    final db = await database;
    return await db.insert(
      _territoriesTable,
      territory,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getAllTerritories() async {
    final db = await database;
    return await db.query(_territoriesTable);
  }

  // Utility methods
  static Future<void> clearAllData() async {
    final db = await database;
    await db.delete(_housesTable);
    await db.delete(_leadsTable);
    await db.delete(_syncOperationsTable);
    await db.delete(_territoriesTable);
    debugPrint('All local data cleared');
  }

  static Future<void> markRecordAsSynced(
      String tableName, String recordId) async {
    final db = await database;
    await db.update(
      tableName,
      {'is_synced': 1, 'needs_sync': 0},
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }

  static Future<List<Map<String, dynamic>>> getUnsyncedRecords(
      String tableName) async {
    final db = await database;
    return await db.query(
      tableName,
      where: 'needs_sync = ?',
      whereArgs: [1],
    );
  }

  static Future<int> getRecordCount(String tableName) async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Get count of pending sync operations
  static Future<int> getPendingSyncOperationsCount() async {
    final db = await database;
    final result = await db
        .rawQuery('SELECT COUNT(*) as count FROM $_syncOperationsTable');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Clear all houses
  static Future<void> clearHouses() async {
    final db = await database;
    await db.delete(_housesTable);
    debugPrint('All houses cleared from local database');
  }

  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
