import 'package:arloop/router/route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../bloc/auth/authentication_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _hasInitialized = false;
  bool _navigationCompleted = false;

  @override
  void initState() {
    super.initState();

    // Set status bar to transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Scale animation
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Start animations
    _animationController.forward();

    // Initialize authentication
    _initializeAuthentication();
  }

  void _initializeAuthentication() {
    // Trigger authentication initialization
    context.read<AuthenticationBloc>().add(InitialAuthenticationEvent());

    // Set minimum splash duration of 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_navigationCompleted) {
        _hasInitialized = true;
        _handleNavigation();
      }
    });
  }

  void _handleNavigation() {
    if (_navigationCompleted) return;

    final authState = context.read<AuthenticationBloc>().state;

    if (authState.isAuthenticated) {
      // User is authenticated, go to home
      _navigateToHome();
    } else if (authState.isUnauthenticated) {
      // User is not authenticated, go to onboarding
      _navigateToOnboarding();
    } else if (authState.isFailure) {
      // Authentication failed, go to onboarding
      _navigateToOnboarding();
    }
    // If still loading, wait for state change
  }

  void _navigateToHome() {
    if (mounted && !_navigationCompleted) {
      _navigationCompleted = true;
      context.go('/home');
    }
  }

  void _navigateToOnboarding() {
    if (mounted && !_navigationCompleted) {
      _navigationCompleted = true;
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          // Handle authentication state changes
          if (_hasInitialized && !_navigationCompleted) {
            if (state.isAuthenticated) {
              _navigateToHome();
            } else if (state.isUnauthenticated || state.isFailure) {
              _navigateToOnboarding();
            }
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Image Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Image.asset(
                      'assets/images/Argyaloop Logo.png',
                      fit: BoxFit.fitHeight,
                      height: 100,
                      // width: 300,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.medical_services,
                          size: 60,
                          color: AppColors.textOnPrimary,
                        );
                      },
                                        ),)
                ),

                const SizedBox(height: 40),

                // App Name Section
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                   
                      Text(
                        'Your Health Companion',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Loading Section with Authentication Status
                BlocBuilder<AuthenticationBloc, AuthenticationState>(
                  builder: (context, state) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.textOnPrimary,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getLoadingMessage(state),
                            style: const TextStyle(
                              color: AppColors.textOnPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLoadingMessage(AuthenticationState state) {
    if (state.isLoading) {
      return 'Authenticating...';
    } else if (state.isAuthenticated) {
      return 'Welcome back!';
    } else if (state.isUnauthenticated) {
      return 'Loading...';
    } else if (state.isFailure) {
      return 'Loading...';
    } else {
      return 'Loading...';
    }
  }
}
