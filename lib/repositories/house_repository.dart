import 'package:ballot_access_pro/core/locator.dart';
import 'package:ballot_access_pro/models/territory_houses.dart';
import 'package:ballot_access_pro/services/database_service.dart';
import 'package:ballot_access_pro/services/sync_service.dart';
import 'package:ballot_access_pro/services/map_service.dart';
import 'package:flutter/foundation.dart';

class HouseRepository {
  final SyncService _syncService = locator<SyncService>();

  /// Get houses with offline-first approach
  Future<TerritoryHouses?> getHouses() async {
    try {
      // First try to get from local database
      final localHouses = await DatabaseService.getHouses();

      // If we have cached data and are offline, return local data
      if (localHouses.isNotEmpty && !await _syncService.isConnected()) {
        debugPrint(
            'HouseRepository: Returning ${localHouses.length} cached houses (offline)');
        return _convertToTerritoryHouses(localHouses);
      }

      // If we're online, try to fetch fresh data
      if (await _syncService.isConnected()) {
        try {
          final freshHouses = await MapService.getHousesForTerritory();
          if (freshHouses != null) {
            // Cache the fresh data
            await _cacheHouses(freshHouses.docs);
            debugPrint(
                'HouseRepository: Fetched ${freshHouses.docs.length} fresh houses');
            return freshHouses;
          }
        } catch (e) {
          debugPrint('HouseRepository: Failed to fetch fresh data: $e');
          // Fall back to cached data if available
          if (localHouses.isNotEmpty) {
            debugPrint(
                'HouseRepository: Falling back to ${localHouses.length} cached houses');
            return _convertToTerritoryHouses(localHouses);
          }
        }
      }

      // Return cached data if available
      if (localHouses.isNotEmpty) {
        return _convertToTerritoryHouses(localHouses);
      }

      return null;
    } catch (e) {
      debugPrint('HouseRepository: Error getting houses: $e');
      return null;
    }
  }

  /// Add a house visit with offline support
  Future<bool> addHouseVisit({
    required double lat,
    required double long,
    required String address,
    required String territory,
    required String status,
    required int registeredVoters,
    required String note,
  }) async {
    try {
      // If online, try to add directly to server
      if (await _syncService.isConnected()) {
        final success = await MapService.addHouseVisit(
          lat: lat,
          long: long,
          address: address,
          territory: territory,
          status: status,
          registeredVoters: registeredVoters,
          note: note,
        );

        if (success) {
          debugPrint('HouseRepository: Successfully added house visit online');
          return true;
        }
      }

      // If offline or online request failed, queue for sync
      await _syncService.queueHouseOperation({
        'operation': 'create',
        'lat': lat,
        'long': long,
        'address': address,
        'territory': territory,
        'status': status,
        'registeredVoters': registeredVoters,
        'note': note,
      });

      debugPrint('HouseRepository: Queued house visit for sync');
      return true;
    } catch (e) {
      debugPrint('HouseRepository: Error adding house visit: $e');
      return false;
    }
  }

  /// Update a house visit with offline support
  Future<bool> updateHouseStatus({
    required String houseId,
    required String status,
    String? note,
  }) async {
    try {
      // If online, try to update directly on server
      if (await _syncService.isConnected()) {
        // Note: You'll need to implement updateHouseStatus in MapService
        // For now, we'll just queue the operation
      }

      // Queue for sync (both online and offline)
      await _syncService.queueHouseOperation({
        'operation': 'update',
        'houseId': houseId,
        'status': status,
        if (note != null) 'note': note,
      });

      // Update local cache if exists - we'll need to implement a separate method
      // for updating by ID with a map of values
      // For now, skip local cache update since we need the full HouseVisit object

      debugPrint('HouseRepository: Queued house status update for sync');
      return true;
    } catch (e) {
      debugPrint('HouseRepository: Error updating house status: $e');
      return false;
    }
  }

  /// Cache houses from server response
  Future<void> _cacheHouses(List<HouseVisit> houses) async {
    try {
      for (final house in houses) {
        await DatabaseService.insertHouse(house);
      }
    } catch (e) {
      debugPrint('HouseRepository: Error caching houses: $e');
    }
  }

  /// Convert database houses to TerritoryHouses format
  TerritoryHouses _convertToTerritoryHouses(List<HouseVisit> houses) {
    return TerritoryHouses(
      docs: houses,
      totalDocs: houses.length,
      limit: houses.length,
      totalPages: 1,
      page: 1,
      pagingCounter: 1,
      hasPrevPage: false,
      hasNextPage: false,
      prevPage: null,
      nextPage: null,
    );
  }

  /// Get sync status for houses
  Future<Map<String, dynamic>> getSyncStatus() async {
    final pendingCount = await DatabaseService.getPendingSyncOperationsCount();
    final isConnected = await _syncService.isConnected();
    final lastSyncTime = await _syncService.getLastSyncTime();

    return {
      'pendingOperations': pendingCount,
      'isConnected': isConnected,
      'lastSyncTime': lastSyncTime,
    };
  }

  /// Trigger manual sync
  Future<bool> syncNow() async {
    try {
      return await _syncService.syncNow();
    } catch (e) {
      debugPrint('HouseRepository: Error during manual sync: $e');
      return false;
    }
  }

  /// Refresh data from server
  Future<bool> refreshFromServer() async {
    try {
      if (!await _syncService.isConnected()) {
        return false;
      }

      final freshHouses = await MapService.getHousesForTerritory();
      if (freshHouses != null) {
        // Clear existing cache and insert fresh data
        await DatabaseService.clearHouses();
        await _cacheHouses(freshHouses.docs);
        debugPrint(
            'HouseRepository: Refreshed ${freshHouses.docs.length} houses from server');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('HouseRepository: Error refreshing from server: $e');
      return false;
    }
  }
}
