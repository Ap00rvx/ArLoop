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
  }

  Future<String> _checkTokensAndGetRole() async {
    // Add minimum splash duration
    await Future.delayed(const Duration(seconds: 3));

    try {
      const storage = FlutterSecureStorage();

      // Check for user token first
      final userToken = await storage.read(key: "auth_token");
      print('User Token: ${userToken != null ? "Found" : "Not found"}');

      if (userToken != null &&
          userToken.isNotEmpty &&
          !JwtDecoder.isExpired(userToken)) {
        final decodedToken = JwtDecoder.decode(userToken);
        final role = decodedToken['role'] as String?;
        print('User token role: $role');
        if (role != null && role.isNotEmpty) {
          return role;
        }
      }

      // Check for store owner token
      final storeOwnerToken = await storage.read(key: "store_owner_token");
      print(
        'Store Owner Token: ${storeOwnerToken != null ? "Found" : "Not found"}',
      );

      if (storeOwnerToken != null &&
          storeOwnerToken.isNotEmpty &&
          !JwtDecoder.isExpired(storeOwnerToken)) {
        final decodedToken = JwtDecoder.decode(storeOwnerToken);
        final role = decodedToken['role'] as String?;
        print('Store owner token role: $role');
        if (role != null && role.isNotEmpty) {
          return role;
        }
        // If no role specified in store owner token, assume storeOwner
        print('Assuming storeOwner role for store owner token');
        return "storeOwner";
      }

      print('No valid tokens found, returning null');
      return "null";
    } catch (e) {
      print('Error checking tokens: $e');
      return "null";
    }
  }

  void _navigateBasedOnRole(String role) {
    if (_navigationCompleted) return;

    _navigationCompleted = true;
    print('Navigating based on role: $role');

    switch (role) {
      case 'user':
        print('Navigating to user home');
        context.go('/home');
        break;
      case 'storeOwner':
        print('Navigating to vendor home');
        context.go('/vendor/home');
        break;
      case 'null':
      default:
        print('Navigating to onboarding');
        context.go('/onboarding');
        break;
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
      body: FutureBuilder<String>(
        future: _checkTokensAndGetRole(),
        builder: (context, snapshot) {
          // Handle navigation based on the detected role
          if (snapshot.hasData && !_navigationCompleted) {
            final role = snapshot.data!;
            print('FutureBuilder detected role: $role');

            // Use addPostFrameCallback to navigate after the build is complete
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_navigationCompleted) {
                _navigateBasedOnRole(role);
              }
            });
          } else if (snapshot.hasError) {
            print('FutureBuilder error: ${snapshot.error}');

            // Navigate to onboarding on error
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_navigationCompleted) {
                _navigateBasedOnRole('null');
              }
            });
          }

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
                  FadeTransition(
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
                          _getLoadingMessage(snapshot),
                          style: const TextStyle(
                            color: AppColors.textOnPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getLoadingMessage(AsyncSnapshot<String> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return 'Checking authentication...';
    } else if (snapshot.hasData) {
      final role = snapshot.data!;
      switch (role) {
        case 'user':
          return 'Welcome back!';
        case 'storeOwner':
          return 'Welcome back, Store Owner!';
        case 'null':
        default:
          return 'Getting started...';
      }
    } else if (snapshot.hasError) {
      return 'Loading...';
    } else {
      return 'Initializing...';
    }
  }
}
