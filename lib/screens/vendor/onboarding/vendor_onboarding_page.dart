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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and skip
            _buildHeader(),

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
                  return _buildOnboardingPage(_onboardingData[index]);
                },
              ),
            ),

            // Bottom Section
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.lightText),
            onPressed: _goBack,
          ),
          const Text(
            'Vendor Onboarding',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          TextButton(
            onPressed: _skipOnboarding,
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.lightText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(VendorOnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 60, color: data.color),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 28,
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
              fontSize: 18,
              color: data.color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 16,
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

  Widget _buildFeaturesList() {
    final features = [
      'Easy medicine inventory management',
      'Real-time order notifications',
      'Customer analytics dashboard',
      'Flexible delivery options',
      'Secure payment processing',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What you get:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkText,
          ),
        ),
        const SizedBox(height: 12),
        ...features.map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Iconsax.tick_circle,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature,
                    style: const TextStyle(
                      fontSize: 14,
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

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingData.length,
              (index) => _buildPageIndicator(index),
            ),
          ),

          const SizedBox(height: 32),

          // Next/Get Started Button
          SizedBox(
            width: double.infinity,
            height: 56,
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Back to customer app option
          TextButton(
            onPressed: () => context.go("/onboarding"),
            child: const Text(
              'Back to Customer App',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.lightText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
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
