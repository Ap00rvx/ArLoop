import 'package:arloop/router/route_names.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
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

  void _handleNavigation() async {
    if (_navigationCompleted) return;

    final authState = context.read<AuthenticationBloc>().state;

    if (authState.isAuthenticated) {
      // User is authenticated, check role and navigate accordingly
      await _navigateBasedOnRole();
    } else if (authState.isUnauthenticated) {
      // User is not authenticated, go to onboarding
      _navigateToOnboarding();
    } else if (authState.isFailure) {
      // Authentication failed, go to onboarding
      _navigateToOnboarding();
    }
    // If still loading, wait for state change
  }

  Future<void> _navigateBasedOnRole() async {
    try {
      final role = await _getRole();
      
      if (mounted && !_navigationCompleted) {
        _navigationCompleted = true;
        
        switch (role) {
          case 'user':
            context.go('/home');
            break;
          case 'storeOwner':
            context.go('/vendor/home');
            break;
          case 'null':
          default:
            context.go('/onboarding');
            break;
        }
      }
    } catch (e) {
      // If there's an error getting the role, navigate to onboarding
      _navigateToOnboarding();
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

  Future<String> _getRole() async {
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: "auth_token");
      
      if (token == null || token.isEmpty) {
        return "null";
      }

      // Check if token is expired
      if (JwtDecoder.isExpired(token)) {
        // Clear expired token
        await storage.delete(key: "auth_token");
        return "null";
      }

      final decodedToken = JwtDecoder.decode(token);
      final role = decodedToken['role'] as String?;
      
      if (role == null || role.isEmpty) {
        return "null";
      }
      
      return role;
    } catch (e) {
      // If there's any error decoding the token, return null
      return "null";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: FutureBuilder<String>(
        future: _getRole(),
        builder: (context, snapshot) {
          return Container(
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
                        'assets/images/splash-removebg-preview.png',
                        fit: BoxFit.fitHeight,
                        height: 150,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.medical_services,
                            size: 60,
                            color: AppColors.textOnPrimary,
                          );
                        },
                      ),
                    ),
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
                              _getLoadingMessage(state, snapshot),
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
          );
        },
      ),
    );
  }

  String _getLoadingMessage(AuthenticationState state, AsyncSnapshot<String> roleSnapshot) {
    if (state.isLoading || roleSnapshot.connectionState == ConnectionState.waiting) {
      return 'Authenticating...';
    } else if (state.isAuthenticated) {
      final role = roleSnapshot.data ?? 'null';
      switch (role) {
        case 'user':
          return 'Welcome back!';
        case 'storeOwner':
          return 'Welcome back, Store Owner!';
        case 'null':
        default:
          return 'Getting started...';
      }
    } else if (state.isUnauthenticated) {
      return 'Loading...';
    } else if (state.isFailure) {
      return 'Loading...';
    } else {
      return 'Loading...';
    }
  }
}