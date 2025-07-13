import 'package:flutter/material.dart';
import '../services/firebase_google_auth_service.dart';
import '../theme/colors.dart';
import 'google_logo.dart';

class GoogleSignInButton extends StatefulWidget {
  final VoidCallback? onSuccess;
  final Function(String)? onError;

  const GoogleSignInButton({Key? key, this.onSuccess, this.onError})
    : super(key: key);

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  final FirebaseGoogleAuthService _googleAuthService =
      FirebaseGoogleAuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResult? result = await _googleAuthService.signInWithGoogle();

      if (result != null) {
        // Success
        final userName =
            result.backendUser['name'] ??
            result.firebaseUser.displayName ??
            'User';

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome $userName!'),
              backgroundColor: AppColors.success,
            ),
          );
        }

        // Check if this is a new user who needs to complete their profile
        if (result.isNewUser &&
            (result.backendUser['phone'] == null ||
                result.backendUser['phone'].toString().isEmpty)) {
          // Show profile completion dialog
          if (mounted) {
            _showCompleteProfileDialog(result);
          }
        } else {
          // Existing user or profile is complete
          widget.onSuccess?.call();
        }
      } else {
        // Handle error
        final errorMessage = _googleAuthService.errorMessage.isEmpty
            ? 'Sign in was cancelled'
            : _googleAuthService.errorMessage;

        widget.onError?.call(errorMessage);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      final errorMessage = 'Google Sign-In failed: $e';
      widget.onError?.call(errorMessage);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showCompleteProfileDialog(AuthResult result) {
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Complete Your Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Welcome ${result.backendUser['name']}!'),
              const SizedBox(height: 16),
              const Text(
                'Please add your phone number to complete your profile.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter 10-digit phone number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                maxLength: 10,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Sign out and close dialog
                await _googleAuthService.signOut();
                if (mounted) {
                  Navigator.of(context).pop();
                  widget.onError?.call('Profile completion cancelled');
                }
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final phone = phoneController.text.trim();
                if (phone.length == 10) {
                  // Complete profile
                  final success = await _googleAuthService.completeProfile(
                    phone: phone,
                  );
                  if (mounted) {
                    Navigator.of(context).pop();
                    if (success) {
                      widget.onSuccess?.call();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile completed successfully!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } else {
                      widget.onError?.call(_googleAuthService.errorMessage);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_googleAuthService.errorMessage),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter a valid 10-digit phone number',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
              ),
              child: const Text('Complete Profile'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleGoogleSignIn,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                else
                  Image.asset(
                    'assets/images/GOOGLE.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const GoogleLogo(size: 24);
                    },
                  ),
               
                Text(
                  _isLoading ? 'Signing in...' : 'Continue with Google',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.darkText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 36), // Balance the icon space
              ],
            ),
          ),
        ),
      ),
    );
  }
}
