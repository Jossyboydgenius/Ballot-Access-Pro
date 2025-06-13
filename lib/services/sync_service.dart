import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ballot_access_pro/services/database_service.dart';
import 'package:ballot_access_pro/services/petitioner_service.dart';
import 'package:ballot_access_pro/services/map_service.dart';
import 'package:ballot_access_pro/core/locator.dart';

enum SyncStatus {
  idle,
  syncing,
  success,
  error,
}

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final PetitionerService _petitionerService = locator<PetitionerService>();

  // Stream controllers for sync status
  final _syncStatusController = StreamController<SyncStatus>.broadcast();
  final _syncProgressController = StreamController<double>.broadcast();
  final _syncMessageController = StreamController<String>.broadcast();

  Stream<SyncStatus> get syncStatus => _syncStatusController.stream;
  Stream<double> get syncProgress => _syncProgressController.stream;
  Stream<String> get syncMessage => _syncMessageController.stream;

  bool _isSyncing = false;
  Timer? _autoSyncTimer;

  // Initialize auto-sync when connectivity is restored
  void initialize() {
    Connectivity().onConnectivityChanged.listen(_onConnectivityChanged);
    _startAutoSyncTimer();
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    if (result != ConnectivityResult.none && !_isSyncing) {
      debugPrint('SyncService: Connectivity restored, starting auto-sync');
      autoSync();
    }
  }

  void _startAutoSyncTimer() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (!_isSyncing) {
        autoSync();
      }
    });
  }

  Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Alias for consistency across the codebase
  Future<bool> isConnected() async {
    return await isOnline();
  }

  Future<void> autoSync() async {
    if (_isSyncing || !await isOnline()) return;

    debugPrint('SyncService: Starting auto-sync');
    await sync(showProgress: false);
  }

  Future<bool> sync({bool showProgress = true}) async {
    if (_isSyncing) {
      debugPrint('SyncService: Sync already in progress');
      return false;
    }

    if (!await isOnline()) {
      debugPrint('SyncService: No internet connection');
      _syncStatusController.add(SyncStatus.error);
      _syncMessageController.add('No internet connection');
      return false;
    }

    _isSyncing = true;
    _syncStatusController.add(SyncStatus.syncing);

    try {
      if (showProgress) {
        _syncProgressController.add(0.0);
        _syncMessageController.add('Starting sync...');
      }

      // Step 1: Upload pending operations (25%)
      await _uploadPendingOperations();
      if (showProgress) {
        _syncProgressController.add(0.25);
        _syncMessageController.add('Uploading local changes...');
      }

      // Step 2: Download fresh data from server (75%)
      await _downloadFreshData();
      if (showProgress) {
        _syncProgressController.add(0.75);
        _syncMessageController.add('Downloading latest data...');
      }

      // Step 3: Complete sync (100%)
      if (showProgress) {
        _syncProgressController.add(1.0);
        _syncMessageController.add('Sync completed successfully');
      }

      _syncStatusController.add(SyncStatus.success);
      debugPrint('SyncService: Sync completed successfully');
      return true;
    } catch (e) {
      debugPrint('SyncService: Sync failed: $e');
      _syncStatusController.add(SyncStatus.error);
      _syncMessageController.add('Sync failed: ${e.toString()}');
      return false;
    } finally {
      _isSyncing = false;
      _syncStatusController.add(SyncStatus.idle);
    }
  }

  Future<void> _uploadPendingOperations() async {
    debugPrint('SyncService: Uploading pending operations');

    final pendingOperations = await DatabaseService.getPendingSyncOperations();

    for (final operation in pendingOperations) {
      try {
        final success = await _processSyncOperation(operation);

        if (success) {
          await DatabaseService.deleteSyncOperation(operation['id']);

          // Mark the record as synced
          await DatabaseService.markRecordAsSynced(
            operation['table_name'],
            operation['record_id'],
          );
        } else {
          // Increment retry count
          final retryCount = operation['retry_count'] + 1;
          await DatabaseService.updateSyncOperationRetryCount(
            operation['id'],
            retryCount,
          );

          // Remove operation if retry count exceeds limit
          if (retryCount >= 3) {
            await DatabaseService.deleteSyncOperation(operation['id']);
            debugPrint(
                'SyncService: Removed operation after 3 failed attempts');
          }
        }
      } catch (e) {
        debugPrint('SyncService: Error processing operation: $e');
      }
    }
  }

  Future<bool> _processSyncOperation(Map<String, dynamic> operation) async {
    final operationType = operation['operation_type'];
    final tableName = operation['table_name'];
    final data = jsonDecode(operation['data']);

    try {
      switch (operationType) {
        case 'CREATE':
          if (tableName == 'houses') {
            return await _createHouseOnServer(data);
          } else if (tableName == 'leads') {
            return await _createLeadOnServer(data);
          }
          break;
        case 'UPDATE':
          if (tableName == 'houses') {
            return await _updateHouseOnServer(operation['record_id'], data);
          }
          break;
      }
    } catch (e) {
      debugPrint('SyncService: Error in _processSyncOperation: $e');
      return false;
    }

    return false;
  }

  Future<bool> _createHouseOnServer(Map<String, dynamic> data) async {
    try {
      final success = await MapService.addHouseVisit(
        lat: data['latitude'],
        long: data['longitude'],
        address: data['address'],
        territory: data['territory'],
        status: data['status'],
        registeredVoters: data['registered_voters'],
        note: data['notes'] ?? '',
      );
      return success;
    } catch (e) {
      debugPrint('SyncService: Error creating house on server: $e');
      return false;
    }
  }

  Future<bool> _createLeadOnServer(Map<String, dynamic> data) async {
    try {
      // Implement lead creation API call here
      // This would need to be added to your API service
      debugPrint('SyncService: Creating lead on server: $data');
      return true; // Placeholder
    } catch (e) {
      debugPrint('SyncService: Error creating lead on server: $e');
      return false;
    }
  }

  Future<bool> _updateHouseOnServer(
      String recordId, Map<String, dynamic> data) async {
    try {
      final success = await MapService.updateHouseStatus(
        markerId: recordId,
        status: data['status'],
        lead: data['lead_data'] != null ? jsonDecode(data['lead_data']) : null,
      );
      return success;
    } catch (e) {
      debugPrint('SyncService: Error updating house on server: $e');
      return false;
    }
  }

  Future<void> _downloadFreshData() async {
    debugPrint('SyncService: Downloading fresh data from server');

    try {
      // Download houses
      final houses = await MapService.getHousesForTerritory();
      if (houses != null) {
        // Clear existing houses that are synced
        final db = await DatabaseService.database;
        await db.delete('houses', where: 'is_synced = ?', whereArgs: [1]);

        // Insert fresh data
        for (final house in houses.docs) {
          await DatabaseService.insertHouse(house);
        }
        debugPrint('SyncService: Downloaded ${houses.docs.length} houses');
      }

      // Download leads
      final leadsResponse = await _petitionerService.getLeads();
      if (leadsResponse.status && leadsResponse.data != null) {
        // Clear existing leads that are synced
        final db = await DatabaseService.database;
        await db.delete('leads', where: 'is_synced = ?', whereArgs: [1]);

        // Insert fresh data
        for (final lead in leadsResponse.data!.docs) {
          await DatabaseService.insertLead(lead);
        }
        debugPrint(
            'SyncService: Downloaded ${leadsResponse.data!.docs.length} leads');
      }
    } catch (e) {
      debugPrint('SyncService: Error downloading fresh data: $e');
      rethrow;
    }
  }

  Future<void> refreshData() async {
    if (!await isOnline()) {
      debugPrint('SyncService: No internet connection for refresh');
      throw Exception('No internet connection');
    }

    _syncStatusController.add(SyncStatus.syncing);
    _syncMessageController.add('Refreshing data...');

    try {
      await _downloadFreshData();
      _syncStatusController.add(SyncStatus.success);
      _syncMessageController.add('Data refreshed successfully');
    } catch (e) {
      _syncStatusController.add(SyncStatus.error);
      _syncMessageController.add('Refresh failed: ${e.toString()}');
      rethrow;
    } finally {
      _syncStatusController.add(SyncStatus.idle);
    }
  }

  // Offline operations
  Future<void> addHouseOffline(Map<String, dynamic> houseData) async {
    await DatabaseService.insertNewHouse(houseData);
    debugPrint('SyncService: Added house offline, will sync when online');
  }

  Future<void> updateHouseOffline(
      String houseId, Map<String, dynamic> updates) async {
    final db = await DatabaseService.database;

    // Update the house record
    await db.update(
      'houses',
      {
        ...updates,
        'updated_at': DateTime.now().toIso8601String(),
        'needs_sync': 1,
      },
      where: 'id = ?',
      whereArgs: [houseId],
    );

    // Add sync operation
    await DatabaseService.addSyncOperation(
      operationType: 'UPDATE',
      tableName: 'houses',
      recordId: houseId,
      data: jsonEncode(updates),
    );

    debugPrint('SyncService: Updated house offline, will sync when online');
  }

  Future<void> addLeadOffline(Map<String, dynamic> leadData) async {
    await DatabaseService.insertNewLead(leadData);
    debugPrint('SyncService: Added lead offline, will sync when online');
  }

  // Get sync statistics
  Future<Map<String, int>> getSyncStats() async {
    final pendingOperations = await DatabaseService.getPendingSyncOperations();
    final unsyncedHouses = await DatabaseService.getUnsyncedRecords('houses');
    final unsyncedLeads = await DatabaseService.getUnsyncedRecords('leads');

    return {
      'pendingOperations': pendingOperations.length,
      'unsyncedHouses': unsyncedHouses.length,
      'unsyncedLeads': unsyncedLeads.length,
      'totalHouses': await DatabaseService.getRecordCount('houses'),
      'totalLeads': await DatabaseService.getRecordCount('leads'),
    };
  }

  // Get last sync time from shared preferences or database
  Future<DateTime?> getLastSyncTime() async {
    try {
      // For now, return null - you might want to store this in SharedPreferences
      // or add a sync_metadata table to track sync times
      return null;
    } catch (e) {
      debugPrint('SyncService: Error getting last sync time: $e');
      return null;
    }
  }

  // Manually trigger sync
  Future<bool> syncNow() async {
    return await sync(showProgress: true);
  }

  // Queue a house operation for later sync
  Future<void> queueHouseOperation(Map<String, dynamic> operation) async {
    try {
      String operationType;
      String recordId;
      Map<String, dynamic> data;

      if (operation['operation'] == 'create') {
        operationType = 'CREATE';
        recordId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
        data = {
          'latitude': operation['lat'],
          'longitude': operation['long'],
          'address': operation['address'],
          'territory': operation['territory'],
          'status': operation['status'],
          'registered_voters': operation['registeredVoters'],
          'notes': operation['note'],
        };
      } else if (operation['operation'] == 'update') {
        operationType = 'UPDATE';
        recordId = operation['houseId'];
        data = {
          'status': operation['status'],
          if (operation['note'] != null) 'notes': operation['note'],
        };
      } else {
        throw Exception('Unknown operation type: ${operation['operation']}');
      }

      await DatabaseService.addSyncOperation(
        operationType: operationType,
        tableName: 'houses',
        recordId: recordId,
        data: jsonEncode(data),
      );

      debugPrint(
          'SyncService: Queued $operationType operation for house $recordId');
    } catch (e) {
      debugPrint('SyncService: Error queueing house operation: $e');
      rethrow;
    }
  }

  void dispose() {
    _autoSyncTimer?.cancel();
    _syncStatusController.close();
    _syncProgressController.close();
    _syncMessageController.close();
  }
}
