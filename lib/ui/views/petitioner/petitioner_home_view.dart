import 'package:flutter/material.dart';
import 'package:ballot_access_pro/shared/constants/app_colors.dart';
import 'package:ballot_access_pro/shared/utils/app_sizer.dart';
import 'package:ballot_access_pro/ui/views/petitioner/map_view.dart';
import 'package:ballot_access_pro/ui/views/petitioner/leads_view.dart';
import 'package:ballot_access_pro/ui/views/petitioner/profile_view.dart';

class PetitionerHomeView extends StatefulWidget {
  const PetitionerHomeView({super.key});

  @override
  State<PetitionerHomeView> createState() => _PetitionerHomeViewState();
}

class _PetitionerHomeViewState extends State<PetitionerHomeView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MapView(),
    const LeadsView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    AppDimension.init(context);
    
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Leads',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
} 