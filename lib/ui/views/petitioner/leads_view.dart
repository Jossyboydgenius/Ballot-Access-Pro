import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ballot_access_pro/models/lead.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/widgets/app_input.dart';
import 'package:ballot_access_pro/ui/views/petitioner/widgets/add_lead_bottom_sheet.dart';
import 'package:ballot_access_pro/shared/constants/app_spacing.dart';

class LeadsView extends StatefulWidget {
  const LeadsView({super.key});

  @override
  State<LeadsView> createState() => _LeadsViewState();
}

class _LeadsViewState extends State<LeadsView> {
  final searchController = TextEditingController();
  List<Lead> leads = [];
  List<Lead> filteredLeads = [];
  final List<String> statuses = ['Interested', 'Not Interested', 'Follow Up', 'Contacted', 'Pending'];
  final List<Color> statusColors = [Colors.green, Colors.red, Colors.orange, Colors.blue, Colors.purple];

  @override
  void initState() {
    super.initState();
    // Add some sample leads
    _addSampleLeads();
    searchController.addListener(_filterLeads);
  }

  void _addSampleLeads() {
    // Add sample leads with random statuses
    leads = List.generate(
      5,
      (index) => Lead(
        id: 'lead_$index',
        name: 'John Doe ${index + 1}',
        address: '${123 + index} Main St, City, State',
        phoneNumber: index % 2 == 0 ? '+1234567890' : null,
        notes: 'Sample notes for lead ${index + 1}',
        status: statuses[index % statuses.length],
      ),
    );
    filteredLeads = List.from(leads);
  }

  void _filterLeads() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredLeads = leads.where((lead) {
        return lead.name.toLowerCase().contains(query) ||
            lead.address.toLowerCase().contains(query) ||
            lead.notes.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _handleAddLead(String name, String address, String? phone, String notes) {
    final newLead = Lead(
      id: 'lead_${leads.length + 1}',
      name: name,
      address: address,
      phoneNumber: phone,
      notes: notes,
      status: statuses[0], // Default to 'Interested'
    );

    setState(() {
      leads.add(newLead);
      _filterLeads();
    });
  }

  void _handleEditLead(Lead lead) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddLeadBottomSheet(
        initialName: lead.name,
        initialAddress: lead.address,
        initialPhone: lead.phoneNumber,
        initialNotes: lead.notes,
        onAddLead: (name, address, phone, notes) {
          final updatedLead = lead.copyWith(
            name: name,
            address: address,
            phoneNumber: phone,
            notes: notes,
          );

          setState(() {
            final index = leads.indexWhere((l) => l.id == lead.id);
            if (index != -1) {
              leads[index] = updatedLead;
              _filterLeads();
            }
          });
        },
        isEditing: true,
      ),
    );
  }

  Color _getStatusColor(String status) {
    final index = statuses.indexOf(status);
    return index != -1 ? statusColors[index] : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Leads',
          style: AppTextStyle.bold20,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: AppInput(
              controller: searchController,
              hintText: 'Search leads...',
              keyboardType: TextInputType.text,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: filteredLeads.length,
              itemBuilder: (context, index) {
                final lead = filteredLeads[index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16.h),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Text(
                                lead.name.split(' ').map((e) => e[0]).take(2).join(),
                                style: AppTextStyle.regular14.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            AppSpacing.h12(),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lead.name,
                                    style: AppTextStyle.semibold16,
                                  ),
                                  Text(
                                    lead.address,
                                    style: AppTextStyle.regular14,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(lead.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                lead.status,
                                style: AppTextStyle.regular12.copyWith(
                                  color: _getStatusColor(lead.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.v12(),
                        Text(
                          'Notes: ${lead.notes}',
                          style: AppTextStyle.regular14,
                        ),
                        AppSpacing.v12(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (lead.phoneNumber != null) ...[
                              TextButton.icon(
                                onPressed: () => _makePhoneCall(lead.phoneNumber!),
                                icon: const Icon(
                                  Icons.phone,
                                  color: AppColors.primary,
                                ),
                                label: Text(
                                  'Call',
                                  style: AppTextStyle.regular14.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              AppSpacing.h16(),
                            ],
                            TextButton.icon(
                              onPressed: () => _handleEditLead(lead),
                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.primary,
                              ),
                              label: Text(
                                'Edit',
                                style: AppTextStyle.regular14.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => AddLeadBottomSheet(
              onAddLead: _handleAddLead,
              isEditing: false,
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Lead',
          style: AppTextStyle.semibold16.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}