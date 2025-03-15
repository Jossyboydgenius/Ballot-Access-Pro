import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ballot_access_pro/models/lead.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/widgets/app_input.dart';
import 'package:ballot_access_pro/ui/views/petitioner/widgets/add_lead_bottom_sheet.dart';
import 'package:ballot_access_pro/ui/views/petitioner/widgets/lead_card.dart';
import 'dart:math';

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

  // Add this list of sample names
  final List<String> sampleNames = [
    'Emma Thompson',
    'James Wilson',
    'Sophia Garcia',
    'Michael Chen',
    'Isabella Martinez',
    'William Taylor',
    'Olivia Johnson',
    'Alexander Lee',
    'Ava Rodriguez',
    'Daniel Kim'
  ];

  final List<String> sampleStreets = [
    'Maple Avenue',
    'Oak Street',
    'Cedar Lane',
    'Pine Road',
    'Elm Boulevard',
    'Birch Drive',
    'Willow Way',
    'Spruce Court',
    'Ash Street',
    'Sycamore Lane'
  ];

  @override
  void initState() {
    super.initState();
    // Add some sample leads
    _addSampleLeads();
    searchController.addListener(_filterLeads);
  }

  void _addSampleLeads() {
    final random = Random();
    
    leads = List.generate(
      10,
      (index) {
        final randomName = sampleNames[random.nextInt(sampleNames.length)];
        final randomStreet = sampleStreets[random.nextInt(sampleStreets.length)];
        final houseNumber = random.nextInt(999) + 1;
        
        return Lead(
          id: 'lead_$index',
          name: randomName,
          address: '$houseNumber $randomStreet, City, State',
          phoneNumber: random.nextBool() ? '+1${random.nextInt(999999999) + 1000000000}' : null,
          notes: 'Sample notes for $randomName',
          status: statuses[random.nextInt(statuses.length)],
        );
      },
    );
    filteredLeads = List.from(leads);
  }

  void _filterLeads() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredLeads = leads.where((lead) {
        return lead.name.toLowerCase().contains(query) ||
            lead.address.toLowerCase().contains(query) ||
            (lead.notes?.toLowerCase().contains(query) ?? false);
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
            child: _buildLeadsList(),
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

  Widget _buildLeadsList() {
    if (filteredLeads.isEmpty) {
      return Center(
        child: Text(
          'No leads found',
          style: AppTextStyle.regular16.copyWith(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredLeads.length,
      itemBuilder: (context, index) {
        final lead = filteredLeads[index];
        return LeadCard(
          name: lead.name,
          address: lead.address,
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}