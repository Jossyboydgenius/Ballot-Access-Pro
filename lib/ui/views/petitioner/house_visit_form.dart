import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/styles/app_text_style.dart';
import '../../../shared/constants/app_colors.dart';
import '../../../models/petitioner_model.dart';
import '../../../services/petitioner_service.dart';
import '../../../core/locator.dart';

class HouseVisitForm extends StatefulWidget {
  const HouseVisitForm({super.key});

  @override
  State<HouseVisitForm> createState() => _HouseVisitFormState();
}

class _HouseVisitFormState extends State<HouseVisitForm> {
  final _formKey = GlobalKey<FormState>();
  final _petitionerService = locator<PetitionerService>();

  Territory? _assignedTerritory;
  String _territoryName = 'Loading territory...';
  bool _isLoading = true;
  int? _numberOfVoters; // Optional field for number of voters

  @override
  void initState() {
    super.initState();
    _loadTerritoryData();
  }

  Future<void> _loadTerritoryData() async {
    setState(() => _isLoading = true);

    try {
      final territory = await _petitionerService.getAssignedTerritory();

      setState(() {
        _assignedTerritory = territory;
        _territoryName = territory?.name ?? 'No Territory Assigned';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _territoryName = 'Failed to load territory';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Territory field (non-editable)
          Text(
            'Territory',
            style: AppTextStyle.semibold16,
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                if (_isLoading)
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else
                  const Icon(Icons.map, color: AppColors.primary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    _territoryName,
                    style: AppTextStyle.regular14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Number of Voters field (optional)
          Text(
            'Number of Voters (Optional)',
            style: AppTextStyle.semibold16,
          ),
          SizedBox(height: 8.h),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter number of voters',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                _numberOfVoters = int.tryParse(value);
              } else {
                _numberOfVoters = null;
              }
            },
          ),

          // Add other form fields as needed
        ],
      ),
    );
  }
}
