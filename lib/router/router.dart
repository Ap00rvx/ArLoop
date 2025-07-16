import 'package:arloop/screens/auth/login_page.dart';
import 'package:arloop/screens/auth/register_page.dart';
import 'package:arloop/screens/home/home_page.dart';
import 'package:arloop/screens/onboarding/onboarding_page.dart';
import 'package:arloop/screens/splash/splash_page.dart';
import 'package:arloop/screens/vendor/home/vendor_home.dart';
import 'package:arloop/screens/vendor/onboarding/vendor_onboarding_page.dart';
import 'package:arloop/screens/vendor/auth/vendor_auth_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

/// Router configuration for the ArLoop application
/// Handles navigation between different screens
/// Uses GoRouter for declarative routing
/// Provides named routes for easy navigation

final GoRouter appRouter = GoRouter(
  initialLocation: "/",
  routes: [
    GoRoute(
      name: RouteNames.splash,
      pageBuilder: (context, state) => const CupertinoPage(child: SplashPage()),
      path: '/',
    ),
    GoRoute(
      name: RouteNames.onboarding,
      pageBuilder: (context, state) =>
          const CupertinoPage(child: OnboardingPage()),
      path: '/onboarding',
    ),
    GoRoute(
      name: RouteNames.register,
      pageBuilder: (context, state) =>
          const CupertinoPage(child: RegisterPage()),
      path: '/register',
    ),
    GoRoute(
      name: RouteNames.login,
      pageBuilder: (context, state) => const CupertinoPage(child: LoginPage()),
      path: '/login',
    ),
    GoRoute(
      name: RouteNames.home,
      pageBuilder: (context, state) => const CupertinoPage(child: HomePage()),
      path: '/home',
    ),

    // Vendor routes
    GoRoute(
      name: RouteNames.vendorOnboarding,
      pageBuilder: (context, state) =>
          const CupertinoPage(child: VendorOnboardingPage()),
      path: '/vendor-onboarding',
    ),
    GoRoute(
      name: RouteNames.vendorAuth,
      pageBuilder: (context, state) =>
          const CupertinoPage(child: VendorAuthPage()),
      path: '/vendor-auth',
    ),
     GoRoute(
      name: RouteNames.vendorHome,
      pageBuilder: (context, state) =>
          const CupertinoPage(child: VendorHome()),
      path: '/vendor/home',
    ),
  ],
);
