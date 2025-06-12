import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ballot_access_pro/models/territory_houses.dart';
import 'package:ballot_access_pro/services/map_service.dart';
import 'package:ballot_access_pro/services/territory_service.dart';
import 'package:ballot_access_pro/services/petitioner_service.dart';
import 'package:ballot_access_pro/shared/widgets/add_house_bottom_sheet.dart';
import 'package:ballot_access_pro/ui/widgets/map/house_details_bottom_sheet.dart';
import 'package:ballot_access_pro/ui/widgets/map/filtered_houses_bottom_sheet.dart';
import 'package:ballot_access_pro/ui/widgets/map/update_house_status_bottom_sheet.dart';

class BottomSheetController {
  // The selected status filter
  String selectedStatus = '';

  // Function to refresh houses after an update
  final Future<void> Function() refreshHouses;

  BottomSheetController({required this.refreshHouses});

  void showHouseDetails(BuildContext context, HouseVisit house) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.95,
      ),
      builder: (context) => HouseDetailsBottomSheet(
        house: house,
        onUpdateTap: (selectedHouse) =>
            showUpdateHouseStatus(context, selectedHouse),
      ),
    );
  }

  void showUpdateHouseStatus(BuildContext context, HouseVisit house) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpdateHouseStatusBottomSheet(
        house: house,
        onUpdateStatus: (status, leadData) {
          // Store local reference to context
          final scaffoldMessenger = ScaffoldMessenger.of(context);
          final currentContext = context;

          // Execute the update asynchronously after the bottom sheet is closed
          Future.microtask(() async {
            // Show loading indicator if still mounted
            if (Navigator.canPop(currentContext)) {
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('Updating house status...')),
              );
            }

            // Call the offline-first API to update the status
            final success = await MapService.updateHouseStatusOfflineFirst(
              markerId: house.id,
              status: status,
              lead: leadData,
            );

            // Check if context is still valid
            if (currentContext.mounted) {
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(
                    leadData != null
                        ? 'Pin Status Updated and Lead Created'
                        : 'Pin Status Updated',
                  ),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );

              // Only refresh houses if successful
              if (success) {
                await refreshHouses();
              }
            }
          });
        },
      ),
    );
  }

  void showFilteredHousesBottomSheet(BuildContext context, String status,
      List<HouseVisit> houses, Function(HouseVisit) onViewHouse) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => FilteredHousesBottomSheet(
        status: status,
        houses: houses,
        onViewHouse: onViewHouse,
      ),
    );
  }

  Future<void> handleMapLongPress(BuildContext context, LatLng position) async {
    // Provide immediate haptic feedback - use heavy impact for better feedback
    HapticFeedback.heavyImpact();

    // Store a local reference to the context for later use
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show loading indicator immediately
    scaffoldMessenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 8),
            Text('Getting address...'),
          ],
        ),
        duration: Duration(seconds: 10), // Longer duration to ensure it shows
      ),
    );

    try {
      // Start the async operations in parallel
      final territoriesFuture = TerritoryService.getTerritories();
      final assignedTerritoryFuture =
          PetitionerService().getAssignedTerritoryId();
      final addressFuture = MapService.getAddressFromCoordinates(
          position.latitude, position.longitude);

      // Wait for all futures to complete
      final territories = await territoriesFuture;
      final assignedTerritoryId = await assignedTerritoryFuture;
      final address = await addressFuture;

      // Find the assigned territory from the list
      final assignedTerritory = territories.isNotEmpty
          ? territories.firstWhere(
              (territory) => territory.id == assignedTerritoryId,
              orElse: () => territories.first,
            )
          : null;

      // Hide the snackbar once we have the data
      scaffoldMessenger.hideCurrentSnackBar();

      if (context.mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: true,
          enableDrag: true,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.95,
          ),
          builder: (context) => AddHouseBottomSheet(
            currentAddress: address,
            onStatusSelected: (status) {
              // This is just for the bottom sheet internal state
            },
            selectedStatus: '',
            territories: territories,
            preSelectedTerritory:
                assignedTerritory?.id, // Fixed null-aware operator
            onAddHouse: (registeredVoters, notes, territory) {
              addHouse(
                context: context,
                position: position,
                address: address,
                territory: territory,
                registeredVoters: registeredVoters,
                notes: notes,
              );
            },
          ),
        );
      }
    } catch (e) {
      // Hide the loading indicator if there's an error
      scaffoldMessenger.hideCurrentSnackBar();
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void addHouse({
    required BuildContext context,
    required LatLng position,
    required String address,
    required String territory,
    required int registeredVoters,
    required String notes,
  }) {
    // Store local reference to context and navigator
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Show loading indicator
    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Adding house visit...')),
    );

    // Close the bottom sheet immediately
    navigator.pop();

    // Add the house visit using offline-first approach
    MapService.addHouseVisitOfflineFirst(
      lat: position.latitude,
      long: position.longitude,
      address: address,
      territory: territory,
      status: selectedStatus.isEmpty
          ? 'Signed'
          : selectedStatus, // Default to Signed
      registeredVoters: registeredVoters,
      note: notes,
    ).then((success) {
      if (success && context.mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('House visit added successfully')),
        );

        // Refresh houses
        refreshHouses();
      } else if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Failed to add house visit')),
        );
      }
    });
  }
}
