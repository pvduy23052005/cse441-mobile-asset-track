import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../engineer/screens/engineer_main_screen.dart';
import '../../operator/screens/operator_main_screen.dart';
import '../../shared_features/asset_common/asset_lookup_screen.dart';
import '../../shared_features/auth/login_portal_screen.dart';
import '../../shared_features/auth/splash_screen.dart';
import '../../shared_features/profile/profile_screen.dart';
import '../../supervisor/screens/supervisor_main_screen.dart';

enum UserRole {
  supervisor,
  engineer,
  operator,
  unknown;

  static UserRole fromString(String? role) {
    if (role == null || role.trim().isEmpty) return UserRole.unknown;
    switch (role.toLowerCase().trim()) {
      case 'supervisor':
        return UserRole.supervisor;
      case 'engineer':
        return UserRole.engineer;
      case 'operator':
        return UserRole.operator;
      default:
        return UserRole.unknown;
    }
  }
}

class AppRoutes {
  static const String home = '/';
  static const String loginPortal = '/login-portal';
  static const String supervisorMain = '/supervisor';
  static const String engineerMain = '/engineer';
  static const String operatorMain = '/operator';
  static const String assetLookup = '/asset-lookup';
  static const String profile = '/profile';

  static String getRouteForRole(String? role) {
    final userRole = UserRole.fromString(role);
    switch (userRole) {
      case UserRole.supervisor:
        return supervisorMain;
      case UserRole.engineer:
        return engineerMain;
      case UserRole.operator:
        return operatorMain;
      case UserRole.unknown:
        return loginPortal;
    }
  }
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.loginPortal,
        builder: (context, state) => const LoginPortalScreen(),
      ),
      GoRoute(
        path: AppRoutes.supervisorMain,
        builder: (context, state) => const SupervisorMainScreen(),
      ),
      GoRoute(
        path: AppRoutes.engineerMain,
        builder: (context, state) => const EngineerMainScreen(),
      ),
      GoRoute(
        path: AppRoutes.operatorMain,
        builder: (context, state) => const OperatorMainScreen(),
      ),
      GoRoute(
        path: AppRoutes.assetLookup,
        builder: (context, state) => const AssetLookupScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Không tìm thấy trang: ${state.uri}')),
    ),
  );

  static void navigateByRole(BuildContext context, String? role) {
    final targetRoute = AppRoutes.getRouteForRole(role);
    context.go(targetRoute);
  }
}
