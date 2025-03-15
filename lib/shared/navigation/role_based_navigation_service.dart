// import 'package:flutter/material.dart';
// import 'package:ballot_access_pro/shared/navigation/app_routes.dart';
// import 'package:ballot_access_pro/shared/navigation/navigation_service.dart';

// class RoleBasedNavigationService {
//   static final GlobalKey<NavigatorState> _navigatorKey = NavigationService.navigatorKey;

//   // Navigate to the appropriate home screen based on user role
//   static void navigateToRoleBasedHome(String role) {
//     final String route = AppRoutes.getHomeRouteForRole(role);
//     _navigatorKey.currentState?.pushReplacementNamed(route);
//   }

//   // Check if the current route is accessible for the given role
//   static bool isRouteAccessibleForRole(String route, String role) {
//     if (role.toLowerCase() == 'admin') {
//       return true; // Admin has access to all routes
//     }

//     // Petitioner route restrictions
//     if (role.toLowerCase() == 'petitioner') {
//       return !route.startsWith('/admin'); // Petitioners can't access admin routes
//     }

//     return false; // Unknown role has no access
//   }

//   // Handle unauthorized access attempts
//   static void handleUnauthorizedAccess(BuildContext context) {
//     NavigationService.pushReplacementNamed(AppRoutes.signInView);
//     // TODO: Show unauthorized access message
//   }

//   // Navigate back to role-specific home
//   static void navigateToRoleHome(String role) {
//     final String route = AppRoutes.getHomeRouteForRole(role);
//     NavigationService.pushReplacementNamed(route);
//   }
// } 