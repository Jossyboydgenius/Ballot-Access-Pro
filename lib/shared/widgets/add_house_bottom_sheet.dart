import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/widgets/app_button.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';
import 'package:ballot_access_pro/models/territory.dart';

class AddHouseBottomSheet extends StatefulWidget {
  final String currentAddress;
  final Function(String) onStatusSelected;
  final Function(int, String) onAddHouse;
  final String selectedStatus;
  final List<Territory> territories;

  const AddHouseBottomSheet({
    super.key,
    required this.currentAddress,
    required this.onStatusSelected,
    required this.onAddHouse,
    required this.selectedStatus,
    required this.territories,
  });

  @override
  State<AddHouseBottomSheet> createState() => _AddHouseBottomSheetState();
}

class _AddHouseBottomSheetState extends State<AddHouseBottomSheet> {
  String? selectedTerritory;
  late String localSelectedStatus;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _votersController = TextEditingController();
  bool get _isFormValid => 
      localSelectedStatus.isNotEmpty && 
      selectedTerritory != null &&
      _votersController.text.isNotEmpty &&
      int.tryParse(_votersController.text) != null;

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
              'Current Location',
              style: AppTextStyle.regular14,
            ),
            AppSpacing.v8(),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primary),
                  AppSpacing.h8(),
                  Expanded(
                    child: Text(
                      widget.currentAddress,
                      style: AppTextStyle.regular14,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.v16(),
            Text(
              'Territory',
              style: AppTextStyle.regular14,
            ),
            AppSpacing.v8(),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedTerritory,
                  hint: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      'Select territory',
                      style: AppTextStyle.regular14,
                    ),
                  ),
                  isExpanded: true,
                  items: widget.territories.map((Territory territory) {
                    return DropdownMenuItem<String>(
                      value: territory.id,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text(
                          territory.name,
                          style: AppTextStyle.regular14,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedTerritory = newValue;
                    });
                  },
                ),
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
                _buildStatusChip('Partially Signed', AppColors.green.withOpacity(0.6)),
                _buildStatusChip('Come Back', Colors.blue),
                _buildStatusChip('Not Home', Colors.yellow),
                _buildStatusChip('BAS', Colors.red),
              ],
            ),
            AppSpacing.v16(),
            Text(
              'Registered Voters',
              style: AppTextStyle.regular14,
            ),
            AppSpacing.v8(),
            TextField(
              controller: _votersController,
              keyboardType: TextInputType.number,
              style: AppTextStyle.regular14,
              decoration: InputDecoration(
                hintText: '0',
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
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
            ),
            AppSpacing.v16(),
            Text(
              'Notes',
              style: AppTextStyle.regular14,
            ),
            AppSpacing.v8(),
            TextField(
              controller: _notesController,
              maxLines: 3,
              style: AppTextStyle.regular14,
              decoration: InputDecoration(
                hintText: 'Any additional information about this house',
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
                contentPadding: EdgeInsets.all(12.w),
              ),
            ),
            AppSpacing.v24(),
            AppButton(
              text: 'Add Pin',
              onPressed: _isFormValid 
                  ? () {
                      final voters = int.tryParse(_votersController.text) ?? 0;
                      widget.onAddHouse(voters, _notesController.text);
                    }
                  : null,
              style: AppTextStyle.semibold16.copyWith(
                color: _isFormValid ? Colors.white : Colors.grey[400],
              ),
              backgroundColor: _isFormValid ? AppColors.primary : Colors.grey[300],
            ),
            AppSpacing.v16(),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _votersController.addListener(() {
      setState(() {});
    });
    localSelectedStatus = widget.selectedStatus;
  }

  @override
  void dispose() {
    _notesController.dispose();
    _votersController.dispose();
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
  }
}

