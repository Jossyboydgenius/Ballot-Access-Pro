import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/widgets/app_button.dart';
import 'package:ballot_access_pro/shared/widgets/app_input.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';

class AddLeadBottomSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: initialName);
    final addressController = TextEditingController(text: initialAddress);
    final phoneController = TextEditingController(text: initialPhone);
    final notesController = TextEditingController(text: initialNotes);

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
              isEditing ? 'Edit Lead' : 'Add New Lead',
              style: AppTextStyle.bold20,
            ),
            AppSpacing.v16(),
            AppInput(
              controller: nameController,
              hintText: 'Full Name',
              keyboardType: TextInputType.name,
            ),
            AppSpacing.v16(),
            AppInput(
              controller: addressController,
              hintText: 'Address',
              keyboardType: TextInputType.streetAddress,
            ),
            AppSpacing.v16(),
            AppInput(
              controller: phoneController,
              hintText: 'Phone Number',
              keyboardType: TextInputType.phone,
            ),
            AppSpacing.v16(),
            AppInput(
              controller: notesController,
              hintText: 'Notes',
              maxLines: 3,
              keyboardType: TextInputType.multiline,
            ),
            AppSpacing.v24(),
            AppButton(
              text: isEditing ? 'Save Changes' : 'Add Lead',
              onPressed: () {
                onAddLead(
                  nameController.text,
                  addressController.text,
                  phoneController.text.isEmpty ? null : phoneController.text,
                  notesController.text,
                );
                Navigator.pop(context);
              },
              style: AppTextStyle.semibold16.copyWith(color: Colors.white),
            ),
            AppSpacing.v16(),
          ],
        ),
      ),
    );
  }
} 