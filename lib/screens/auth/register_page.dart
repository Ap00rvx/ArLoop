import 'package:arloop/bloc/auth/authentication_bloc.dart';
import 'package:arloop/router/route_names.dart';
import 'package:arloop/services/google_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../../theme/colors.dart';
import '../../widgets/google_sign_in_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreeToTerms = false;
  bool _isLoading = false;
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleAuthService authService = GoogleAuthService();
      final GoogleUser? user = await authService.signIn();

      if (user != null) {
        _showSuccessSnackBar('Welcome ${user.name ?? user.email}!');
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        _showErrorSnackBar(
          authService.errorMessage.isEmpty
              ? 'Sign in was canceled'
              : authService.errorMessage,
        );
      }
    } catch (e) {
      _showErrorSnackBar('Google Sign-In failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Focus nodes for better UX
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  // Form validation methods
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[\d\s-()]{10,}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Registration logic
  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      _showErrorSnackBar('Please agree to the terms and conditions');
      return;
    }

    context.read<AuthenticationBloc>().add(
      RegisterEvent(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        phone: _phoneController.text,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.surface,

      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) async {
          if (state.status == AuthenticationStatus.failure) {
            _showErrorSnackBar(state.errorMessage ?? "Registration failed");
          } else if (state.status == AuthenticationStatus.authenticated) {
            final token = state.token;
            await FlutterSecureStorage().write(key: "auth_token", value: token);
            _showSuccessSnackBar('Registration successful!');
            context.goNamed(RouteNames.home);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header Section
                  _buildHeader(size),

                  // Form Fields
                  Container(
                    color: AppColors.primary,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        spacing: 6,
                        children: [
                          // Title
                          SizedBox.fromSize(size: const Size.fromHeight(30)),
                          Text(
                            'Create Account',
                            style: Theme.of(context).textTheme.headlineLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText,
                                ),
                          ),

                          // Subtitle
                          Text(
                            'Join Arogya Loop for better healthcare',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.lightText),
                          ),
                          _buildFormFields(),

                          _buildTermsCheckbox(),

                          // Register Button
                          _buildRegisterButton(),

                          // Login Link
                          _buildLoginLink(),

                          // Social Login (Optional)
                          _buildSocialLogin(),
                          SizedBox(height: 34),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Size size) {
    return Column(
      children: [
        // Logo or Icon
        Container(
          color: AppColors.surface,
          child: Container(
            width: double.infinity,
            height: size.height * 0.25,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40)),
            ),
            child: Center(
              child: Image.asset(
                'assets/images/login_logo.png', // Replace with your logo asset
                height: 200,
                width: 200,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.medical_services,
                    size: 50,
                    color: AppColors.textOnPrimary,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        color: AppColors.surface,
        child: Column(
          spacing: 12,
          children: [
            // Name Field
            TextFormField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Enter your full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textInputAction: TextInputAction.next,
              validator: _validateName,
              onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
            ),

            // Email Field
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter your email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
              onFieldSubmitted: (_) => _phoneFocusNode.requestFocus(),
            ),

            // Phone Field
            TextFormField(
              controller: _phoneController,
              focusNode: _phoneFocusNode,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter your phone number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              validator: _validatePhone,
              onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
            ),

            // Password Field
            TextFormField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Create a strong password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.next,
              validator: _validatePassword,
              onFieldSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
            ),

            // Confirm Password Field
            TextFormField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isConfirmPasswordVisible,
              textInputAction: TextInputAction.done,
              validator: _validateConfirmPassword,
              onFieldSubmitted: (_) => _handleRegistration(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Checkbox(
            value: _agreeToTerms,
            onChanged: (value) {
              setState(() {
                _agreeToTerms = value ?? false;
              });
            },
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _agreeToTerms = !_agreeToTerms;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      const TextSpan(text: 'I agree to the '),
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      color: AppColors.surface,
      width: double.infinity,
      height: 56,
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state.status == AuthenticationStatus.loading) {
            return ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.textOnPrimary,
                  ),
                  strokeWidth: 2,
                ),
              ),
            );
          }
          return ElevatedButton(
            onPressed: _isLoading ? null : _handleRegistration,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textOnPrimary,
                      ),
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Create Account',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.lightText),
        ),
        TextButton(
          onPressed: () {
            context.goNamed(RouteNames.login);
          },
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Divider
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Or continue with',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),

          const SizedBox(height: 24),

          // Social Buttons
          GoogleSignInButton(
            onSuccess: () {
              // Navigate to home page after successful Google sign-in
              context.goNamed(RouteNames.home);
            },
            onError: (String errorMessage) {
              _showErrorSnackBar(errorMessage);
            },
          ),
        ],
      ),
    );
  }
}
