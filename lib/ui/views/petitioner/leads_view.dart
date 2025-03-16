import 'package:ballot_access_pro/models/lead_model.dart';
import 'package:ballot_access_pro/shared/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/shared/widgets/app_input.dart';
import 'package:ballot_access_pro/ui/views/petitioner/widgets/lead_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ballot_access_pro/ui/views/petitioner/bloc/leads_bloc.dart';

class LeadsView extends StatelessWidget {
  const LeadsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LeadsBloc()..add(const LoadLeads()),
      child: const LeadsViewContent(),
    );
  }
}

class LeadsViewContent extends StatefulWidget {
  const LeadsViewContent({super.key});

  @override
  State<LeadsViewContent> createState() => _LeadsViewContentState();
}

class _LeadsViewContentState extends State<LeadsViewContent> {
  final searchController = TextEditingController();
  List<LeadModel> filteredLeads = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Leads',
          style: AppTextStyle.bold20,
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<LeadsBloc, LeadsState>(
        listener: (context, state) {
          if (state.status == LeadsStatus.failure) {
            AppToast.showErrorToast(state.error ?? 'Failed to load leads');
          }
        },
        builder: (context, state) {
          if (state.status == LeadsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final leads = state.leads?.docs ?? [];
          
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: AppInput(
                  controller: searchController,
                  hintText: 'Search leads...',
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  onChanged: (value) => _filterLeads(value, leads),
                ),
              ),
              Expanded(
                child: filteredLeads.isEmpty && searchController.text.isEmpty
                    ? ListView.builder(
                        itemCount: leads.length,
                        itemBuilder: (context, index) {
                          return LeadCard(lead: leads[index]);
                        },
                      )
                    : filteredLeads.isEmpty
                        ? Center(
                            child: Text(
                              'No leads found',
                              style: AppTextStyle.regular16.copyWith(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredLeads.length,
                            itemBuilder: (context, index) {
                              return LeadCard(lead: filteredLeads[index]);
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _filterLeads(String query, List<LeadModel> leads) {
    setState(() {
      filteredLeads = leads.where((lead) {
        final fullName = '${lead.firstName} ${lead.lastName}'.toLowerCase();
        final searchQuery = query.toLowerCase();
        return fullName.contains(searchQuery) ||
            (lead.address?.toLowerCase().contains(searchQuery) ?? false) ||
            lead.email.toLowerCase().contains(searchQuery) ||
            lead.phone.contains(searchQuery);
      }).toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}