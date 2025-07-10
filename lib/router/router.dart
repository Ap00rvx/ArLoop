import 'package:arloop/screens/onboarding/onboarding_page.dart';
import 'package:arloop/screens/splash/splash_page.dart';
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
      pageBuilder: (context, state) => const CupertinoPage(child: OnboardingPage()),
      path: '/onboarding', 
    ), 
  ],
);
