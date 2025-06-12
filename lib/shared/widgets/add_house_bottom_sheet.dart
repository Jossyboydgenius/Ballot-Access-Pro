import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/widgets/app_button.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';
import 'package:ballot_access_pro/models/territory.dart';
import 'package:ballot_access_pro/services/petitioner_service.dart';

class AddHouseBottomSheet extends StatefulWidget {
  final String currentAddress;
  final Function(String) onStatusSelected;
  final Function(int, String, String) onAddHouse;
  final String selectedStatus;
  final List<Territory> territories;
  final String? preSelectedTerritory;

  const AddHouseBottomSheet({
    super.key,
    required this.currentAddress,
    required this.onStatusSelected,
    required this.onAddHouse,
    required this.selectedStatus,
    required this.territories,
    this.preSelectedTerritory,
  });

  @override
  State<AddHouseBottomSheet> createState() => _AddHouseBottomSheetState();
}

class _AddHouseBottomSheetState extends State<AddHouseBottomSheet> {
  String? selectedTerritory;
  late String localSelectedStatus;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _votersController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = true;

  // Add validation state for notes
  bool _isNotesInvalid = false;
  bool _isAddressInvalid = false;

  bool get _isFormValid =>
      localSelectedStatus.isNotEmpty &&
      selectedTerritory != null &&
      _addressController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    localSelectedStatus = widget.selectedStatus;
    _addressController.text = widget.currentAddress;

    // If preSelectedTerritory is provided, use it immediately
    if (widget.preSelectedTerritory != null &&
        widget.preSelectedTerritory!.isNotEmpty) {
      selectedTerritory = widget.preSelectedTerritory;
      _isLoading = false;
    } else {
      // Otherwise load from the API
      _loadAssignedTerritory();
    }
  }

  // Load the petitioner's assigned territory
  Future<void> _loadAssignedTerritory() async {
    setState(() => _isLoading = true);

    try {
      final territoryId = await PetitionerService().getAssignedTerritoryId();

      if (mounted) {
        setState(() {
          // Set the territory if it exists in the territories list
          if (territoryId.isNotEmpty &&
              widget.territories.any((t) => t.id == territoryId)) {
            selectedTerritory = territoryId;
          } else if (widget.territories.isNotEmpty) {
            // Fallback to the first territory if assigned one isn't in the list
            selectedTerritory = widget.territories.first.id;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading assigned territory: $e');
      if (mounted) {
        setState(() {
          // Fallback to the first territory if there's an error
          if (widget.territories.isNotEmpty) {
            selectedTerritory = widget.territories.first.id;
          }
          _isLoading = false;
        });
      }
    }
  }

  // Add validation method for notes - changed to not show error if empty
  void _validateNotes() {
    setState(() {
      _isNotesInvalid = false;
    });
  }

  // Add validation method for address
  void _validateAddress() {
    setState(() {
      _isAddressInvalid = _addressController.text.isEmpty;
    });
  }

  Widget _buildStatusChip(String label, Color color) {
    final isSelected = localSelectedStatus == label;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            // Update local state immediately
            localSelectedStatus = isSelected ? '' : label;
          });
          // Notify parent
          widget.onStatusSelected(isSelected ? '' : label);
        },
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.r,
                height: 12.r,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: AppTextStyle.regular12.copyWith(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.r),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Pin',
              style: AppTextStyle.bold20,
            ),
            AppSpacing.v4(),
            Text(
              'Create a new house pin at the selected location.',
              style: AppTextStyle.regular14.copyWith(color: Colors.grey[600]),
            ),
            AppSpacing.v16(),
            Text(
              'Address',
              style: AppTextStyle.regular14,
            ),
            AppSpacing.v8(),
            TextField(
              controller: _addressController,
              style: AppTextStyle.regular14,
              onChanged: (_) => _validateAddress(),
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.location_on, color: AppColors.primary),
                hintText: 'Enter address',
                hintStyle: AppTextStyle.regular14,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: _isAddressInvalid ? Colors.red : Colors.grey,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: _isAddressInvalid ? Colors.red : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: _isAddressInvalid ? Colors.red : AppColors.primary,
                  ),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                errorText: _isAddressInvalid ? 'Address is required' : null,
              ),
            ),
            AppSpacing.v16(),
            Text(
              'Initial Status',
              style: AppTextStyle.regular14,
            ),
            AppSpacing.v8(),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _buildStatusChip('Signed', AppColors.green100),
                _buildStatusChip('Come Back', Colors.blue),
                _buildStatusChip('Not Home', Colors.yellow),
                _buildStatusChip('Not Signed', Colors.red),
              ],
            ),
            AppSpacing.v16(),
            Text(
              'Registered Voters (Optional)',
              style: AppTextStyle.regular14,
            ),
            AppSpacing.v8(),
            TextField(
              controller: _votersController,
              keyboardType: TextInputType.number,
              style: AppTextStyle.regular14,
              decoration: InputDecoration(
                hintText: '0 (Leave empty if unknown)',
                hintStyle: AppTextStyle.regular14,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
            ),
            AppSpacing.v16(),
            Text(
              'Notes *',
              style: AppTextStyle.regular14,
            ),
            AppSpacing.v8(),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: AppTextStyle.regular14,
              onChanged: (value) {
                _validateNotes();
              },
              decoration: InputDecoration(
                hintText: 'Optional: Add information about this house visit',
                hintStyle:
                    AppTextStyle.regular14.copyWith(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: _isNotesInvalid ? Colors.red : Colors.grey,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: _isNotesInvalid ? Colors.red : Colors.grey,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: _isNotesInvalid ? Colors.red : AppColors.primary,
                  ),
                ),
                contentPadding: EdgeInsets.all(12.w),
                errorText: _isNotesInvalid ? 'Invalid notes format' : null,
              ),
            ),
            AppSpacing.v16(),
            Text(
              'Territory',
              style: AppTextStyle.regular14,
            ),
            AppSpacing.v8(),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.map, color: AppColors.primary),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            widget.territories
                                .firstWhere(
                                  (t) => t.id == selectedTerritory,
                                  orElse: () => Territory(
                                    id: '',
                                    name: 'Unknown Territory',
                                    description: '',
                                    priority: 'low',
                                    estimatedHouses: 0,
                                    petitioners: [],
                                    status: 'inactive',
                                    progress: 0,
                                    totalHousesSigned: 0,
                                    totalHousesVisited: 0,
                                  ),
                                )
                                .name,
                            style: AppTextStyle.regular14,
                          ),
                        ),
                      ],
                    ),
                  ),
            AppSpacing.v16(),
            AppSpacing.v24(),
            AppButton(
              text: 'Add Pin',
              onPressed: _isFormValid
                  ? () {
                      final voters = int.tryParse(_votersController.text) ?? 1;
                      widget.onAddHouse(
                        voters,
                        _notesController.text,
                        selectedTerritory ?? '',
                      );
                    }
                  : null,
              style: AppTextStyle.semibold16.copyWith(
                color: _isFormValid ? Colors.white : Colors.grey[400],
              ),
              backgroundColor:
                  _isFormValid ? AppColors.primary : Colors.grey[300],
            ),
            AppSpacing.v16(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _votersController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AddHouseBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedStatus != oldWidget.selectedStatus) {
      setState(() {
        localSelectedStatus = widget.selectedStatus;
      });
    }

    // Update address if it changes
    if (widget.currentAddress != oldWidget.currentAddress &&
        _addressController.text != widget.currentAddress) {
      _addressController.text = widget.currentAddress;
    }
  }
}
