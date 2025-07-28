import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../theme/colors.dart';

class VendorOnboardingPage extends StatefulWidget {
  const VendorOnboardingPage({super.key});

  @override
  State<VendorOnboardingPage> createState() => _VendorOnboardingPageState();
}

class _VendorOnboardingPageState extends State<VendorOnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Vendor onboarding data
  final List<VendorOnboardingData> _onboardingData = [
    VendorOnboardingData(
      icon: Iconsax.shop,
      title: 'Set Up Your Medicine Store',
      subtitle: 'Join our trusted pharmacy network',
      description:
          'Register your pharmacy and connect with customers in your area. Start selling medicines online with our easy-to-use platform.',
      color: AppColors.primary,
    ),
    VendorOnboardingData(
      icon: Iconsax.box,
      title: 'Manage Your Inventory',
      subtitle: 'Easy medicine listing & management',
      description:
          'Upload your medicine inventory, set prices, and manage stock levels. Our system helps you keep track of all your products efficiently.',
      color: AppColors.ctaAccent,
    ),
    VendorOnboardingData(
      icon: Iconsax.location,
      title: 'Deliver to Your Area',
      subtitle: 'Local delivery made simple',
      description:
          'Set your delivery radius and start serving customers in your neighborhood. Track orders and manage deliveries seamlessly.',
      color: AppColors.success,
    ),
    VendorOnboardingData(
      icon: Iconsax.chart_2,
      title: 'Grow Your Business',
      subtitle: 'Analytics & customer insights',
      description:
          'Monitor your sales, track customer preferences, and grow your pharmacy business with our comprehensive analytics dashboard.',
      color: AppColors.info,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToVendorAuth();
    }
  }

  void _skipOnboarding() {
    _navigateToVendorAuth();
  }

  void _navigateToVendorAuth() {
    context.go("/vendor-auth");
  }

  void _goBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.go("/onboarding");
    }
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
    return Column(
      children: [
        // Header with back button and skip
        _buildHeader(isTablet: isTablet),

        // Page View
        Expanded(
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
                isTablet: isTablet,
              );
            },
          ),
        ),

        // Bottom Section
        _buildBottomSection(isTablet: isTablet),
      ],
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
                _buildHeader(isLandscape: true),
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

  Widget _buildHeader({bool isTablet = false, bool isLandscape = false}) {
    final titleFontSize = isTablet ? 20.0 : (isLandscape ? 16.0 : 18.0);
    final skipFontSize = isTablet ? 18.0 : (isLandscape ? 14.0 : 16.0);
    final padding = isTablet ? 20.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.lightText),
            onPressed: _goBack,
          ),
          Text(
            'Vendor Onboarding',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          TextButton(
            onPressed: _skipOnboarding,
            child: Text(
              'Skip',
              style: TextStyle(
                fontSize: skipFontSize,
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
    VendorOnboardingData data, {
    bool isTablet = false,
    bool isLandscape = false,
  }) {
    final containerPadding = isTablet ? 32.0 : (isLandscape ? 16.0 : 24.0);
    final titleFontSize = isTablet ? 32.0 : (isLandscape ? 24.0 : 28.0);
    final subtitleFontSize = isTablet ? 20.0 : (isLandscape ? 16.0 : 18.0);
    final descriptionFontSize = isTablet ? 18.0 : (isLandscape ? 14.0 : 16.0);
    final iconSize = isTablet ? 140.0 : (isLandscape ? 100.0 : 120.0);
    final iconInnerSize = isTablet ? 70.0 : (isLandscape ? 50.0 : 60.0);

    return Padding(
      padding: EdgeInsets.all(containerPadding),
      child: isLandscape
          ? Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        data.subtitle,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: data.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data.description,
                        style: TextStyle(
                          fontSize: descriptionFontSize,
                          color: AppColors.lightText,
                          height: 1.5,
                        ),
                      ),
                      if (_currentPage == _onboardingData.length - 1) ...[
                        const SizedBox(height: 20),
                        _buildFeaturesList(isCompact: true),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Container(
                      height: iconSize,
                      width: iconSize,
                      decoration: BoxDecoration(
                        color: data.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        data.icon,
                        size: iconInnerSize,
                        color: data.color,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  height: iconSize,
                  width: iconSize,
                  decoration: BoxDecoration(
                    color: data.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    data.icon,
                    size: iconInnerSize,
                    color: data.color,
                  ),
                ),

                const SizedBox(height: 40),

                // Title
                Text(
                  data.title,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  data.subtitle,
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: data.color,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  data.description,
                  style: TextStyle(
                    fontSize: descriptionFontSize,
                    color: AppColors.lightText,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // Features list (for last page)
                if (_currentPage == _onboardingData.length - 1) ...[
                  _buildFeaturesList(),
                ],
              ],
            ),
    );
  }

  Widget _buildFeaturesList({bool isCompact = false}) {
    final features = [
      'Easy medicine inventory management',
      'Real-time order notifications',
      'Customer analytics dashboard',
      'Flexible delivery options',
      'Secure payment processing',
    ];

    final titleFontSize = isCompact ? 16.0 : 18.0;
    final itemFontSize = isCompact ? 12.0 : 14.0;
    final iconSize = isCompact ? 18.0 : 20.0;
    final itemSpacing = isCompact ? 6.0 : 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What you get:',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        SizedBox(height: isCompact ? 8 : 12),
        ...features.map(
          (feature) => Padding(
            padding: EdgeInsets.only(bottom: itemSpacing),
            child: Row(
              children: [
                Icon(
                  Iconsax.tick_circle,
                  color: AppColors.success,
                  size: iconSize,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontSize: itemFontSize,
                      color: AppColors.lightText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection({
    bool isTablet = false,
    bool isLandscape = false,
  }) {
    final buttonHeight = isTablet ? 64.0 : (isLandscape ? 48.0 : 56.0);
    final buttonFontSize = isTablet ? 18.0 : (isLandscape ? 14.0 : 16.0);
    final containerPadding = isTablet ? 32.0 : (isLandscape ? 16.0 : 24.0);

    return Container(
      padding: EdgeInsets.all(containerPadding),
      child: Column(
        children: [
          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingData.length,
              (index) => _buildPageIndicator(index, isTablet: isTablet),
            ),
          ),

          SizedBox(height: isLandscape ? 16 : 32),

          // Next/Get Started Button
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentPage == _onboardingData.length - 1
                    ? 'Get Started as Vendor'
                    : 'Next',
                style: TextStyle(
                  fontSize: buttonFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: isLandscape ? 8 : 16),

          // Back to customer app option
          TextButton(
            onPressed: () => context.go("/onboarding"),
            child: Text(
              'Back to Customer App',
              style: TextStyle(
                fontSize: isTablet ? 16.0 : (isLandscape ? 12.0 : 14.0),
                color: AppColors.lightText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index, {bool isTablet = false}) {
    final indicatorHeight = isTablet ? 10.0 : 8.0;
    final activeWidth = isTablet ? 28.0 : 24.0;
    final inactiveWidth = isTablet ? 10.0 : 8.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: indicatorHeight,
      width: _currentPage == index ? activeWidth : inactiveWidth,
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

// Data model for vendor onboarding pages
class VendorOnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;

  VendorOnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
  });
}
