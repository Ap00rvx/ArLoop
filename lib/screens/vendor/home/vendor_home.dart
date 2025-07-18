import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/store_owner/store_owner_bloc.dart';
import '../../../bloc/shop/shop_bloc.dart';
import '../../../bloc/medicine/medicine_bloc.dart';
import '../../../theme/colors.dart';
import '../../../models/vendor/shop.dart';
import '../../../models/vendor/medicine.dart';

class VendorHome extends StatefulWidget {
  const VendorHome({super.key});

  @override
  State<VendorHome> createState() => _VendorHomeState();
}

class _VendorHomeState extends State<VendorHome> {
  int _currentIndex = 0;

  // Demo medicines data
  final List<Map<String, dynamic>> _demoMedicines = [
    {
      'name': 'Paracetamol 500mg',
      'category': 'Pain Relief',
      'price': 25.50,
      'stock': 150,
      'prescription': false,
      'image': 'assets/images/med.png',
    },
    {
      'name': 'Amoxicillin 250mg',
      'category': 'Antibiotic',
      'price': 85.00,
      'stock': 75,
      'prescription': true,
      'image': 'assets/images/med.png',
    },
    {
      'name': 'Vitamin D3',
      'category': 'Vitamins',
      'price': 120.00,
      'stock': 200,
      'prescription': false,
      'image': 'assets/images/med.png',
    },
    {
      'name': 'Insulin 100IU',
      'category': 'Diabetes',
      'price': 450.00,
      'stock': 25,
      'prescription': true,
      'image': 'assets/images/med.png',
    },
    {
      'name': 'Aspirin 75mg',
      'category': 'Cardiovascular',
      'price': 15.00,
      'stock': 300,
      'prescription': false,
      'image': 'assets/images/med.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeBlocs();
  }

  void _initializeBlocs() {
    // Initialize store owner bloc to get profile data
    context.read<StoreOwnerBloc>().add(InitialStoreOwnerEvent());

    // Initialize shop bloc and get shop details
    context.read<ShopBloc>().add(InitialShopEvent());
    context.read<ShopBloc>().add(GetShopDetailsEvent());
    context.read<ShopBloc>().add(GetShopStatisticsEvent());
    context.read<ShopBloc>().add(GetActiveAnnouncementsEvent());

    // Initialize medicine bloc and load medicines
    context.read<MedicineBloc>().add(InitialMedicineEvent());
    context.read<MedicineBloc>().add(
      const LoadOwnerMedicinesEvent(page: 1, limit: 10),
    );
    context.read<MedicineBloc>().add(LoadLowStockMedicinesEvent());
    context.read<MedicineBloc>().add(
      const LoadOwnerMedicinesEvent(page: 1, limit: 10),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Get page titles for app bar
  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Announcements';
      case 2:
        return 'Medicines';
      case 3:
        return 'Profile';
      default:
        return 'ArLoop Vendor';
    }
  }

  // Get different pages based on bottom nav selection
  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardPage();
      case 1:
        return _buildAnnouncementsPage();
      case 2:
        return _buildMedicinesPage();
      case 3:
        return _buildProfilePage();
      default:
        return _buildDashboardPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(_getPageTitle(_currentIndex)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications
            },
          ),
          if (_currentIndex == 3) // Only show logout on profile page
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<StoreOwnerBloc>().add(LogoutStoreOwnerEvent());
              },
            ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<StoreOwnerBloc, StoreOwnerState>(
            listener: (context, state) {
              if (!state.isAuthenticated && state.token == null) {
                // Navigate to login page
                Navigator.of(context).pushReplacementNamed('/onboarding');
              }
            },
          ),
          BlocListener<MedicineBloc, MedicineState>(
            listener: (context, state) {
              // if (state.successMessage != null) {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(
              //       content: Text(state.successMessage!),
              //       backgroundColor: Colors.green,
              //     ),
              //   );
              //   // Clear the message after showing
              //   Future.delayed(const Duration(milliseconds: 100), () {
              //     if (mounted) {
              //       context.read<MedicineBloc>().add(InitialMedicineEvent());
              //     }
              //   });
              // }
              // if (state.errorMessage != null) {
              //   ScaffoldMessenger.of(context).showSnackBar(
              //     SnackBar(
              //       content: Text(state.errorMessage!),
              //       backgroundColor: Colors.red,
              //     ),
              //   );
              //   // Clear the message after showing
              //   Future.delayed(const Duration(milliseconds: 100), () {
              //     if (mounted) {
              //       context.read<MedicineBloc>().add(InitialMedicineEvent());
              //     }
              //   });
              // }
            },
          ),
        ],
        child: _getCurrentPage(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Announcements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medicines',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Dashboard/Home Page
  Widget _buildDashboardPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 20),
          _buildQuickStatsSection(),
          const SizedBox(height: 20),
          _buildShopDetailsSection(),
          const SizedBox(height: 20),
          _buildQuickActionsSection(),
        ],
      ),
    );
  }

  // Announcements Page
  Widget _buildAnnouncementsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.campaign, color: Colors.white, size: 32),
                const SizedBox(height: 12),
                const Text(
                  'Manage Announcements',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep your customers informed with important updates',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildAnnouncementsSection(),
        ],
      ),
    );
  }

  // Medicines Page
  Widget _buildMedicinesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.medication, color: Colors.white, size: 32),
                const SizedBox(height: 12),
                const Text(
                  'Medicine Inventory',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your pharmacy stock and inventory',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildMedicinesSection(),
          const SizedBox(height: 20),
          _buildMedicineActions(),
        ],
      ),
    );
  }

  // Profile Page
  Widget _buildProfilePage() {
    return BlocBuilder<StoreOwnerBloc, StoreOwnerState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.indigo, Colors.indigoAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.currentOwner?.ownerName ?? 'Store Owner',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.currentOwner?.email ?? 'owner@example.com',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildProfileDetails(state),
              const SizedBox(height: 20),
              _buildProfileActions(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileDetails(StoreOwnerState state) {
    final owner = state.currentOwner;
    if (owner == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDetailRow(Icons.person, 'Name', owner.ownerName),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.email, 'Email', owner.email),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.phone, 'Phone', owner.phone),
              const SizedBox(height: 12),
              _buildDetailRow(
                Icons.verified,
                'Verification Status',
                owner.accountStatus.isNotEmpty ? 'Verified' : 'Pending',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: [
            _buildActionTile(
              Icons.edit,
              'Edit Profile',
              'Update your personal information',
              () {
                // Edit profile
              },
            ),
            const SizedBox(height: 8),
            _buildActionTile(
              Icons.security,
              'Change Password',
              'Update your account password',
              () {
                // Change password
              },
            ),
            const SizedBox(height: 8),
            _buildActionTile(
              Icons.store,
              'Shop Settings',
              'Manage shop details and preferences',
              () {
                // Shop settings
              },
            ),
            const SizedBox(height: 8),
            _buildActionTile(
              Icons.help,
              'Help & Support',
              'Get help or contact support',
              () {
                // Help & support
              },
            ),
            const SizedBox(height: 8),
            _buildActionTile(
              Icons.logout,
              'Logout',
              'Sign out of your account',
              () {
                context.read<StoreOwnerBloc>().add(LogoutStoreOwnerEvent());
              },
              isDestructive: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDestructive ? Colors.red : AppColors.primary)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medicine Management',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Add Medicine',
                Icons.add_box,
                Colors.green,
                () {
                  _showAddMedicineDialog();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Search Medicine',
                Icons.search,
                Colors.blue,
                () {
                  _showSearchMedicineDialog();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Low Stock Alert',
                Icons.warning,
                Colors.orange,
                () {
                  _showLowStockMedicines();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Expired Medicines',
                Icons.schedule,
                Colors.red,
                () {
                  _showExpiredMedicines();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return BlocBuilder<StoreOwnerBloc, StoreOwnerState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back!',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.currentOwner?.ownerName ?? 'Store Owner',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (state.currentShop?.owner != null) ...[
                const SizedBox(height: 4),
                Text(
                  state.currentShop!.createdAt!.toLocal().toString().split(
                    ' ',
                  )[0],
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
              const SizedBox(height: 16),
              _buildShopStatusIndicator(state.currentShop),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShopStatusIndicator(Shop? shop) {
    if (shop == null) return const SizedBox.shrink();

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (shop.operationalStatus.toLowerCase()) {
      case 'open':
        statusColor = Colors.green;
        statusText = 'Open';
        statusIcon = Icons.check_circle;
        break;
      case 'closed':
        statusColor = Colors.red;
        statusText = 'Closed';
        statusIcon = Icons.cancel;
        break;
      case 'busy':
        statusColor = Colors.orange;
        statusText = 'Busy';
        statusIcon = Icons.hourglass_empty;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
        statusIcon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 16),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            if (state.isStatisticsLoading)
              const Center(child: CircularProgressIndicator())
            else if (state.statistics != null)
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Orders',
                      state.statistics!.metrics.totalOrders.toString(),
                      Icons.shopping_cart,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Customers',
                      '${state.statistics!.metrics.totalCustomers.toStringAsFixed(0)}',
                      Icons.currency_rupee,
                      Colors.green,
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Orders',
                      '128',
                      Icons.shopping_cart,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Revenue',
                      '₹25,400',
                      Icons.currency_rupee,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Avg Rating',
                    '4.8',
                    Icons.star,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Medicines',
                    _demoMedicines.length.toString(),
                    Icons.medication,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildShopDetailsSection() {
    return BlocBuilder<StoreOwnerBloc, StoreOwnerState>(
      builder: (context, state) {
        final shop = state.currentShop;
        final storeOwner = state.currentOwner;
        if (shop == null || storeOwner == null) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shop Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    Icons.store,
                    'Name',
                    storeOwner.shopDetails.shopName,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.phone, 'Phone', storeOwner.phone),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.location_on,
                    'Address',
                    storeOwner.shopDetails.shopAddress.street +
                        ', ' +
                        storeOwner.shopDetails.shopAddress.city +
                        ', ' +
                        storeOwner.shopDetails.shopAddress.state +
                        ', ' +
                        storeOwner.shopDetails.shopAddress.pincode,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.access_time,
                    'Working Hours',
                    '${storeOwner.shopDetails.workingHours.openTime} - ${storeOwner.shopDetails.workingHours.closeTime}',
                  ),
                  if (storeOwner
                      .shopDetails
                      .workingHours
                      .workingDays
                      .isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Working Days',
                      storeOwner.shopDetails.workingHours.workingDays.join(
                        ', ',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementsSection() {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Announcements',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Add new announcement
                    _showAddAnnouncementDialog();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (state.isAnnouncementsLoading)
              const Center(child: CircularProgressIndicator())
            else if (state.announcements.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.announcements.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final announcement = state.announcements[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getAnnouncementTypeColor(
                          announcement.type,
                        ).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getAnnouncementTypeColor(
                                  announcement.type,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                announcement.type.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getAnnouncementTypeColor(
                                    announcement.type,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (announcement.isActive)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          announcement.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          announcement.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No announcements yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _showAddAnnouncementDialog,
                      child: const Text('Add your first announcement'),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Color _getAnnouncementTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'info':
        return Colors.blue;
      case 'warning':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      case 'promotion':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildMedicinesSection() {
    return BlocBuilder<MedicineBloc, MedicineState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Medicines',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    // Refresh medicines
                    context.read<MedicineBloc>().add(
                      const LoadOwnerMedicinesEvent(),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (state.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (state.isFailure)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      state.errorMessage ?? 'Failed to load medicines',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.read<MedicineBloc>().add(
                          const LoadOwnerMedicinesEvent(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (state.medicines.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.medication_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No medicines found',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add medicines to your inventory to get started',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showAddMedicineDialog();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Medicine'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.medicines.length > 10
                      ? 10
                      : state.medicines.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final medicine = state.medicines[index];
                    return _buildMedicineCard(medicine);
                  },
                ),
              ),

            // Low stock warning section
            if (state.lowStockMedicines.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Low Stock Alert',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${state.lowStockMedicines.length} medicines are running low on stock',
                      style: TextStyle(color: Colors.orange[700]),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        _showLowStockMedicines();
                      },
                      child: const Text('View Details'),
                    ),
                  ],
                ),
              ),
            ],

            // Success message
            if (state.successMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.successMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildMedicineCard(Medicine medicine) {
    final isLowStock =
        medicine.stock.availableQuantity < medicine.stock.minimumStockLevel;

    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: medicine.imageUrl != null && medicine.imageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      medicine.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.medication,
                          size: 32,
                          color: AppColors.primary,
                        );
                      },
                    ),
                  )
                : Icon(Icons.medication, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            medicine.medicineName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            medicine.category,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${medicine.pricing.sellingPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (medicine.prescriptionRequired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Rx',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Stock: ${medicine.stock.availableQuantity}',
            style: TextStyle(
              fontSize: 11,
              color: isLowStock
                  ? Colors.red
                  : medicine.stock.availableQuantity < 50
                  ? Colors.orange
                  : Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isLowStock)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Low Stock',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Update Status',
                Icons.update,
                Colors.blue,
                () {
                  _showUpdateStatusDialog();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Add Medicine',
                Icons.add_box,
                Colors.green,
                () {
                  // Add medicine
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'View Orders',
                Icons.receipt_long,
                Colors.orange,
                () {
                  // View orders
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Settings',
                Icons.settings,
                Colors.purple,
                () {
                  // Settings
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAnnouncementDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'info';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Announcement'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: ['info', 'warning', 'urgent', 'promotion']
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  messageController.text.isNotEmpty) {
                context.read<ShopBloc>().add(
                  AddAnnouncementEvent(
                    title: titleController.text,
                    message: messageController.text,
                    type: selectedType,
                    endDate: DateTime.now().add(const Duration(days: 30)),
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog() {
    String currentStatus = 'open';
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Shop Status'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: currentStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: ['open', 'closed', 'busy']
                    .map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    currentStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Status Message (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<StoreOwnerBloc>().add(
                UpdateShopStatusEvent(
                  operationalStatus: currentStatus,
                  statusMessage: messageController.text,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Medicine Management Methods
  void _showAddMedicineDialog() {
    showDialog(
      context: context,
      builder: (context) => AddMedicineDialog(
        onAddMedicine: (medicineData) {
          context.read<MedicineBloc>().add(
            AddMedicineEvent(
              medicineName: medicineData['medicineName'],
              genericName: medicineData['genericName'],
              manufacturer: medicineData['manufacturer'],
              category: medicineData['category'],
              therapeuticClass: medicineData['therapeuticClass'],
              composition: medicineData['composition'],
              strength: medicineData['strength'],
              dosageForm: medicineData['dosageForm'],
              brandName: medicineData['brandName'],
              description: medicineData['description'],
              prescriptionRequired:
                  medicineData['prescriptionRequired'] ?? false,
              sellingPrice: medicineData['sellingPrice'],
              mrp: medicineData['mrp'],
              costPrice: medicineData['costPrice'],
              availableQuantity: medicineData['availableQuantity'],
              minimumStockLevel: medicineData['minimumStockLevel'],
              keywords: medicineData['keywords'],
              isVisible: medicineData['isVisible'] ?? true,
            ),
          );
        },
      ),
    );
  }

  void _showSearchMedicineDialog() {
    showDialog(
      context: context,
      builder: (context) => SearchMedicineDialog(
        onSearch: (searchParams) {
          context.read<MedicineBloc>().add(
            SearchMedicinesEvent(
              search: searchParams['search'],
              category: searchParams['category'],
              therapeuticClass: searchParams['therapeuticClass'],
              prescriptionRequired: searchParams['prescriptionRequired'],
              minPrice: searchParams['minPrice'],
              maxPrice: searchParams['maxPrice'],
            ),
          );
        },
      ),
    );
  }

  void _showLowStockMedicines() {
    context.read<MedicineBloc>().add(LoadLowStockMedicinesEvent());
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<MedicineBloc, MedicineState>(
        builder: (context, state) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('Low Stock Medicines'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.lowStockMedicines.isEmpty
                  ? const Center(
                      child: Text('No medicines with low stock found'),
                    )
                  : ListView.builder(
                      itemCount: state.lowStockMedicines.length,
                      itemBuilder: (context, index) {
                        final medicine = state.lowStockMedicines[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.medication,
                            color: Colors.orange,
                          ),
                          title: Text(medicine.medicineName),
                          subtitle: Text(
                            'Stock: ${medicine.stock.availableQuantity}',
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              _showUpdateStockDialog(medicine);
                            },
                            child: const Text('Update Stock'),
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showExpiredMedicines() {
    context.read<MedicineBloc>().add(LoadExpiredMedicinesEvent());
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<MedicineBloc, MedicineState>(
        builder: (context, state) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.schedule, color: Colors.red),
                SizedBox(width: 8),
                Text('Expired Medicines'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.expiredMedicines.isEmpty
                  ? const Center(child: Text('No expired medicines found'))
                  : ListView.builder(
                      itemCount: state.expiredMedicines.length,
                      itemBuilder: (context, index) {
                        final medicine = state.expiredMedicines[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.medication,
                            color: Colors.red,
                          ),
                          title: Text(medicine.medicineName),
                          subtitle: medicine.batchDetails != null
                              ? Text(
                                  'Expired: ${medicine.batchDetails!.first.expiryDate.toLocal().toString().split(' ')[0]}',
                                )
                              : const Text('Expired medicine'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteConfirmation(medicine);
                            },
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUpdateStockDialog(Medicine medicine) {
    final quantityController = TextEditingController();
    String operation = 'add';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stock - ${medicine.medicineName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Stock: ${medicine.stock.availableQuantity}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: operation,
              decoration: const InputDecoration(
                labelText: 'Operation',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'add', child: Text('Add Stock')),
                DropdownMenuItem(value: 'remove', child: Text('Remove Stock')),
                DropdownMenuItem(value: 'set', child: Text('Set Stock')),
              ],
              onChanged: (value) {
                operation = value!;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text);
              if (quantity != null) {
                context.read<MedicineBloc>().add(
                  UpdateStockEvent(
                    medicineId: medicine.id,
                    operation: operation,
                    quantity: quantity,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Medicine medicine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: Text(
          'Are you sure you want to delete ${medicine.medicineName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<MedicineBloc>().add(
                DeleteMedicineEvent(medicineId: medicine.id),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Simple dialog widgets for medicine management
class AddMedicineDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onAddMedicine;

  const AddMedicineDialog({super.key, required this.onAddMedicine});

  @override
  State<AddMedicineDialog> createState() => _AddMedicineDialogState();
}

class _AddMedicineDialogState extends State<AddMedicineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _medicineNameController = TextEditingController();
  final _genericNameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _compositionController = TextEditingController();
  final _strengthController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _mrpController = TextEditingController();
  final _stockController = TextEditingController();

  String _selectedCategory = 'Tablet';
  String _selectedTherapeuticClass = 'Antibiotic';
  String _selectedDosageForm = 'Oral';
  bool _prescriptionRequired = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Medicine'),
      content: SizedBox(
        width: double.maxFinite,
        height: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _medicineNameController,
                  decoration: const InputDecoration(
                    labelText: 'Medicine Name *',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _genericNameController,
                  decoration: const InputDecoration(
                    labelText: 'Generic Name *',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _manufacturerController,
                  decoration: const InputDecoration(
                    labelText: 'Manufacturer *',
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items:
                      [
                            'Tablet',
                            'Capsule',
                            'Syrup',
                            'Injection',
                            'Drops',
                            'Cream',
                            'Ointment',
                            'Powder',
                            'Inhaler',
                            'Spray',
                            'Gel',
                            'Lotion',
                            'Suspension',
                            'Other',
                          ]
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedTherapeuticClass,
                  decoration: const InputDecoration(
                    labelText: 'Therapeutic Class',
                  ),
                  items:
                      [
                            'Antibiotic',
                            'Analgesic',
                            'Antacid',
                            'Antidiabetic',
                            'Antihypertensive',
                            'Antihistamine',
                            'Vitamin',
                            'Supplement',
                            'Cardiac',
                            'Respiratory',
                            'Gastrointestinal',
                            'Neurological',
                            'Dermatological',
                            'Other',
                          ]
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedTherapeuticClass = value!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _compositionController,
                  decoration: const InputDecoration(labelText: 'Composition *'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _strengthController,
                  decoration: const InputDecoration(labelText: 'Strength *'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedDosageForm,
                  decoration: const InputDecoration(labelText: 'Dosage Form'),
                  items:
                      [
                            'Oral',
                            'Topical',
                            'Injectable',
                            'Inhalation',
                            'Nasal',
                            'Ophthalmic',
                            'Otic',
                            'Rectal',
                          ]
                          .map(
                            (form) => DropdownMenuItem(
                              value: form,
                              child: Text(form),
                            ),
                          )
                          .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedDosageForm = value!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sellingPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Selling Price *',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _mrpController,
                  decoration: const InputDecoration(labelText: 'MRP *'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(
                    labelText: 'Initial Stock *',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Prescription Required'),
                  value: _prescriptionRequired,
                  onChanged: (value) =>
                      setState(() => _prescriptionRequired = value!),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onAddMedicine({
                'medicineName': _medicineNameController.text,
                'genericName': _genericNameController.text,
                'manufacturer': _manufacturerController.text,
                'category': _selectedCategory,
                'therapeuticClass': _selectedTherapeuticClass,
                'composition': _compositionController.text,
                'strength': _strengthController.text,
                'dosageForm': _selectedDosageForm,
                'prescriptionRequired': _prescriptionRequired,
                'sellingPrice': double.tryParse(_sellingPriceController.text),
                'mrp': double.tryParse(_mrpController.text),
                'availableQuantity': int.tryParse(_stockController.text),
                'minimumStockLevel': 10,
              });
              Navigator.pop(context);
            }
          },
          child: const Text('Add Medicine'),
        ),
      ],
    );
  }
}

class SearchMedicineDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSearch;

  const SearchMedicineDialog({super.key, required this.onSearch});

  @override
  State<SearchMedicineDialog> createState() => _SearchMedicineDialogState();
}

class _SearchMedicineDialogState extends State<SearchMedicineDialog> {
  final _searchController = TextEditingController();
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  String? _selectedCategory;
  String? _selectedTherapeuticClass;
  bool? _prescriptionRequired;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Search Medicines'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by name',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items:
                  [
                        null,
                        'Tablet',
                        'Capsule',
                        'Syrup',
                        'Injection',
                        'Drops',
                        'Cream',
                        'Ointment',
                        'Powder',
                        'Inhaler',
                        'Spray',
                        'Gel',
                        'Lotion',
                        'Suspension',
                        'Other',
                      ]
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category ?? 'All Categories'),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedTherapeuticClass,
              decoration: const InputDecoration(labelText: 'Therapeutic Class'),
              items:
                  [
                        null,
                        'Antibiotic',
                        'Analgesic',
                        'Antacid',
                        'Antidiabetic',
                        'Antihypertensive',
                        'Antihistamine',
                        'Vitamin',
                        'Supplement',
                        'Cardiac',
                        'Respiratory',
                        'Gastrointestinal',
                        'Neurological',
                        'Dermatological',
                        'Other',
                      ]
                      .map(
                        (item) => DropdownMenuItem(
                          value: item,
                          child: Text(item ?? 'All Classes'),
                        ),
                      )
                      .toList(),
              onChanged: (value) =>
                  setState(() => _selectedTherapeuticClass = value),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    decoration: const InputDecoration(labelText: 'Min Price'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    decoration: const InputDecoration(labelText: 'Max Price'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<bool>(
              value: _prescriptionRequired,
              decoration: const InputDecoration(
                labelText: 'Prescription Required',
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: true, child: Text('Yes')),
                DropdownMenuItem(value: false, child: Text('No')),
              ],
              onChanged: (value) =>
                  setState(() => _prescriptionRequired = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSearch({
              'search': _searchController.text.isNotEmpty
                  ? _searchController.text
                  : null,
              'category': _selectedCategory,
              'therapeuticClass': _selectedTherapeuticClass,
              'prescriptionRequired': _prescriptionRequired,
              'minPrice': double.tryParse(_minPriceController.text),
              'maxPrice': double.tryParse(_maxPriceController.text),
            });
            Navigator.pop(context);
          },
          child: const Text('Search'),
        ),
      ],
    );
  }
}
