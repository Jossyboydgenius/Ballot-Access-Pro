import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/utils/app_sizer.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({super.key});

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  String selectedTimeframe = 'Week';

  @override
  Widget build(BuildContext context) {
    AppDimension.init(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: AppTextStyle.bold20,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download, color: AppColors.primary),
            onPressed: () {
              // TODO: Implement export functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTimeframeSelector(),
            SizedBox(height: 24.h),
            _buildOverviewCards(),
            SizedBox(height: 24.h),
            _buildPetitionersList(),
            SizedBox(height: 24.h),
            _buildStatusBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Day', 'Week', 'Month', 'Year'].map((timeframe) {
          final isSelected = selectedTimeframe == timeframe;
          return GestureDetector(
            onTap: () => setState(() => selectedTimeframe = timeframe),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                timeframe,
                style: AppTextStyle.regular14.copyWith(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                'Total Houses',
                '1,234',
                Icons.home,
                Colors.blue,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildOverviewCard(
                'Success Rate',
                '75%',
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildOverviewCard(
                'Active Petitioners',
                '8',
                Icons.people,
                Colors.orange,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildOverviewCard(
                'Pending Houses',
                '456',
                Icons.pending_actions,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24.r),
          SizedBox(height: 12.h),
          Text(
            value,
            style: AppTextStyle.bold24,
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: AppTextStyle.regular14.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetitionersList() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Petitioners',
                style: AppTextStyle.semibold16,
              ),
              TextButton(
                onPressed: () {
                  // TODO: Navigate to detailed petitioners list
                },
                child: Text(
                  'View All',
                  style: AppTextStyle.regular14.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    'P${index + 1}',
                    style: AppTextStyle.semibold14.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
                title: Text(
                  'Petitioner ${index + 1}',
                  style: AppTextStyle.regular14,
                ),
                subtitle: Text(
                  '${150 - (index * 20)} houses visited',
                  style: AppTextStyle.regular12.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                trailing: Text(
                  '${85 - (index * 5)}%',
                  style: AppTextStyle.semibold14.copyWith(
                    color: Colors.green,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Breakdown',
            style: AppTextStyle.semibold16,
          ),
          SizedBox(height: 16.h),
          _buildStatusRow('Signed', 45, Colors.green),
          SizedBox(height: 12.h),
          _buildStatusRow('Come Back', 25, Colors.orange),
          SizedBox(height: 12.h),
          _buildStatusRow('Not Home', 20, Colors.blue),
          SizedBox(height: 12.h),
          _buildStatusRow('Not Signed', 10, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String status, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              status,
              style: AppTextStyle.regular14,
            ),
            Text(
              '$percentage%',
              style: AppTextStyle.semibold14,
            ),
          ],
        ),
        SizedBox(height: 8.h),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8.h,
          borderRadius: BorderRadius.circular(4.r),
        ),
      ],
    );
  }
}
