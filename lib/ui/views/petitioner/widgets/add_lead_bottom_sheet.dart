import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/widgets/app_button.dart';
import 'package:ballot_access_pro/shared/widgets/app_input.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';

class AddLeadBottomSheet extends StatefulWidget {
  final Function(String, String, String?, String) onAddLead;
  final String? initialName;
  final String? initialAddress;
  final String? initialPhone;
  final String? initialNotes;
  final bool isEditing;

  const AddLeadBottomSheet({
    super.key,
    required this.onAddLead,
    this.initialName,
    this.initialAddress,
    this.initialPhone,
    this.initialNotes,
    this.isEditing = false,
  });

  @override
  _AddLeadBottomSheetState createState() => _AddLeadBottomSheetState();
}

class _AddLeadBottomSheetState extends State<AddLeadBottomSheet> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final notesController = TextEditingController();
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Initialize with existing values if editing
    nameController.text = widget.initialName ?? '';
    addressController.text = widget.initialAddress ?? '';
    phoneController.text = widget.initialPhone ?? '';
    notesController.text = widget.initialNotes ?? '';
    
    // Add listeners
    nameController.addListener(_validateForm);
    addressController.addListener(_validateForm);
    phoneController.addListener(_validateForm);
    notesController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      isFormValid = nameController.text.isNotEmpty &&
          addressController.text.isNotEmpty &&
          notesController.text.isNotEmpty;
    });
  }

  String? _validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!RegExp(r'^[0-9-+() ]+$').hasMatch(value)) {
        return 'Please enter only numbers and valid symbols';
      }
    }
    return null;
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
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isEditing ? 'Edit Lead' : 'Add New Lead',
              style: AppTextStyle.bold20,
            ),
            AppSpacing.v16(),
            AppInput(
              controller: nameController,
              hintText: 'Full Name',
              keyboardType: TextInputType.name,
              validator: (value) => value?.isEmpty == true ? 'Name is required' : null,
              autoValidate: true,
            ),
            AppSpacing.v16(),
            AppInput(
              controller: addressController,
              hintText: 'Address',
              keyboardType: TextInputType.streetAddress,
              validator: (value) => value?.isEmpty == true ? 'Address is required' : null,
              autoValidate: true,
            ),
            AppSpacing.v16(),
            AppInput(
              controller: phoneController,
              hintText: 'Phone Number',
              keyboardType: TextInputType.phone,
              validator: _validatePhone,
              autoValidate: true,
            ),
            AppSpacing.v16(),
            AppInput(
              controller: notesController,
              hintText: 'Notes',
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              validator: (value) => value?.isEmpty == true ? 'Notes are required' : null,
              autoValidate: true,
            ),
            AppSpacing.v24(),
            AppButton(
              text: widget.isEditing ? 'Save Changes' : 'Add Lead',
              onPressed: isFormValid
                  ? () {
                      if (_validatePhone(phoneController.text) == null) {
                        widget.onAddLead(
                          nameController.text,
                          addressController.text,
                          phoneController.text.isEmpty ? null : phoneController.text,
                          notesController.text,
                        );
                        Navigator.pop(context);
                      }
                    }
                  : null,
              style: AppTextStyle.semibold16.copyWith(color: Colors.white),
            ),
            AppSpacing.v16(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    notesController.dispose();
    super.dispose();
  }
} 