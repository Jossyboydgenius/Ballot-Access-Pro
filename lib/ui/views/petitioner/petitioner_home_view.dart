import 'package:ballot_access_pro/shared/styles/app_text_style.dart';
import 'package:ballot_access_pro/ui/views/petitioner/bloc/leads_bloc.dart';
import 'package:ballot_access_pro/ui/views/petitioner/bloc/profile_bloc.dart';
import 'package:ballot_access_pro/ui/views/petitioner/bloc/profile_event.dart';
import 'package:ballot_access_pro/ui/views/petitioner/bloc/work_bloc.dart';
import 'package:ballot_access_pro/ui/views/petitioner/bloc/work_event.dart';
import 'package:flutter/material.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/utils/app_sizer.dart';
import 'package:ballot_access_pro/ui/views/petitioner/map_view.dart';
import 'package:ballot_access_pro/ui/views/petitioner/leads_view.dart';
import 'package:ballot_access_pro/ui/views/petitioner/profile_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class PetitionerHomeView extends StatefulWidget {
  const PetitionerHomeView({Key? key}) : super(key: key);

  @override
  _PetitionerHomeViewState createState() => _PetitionerHomeViewState();
}

class _PetitionerHomeViewState extends State<PetitionerHomeView> {
  int _currentIndex = 0;
  late final LeadsBloc _leadsBloc;
  late final ProfileBloc _profileBloc;
  late final WorkBloc _workBloc;

  @override
  void initState() {
    super.initState();
    _leadsBloc = LeadsBloc()..add(const LoadLeads());
    _profileBloc = GetIt.I<ProfileBloc>()..add(const LoadProfile());
    _workBloc = WorkBloc()..add(const CheckWorkSession());
  }

  @override
  void dispose() {
    _leadsBloc.close();
    _profileBloc.close();
    _workBloc.close();
    super.dispose();
  }

  // Using IndexedStack instead of switching children
  // This preserves the state of all child views
  final List<Widget> _screens = [
    const MapView(),
    const LeadsView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    AppDimension.init(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider<LeadsBloc>.value(value: _leadsBloc),
        BlocProvider<ProfileBloc>.value(value: _profileBloc),
        BlocProvider<WorkBloc>.value(value: _workBloc),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: AppTextStyle.bold14,
          unselectedLabelStyle: AppTextStyle.regular12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Leads',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
