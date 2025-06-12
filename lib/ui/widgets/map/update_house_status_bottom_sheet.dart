import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/widgets/app_button.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/models/territory_houses.dart';

class UpdateHouseStatusBottomSheet extends StatefulWidget {
  final HouseVisit house;
  final Function(String status, Map<String, String>? leadData) onUpdateStatus;

  const UpdateHouseStatusBottomSheet({
    Key? key,
    required this.house,
    required this.onUpdateStatus,
  }) : super(key: key);

  @override
  State<UpdateHouseStatusBottomSheet> createState() =>
      _UpdateHouseStatusBottomSheetState();
}

class _UpdateHouseStatusBottomSheetState
    extends State<UpdateHouseStatusBottomSheet> {
  String selectedStatus = '';
  bool addLead = false;

  // Controllers for lead information
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Form validation state
  bool _isFirstNameInvalid = false;
  bool _isLastNameInvalid = false;
  bool _isEmailInvalid = false;
  bool _isFormValid = false;

  // API requires specific status values
  final Map<String, String> statusMappings = {
    'signed': 'signed',
    'comeback': 'comeback',
    'nothome': 'notHome',
    'not-signed': 'not-signed',
  };

  @override
  void initState() {
    super.initState();
    // Set initial status to current house status - ensure it matches API format
    selectedStatus = _getCorrectStatusFormat(widget.house.status);

    // Add form field value change listeners
    _firstNameController.addListener(_validateForm);
    _lastNameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);

    // Initial validation
    _validateForm();
  }

  @override
  void dispose() {
    // Clean up controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Convert UI-friendly status to API-required format
  String _getCorrectStatusFormat(String status) {
    final normalized = status.toLowerCase();

    if (normalized == 'not home' || normalized == 'nothome') {
      return 'notHome';
    } else if (normalized == 'come back' || normalized == 'comeback') {
      return 'comeback';
    } else if (normalized == 'not signed' || normalized == 'not-signed') {
      return 'not-signed';
    } else if (normalized == 'signed') {
      return 'signed';
    }

    // Default return original if no match
    return normalized;
  }

  // Create display-friendly status format
  String _getDisplayStatusFormat(String apiStatus) {
    if (apiStatus == 'notHome') return 'Not Home';
    if (apiStatus == 'not-signed') return 'Not Signed';
    if (apiStatus == 'comeback') return 'Come Back';
    return apiStatus.substring(0, 1).toUpperCase() +
        apiStatus.substring(1); // Capitalize first letter
  }

  void _validateForm() {
    if (!mounted) return;

    // Only show validation errors for fields that have been edited
    _isFirstNameInvalid = addLead &&
        _firstNameController.text.isNotEmpty &&
        _firstNameController.text.length < 2;

    _isLastNameInvalid = addLead &&
        _lastNameController.text.isNotEmpty &&
        _lastNameController.text.length < 2;

    _isEmailInvalid = addLead &&
        _emailController.text.isNotEmpty &&
        !_isValidEmail(_emailController.text);

    // Determine overall form validity
    final bool formValid = selectedStatus.isNotEmpty &&
        (!addLead ||
            (_firstNameController.text.length >= 2 &&
                _lastNameController.text.length >= 2 &&
                (_emailController.text.isEmpty ||
                    _isValidEmail(_emailController.text))));

    // Only update state if validity changed to minimize rebuilds
    if (_isFormValid != formValid) {
      setState(() {
        _isFormValid = formValid;
      });
    }
  }

  bool _isValidEmail(String email) {
    // Simple email validation regex
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  Widget _buildStatusChip(
      String apiStatusValue, String displayLabel, Color color) {
    final isSelected =
        selectedStatus.toLowerCase() == apiStatusValue.toLowerCase();

    return InkWell(
      onTap: () {
        setState(() {
          selectedStatus = apiStatusValue;
          _validateForm();
        });
      },
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
              displayLabel,
              style: AppTextStyle.regular12.copyWith(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, String>? _getLeadData() {
    if (!addLead) return null;

    Map<String, String> leadData = {
      "firstName": _firstNameController.text,
      "lastName": _lastNameController.text,
    };

    if (_emailController.text.isNotEmpty) {
      leadData["email"] = _emailController.text;
    }

    if (_phoneController.text.isNotEmpty) {
      leadData["phone"] = _phoneController.text;
    }

    return leadData;
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
            // Drag handle indicator
            Center(
              child: Container(
                width: 40.w,
                height: 5.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5.r),
                ),
              ),
            ),

            // Title
            Text(
              'Update House Status',
              style: AppTextStyle.bold20,
            ),

            // Current address
            AppSpacing.v8(),
            Text(
              widget.house.address,
              style: AppTextStyle.regular14.copyWith(color: Colors.grey[600]),
            ),

            // Status selection
            AppSpacing.v16(),
            Text(
              'Update Status',
              style: AppTextStyle.semibold16,
            ),
            AppSpacing.v12(),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _buildStatusChip('signed', 'Signed', AppColors.green100),
                _buildStatusChip('comeback', 'Come Back', Colors.blue),
                _buildStatusChip('notHome', 'Not Home', Colors.yellow),
                _buildStatusChip('not-signed', 'Not Signed', Colors.red),
              ],
            ),

            // Add Lead section
            AppSpacing.v24(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Add Lead Information',
                    style: AppTextStyle.semibold16,
                  ),
                ),
                Switch(
                  value: addLead,
                  onChanged: (value) {
                    setState(() {
                      addLead = value;
                      // Reset validations when toggling
                      _isFirstNameInvalid = false;
                      _isLastNameInvalid = false;
                      _isEmailInvalid = false;
                    });
                    // Force validation update after state changes
                    Future.microtask(() => _validateForm());
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),

            // Lead form fields (conditionally visible)
            if (addLead) ...[
              AppSpacing.v16(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'First Name*',
                        errorText:
                            _isFirstNameInvalid ? 'Min 2 characters' : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color:
                                _isFirstNameInvalid ? Colors.red : Colors.grey,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color:
                                _isFirstNameInvalid ? Colors.red : Colors.grey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: _isFirstNameInvalid
                                ? Colors.red
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _isFirstNameInvalid =
                              value.isNotEmpty && value.length < 2;
                        });
                        _validateForm();
                      },
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name*',
                        errorText:
                            _isLastNameInvalid ? 'Min 2 characters' : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color:
                                _isLastNameInvalid ? Colors.red : Colors.grey,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color:
                                _isLastNameInvalid ? Colors.red : Colors.grey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: _isLastNameInvalid
                                ? Colors.red
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _isLastNameInvalid =
                              value.isNotEmpty && value.length < 2;
                        });
                        _validateForm();
                      },
                    ),
                  ),
                ],
              ),
              AppSpacing.v12(),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: _isEmailInvalid ? 'Invalid email format' : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: _isEmailInvalid ? Colors.red : Colors.grey,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: _isEmailInvalid ? Colors.red : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: _isEmailInvalid ? Colors.red : AppColors.primary,
                    ),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    _isEmailInvalid = value.isNotEmpty && !_isValidEmail(value);
                  });
                  _validateForm();
                },
              ),
              AppSpacing.v12(),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],

            // Update button
            AppSpacing.v24(),
            AppButton(
              text: 'Save Changes',
              onPressed: _isFormValid
                  ? () {
                      // Store values locally before widget is disposed
                      final String status = selectedStatus;
                      final Map<String, String>? leadData = _getLeadData();
                      final Function(String, Map<String, String>?)
                          onUpdateStatus = widget.onUpdateStatus;

                      // Log what we're sending for debugging purposes
                      debugPrint(
                          'Sending status update: status=$status, lead=$leadData');

                      // Close the bottom sheet first
                      Navigator.of(context).pop();

                      // Then process the update with stored values (without any widget dependencies)
                      onUpdateStatus(status, leadData);
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
}
