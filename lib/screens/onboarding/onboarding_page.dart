import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../router/route_names.dart';
import '../../theme/colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _selectedLanguage = "en";
  // Onboarding data
  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      image: 'assets/images/doctors_2.jpg',
      title: 'Expert Medical Consultation',
      subtitle: 'Connect with qualified doctors',
      description:
          'Get professional medical advice from certified doctors anytime, anywhere. Your health is our priority.',
    ),
    OnboardingData(
      image: 'assets/images/doctors.jpg',
      title: 'Trusted Healthcare Network',
      subtitle: 'Quality care you can trust',
      description:
          'Access a network of verified healthcare professionals and get personalized treatment recommendations.',
    ),
    OnboardingData(
      image: 'assets/images/med.png',
      title: 'Fast Medicine Delivery',
      subtitle: 'Medicines at your doorstep',
      description:
          'Order prescription medicines and health products with quick delivery to your home. Safe, secure, and convenient.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToHome();
    }
  }

  void _skipOnboarding() {
    _navigateToHome();
  }

  void _navigateToHome() {
    context.go("/register");
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (isLandscape && !isTablet) {
              // Landscape phone layout
              return _buildLandscapeLayout(constraints);
            } else {
              // Portrait layout (phone and tablet)
              return _buildPortraitLayout(constraints, isTablet);
            }
          },
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(BoxConstraints constraints, bool isTablet) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Column(
          children: [
            // Skip Button
            _buildSkipButton(),

            // Page View
            SizedBox(
              height: constraints.maxHeight * (isTablet ? 0.6 : 0.5),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(
                    _onboardingData[index],
                    Size(constraints.maxWidth, constraints.maxHeight),
                    isTablet: isTablet,
                  );
                },
              ),
            ),

            // Bottom Section
            _buildBottomSection(isTablet: isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(BoxConstraints constraints) {
    return Row(
      children: [
        // Left side - Page View
        Expanded(
          flex: 3,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return _buildOnboardingPage(
                _onboardingData[index],
                Size(constraints.maxWidth * 0.6, constraints.maxHeight),
                isLandscape: true,
              );
            },
          ),
        ),

        // Right side - Controls and info
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSkipButton(),
                Expanded(
                  child: Center(child: _buildBottomSection(isLandscape: true)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkipButton() {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Visibility(
                visible: _currentPage > 0,
                child: IconButton(
                  onPressed: () {
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.lightText,
                    size: isTablet ? 24 : 20,
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 12 : 10),

              Icon(
                Iconsax.language_square4,
                color: AppColors.lightText,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: isTablet ? 8 : 5),
              // dropdown to select language
              DropdownButton<String>(
                value: _selectedLanguage,
                items: const [
                  DropdownMenuItem(value: "en", child: Text("English")),
                  DropdownMenuItem(value: "hi", child: Text("हिंदी")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
                underline: Container(),
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: isTablet ? 18 : 16,
                ),
              ),
            ],
          ),

          TextButton(
            onPressed: _skipOnboarding,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 16,
                vertical: isTablet ? 12 : 8,
              ),
            ),
            child: Text(
              'Skip',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: AppColors.lightText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(
    OnboardingData data,
    Size size, {
    bool isTablet = false,
    bool isLandscape = false,
  }) {
    final horizontalPadding = isTablet ? 48.0 : 24.0;
    final imageHeight = isLandscape
        ? size.height * 0.27
        : size.height * (isTablet ? 0.20 : 0.18);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isLandscape ? 12.0 : 24.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Container(
            height: imageHeight,
            width: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                data.image,
                fit: BoxFit.fitHeight,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.neutralGrey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.medical_services,
                      size: isTablet ? 120 : 100,
                      color: AppColors.primary,
                    ),
                  );
                },
              ),
            ),
          ),

          SizedBox(height: isLandscape ? 16 : 20),

          // Title
          Text(
            data.title,
            style: TextStyle(
              fontSize: isTablet ? 32 : (isLandscape ? 24 : 28),
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: isLandscape ? 8 : 10),

          // Subtitle
          Text(
            data.subtitle,
            style: TextStyle(
              fontSize: isTablet ? 20 : (isLandscape ? 14 : 16),
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: isLandscape ? 10 : 12),

          // Description
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 600 : double.infinity,
            ),
            child: Text(
              data.description,
              style: TextStyle(
                fontSize: isTablet ? 18 : (isLandscape ? 14 : 16),
                color: AppColors.lightText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection({
    bool isTablet = false,
    bool isLandscape = false,
  }) {
    final horizontalPadding = isTablet ? 48.0 : 24.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isLandscape ? 16.0 : 24.0,
      ),
      child: Column(
        mainAxisSize: isLandscape ? MainAxisSize.min : MainAxisSize.max,
        children: [
          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingData.length,
              (index) => _buildPageIndicator(index, isTablet: isTablet),
            ),
          ),

          SizedBox(height: isLandscape ? 24 : 32),

          // Next/Get Started Button
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 400 : double.infinity,
            ),
            child: SizedBox(
              width: double.infinity,
              height: isTablet ? 64 : 56,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  _currentPage == _onboardingData.length - 1
                      ? 'Get Started'
                      : 'Next',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: isLandscape ? 12 : 16),

          // Alternative: Login/Sign Up Row (if needed)
          if (!isLandscape) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: TextStyle(
                    color: AppColors.lightText,
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to login
                    context.goNamed(RouteNames.login);
                  },
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isTablet ? 32 : 24),

            // Vendor option
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isTablet ? 500 : double.infinity,
              ),
              child: Container(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Iconsax.shop,
                          color: AppColors.primary,
                          size: isTablet ? 28 : 24,
                        ),
                        SizedBox(width: isTablet ? 16 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Are you a pharmacy owner?',
                                style: TextStyle(
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkText,
                                ),
                              ),
                              SizedBox(height: isTablet ? 6 : 4),
                              Text(
                                'Join as a vendor and start selling medicines online',
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12,
                                  color: AppColors.lightText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    SizedBox(
                      width: double.infinity,
                      height: isTablet ? 52 : 44,
                      child: OutlinedButton(
                        onPressed: () => context.go("/vendor-onboarding"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 16 : 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Join as Vendor',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index, {bool isTablet = false}) {
    final indicatorHeight = isTablet ? 10.0 : 8.0;
    final indicatorWidth = _currentPage == index
        ? (isTablet ? 32.0 : 24.0)
        : (isTablet ? 10.0 : 8.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 6 : 4),
      height: indicatorHeight,
      width: indicatorWidth,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.primary
            : AppColors.neutralGrey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// Data model for onboarding pages
class OnboardingData {
  final String image;
  final String title;
  final String subtitle;
  final String description;

  OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}
