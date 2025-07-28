import 'package:arloop/router/route_names.dart';
import 'package:arloop/static/demo_images.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../theme/colors.dart';
import '../../bloc/auth/authentication_bloc.dart';
import '../../bloc/location/location_bloc.dart';
import '../../bloc/store_owner/store_owner_bloc.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../services/location_service.dart';
import '../../services/prescription_service.dart';
import '../medicine/medicine_search_page.dart';
import '../emergency/emergency_service_page.dart';
import 'cart_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Prescription related variables
  final PrescriptionService _prescriptionService = PrescriptionService();
  List<PrescriptionItem> _prescriptions = [];
  bool _isLoadingPrescriptions = false;
  String lang = "en";
  @override
  void initState() {
    super.initState();
    // Get location and nearby stores when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationBloc>().add(GetCurrentLocationEvent());
      context.read<AuthenticationBloc>().add(GetProfileEvent());
      context.read<CartBloc>().add(LoadCartEvent());
      _loadPrescriptions();
    });
  }

  Future<void> _loadPrescriptions() async {
    setState(() {
      _isLoadingPrescriptions = true;
    });

    try {
      await _prescriptionService.cleanupOrphanedPrescriptions();
      final prescriptions = await _prescriptionService.getPrescriptions();
      setState(() {
        _prescriptions = prescriptions;
        _isLoadingPrescriptions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPrescriptions = false;
      });
      print('Error loading prescriptions: $e');
    }
  }

  Future<void> _handleImageCapture(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        // Show dialog to get prescription name
        final String? prescriptionName = await _showPrescriptionNameDialog();

        if (prescriptionName != null && prescriptionName.isNotEmpty) {
          setState(() {
            _isLoadingPrescriptions = true;
          });

          final savedPrescription = await _prescriptionService.savePrescription(
            image.path,
            prescriptionName,
          );

          if (savedPrescription != null) {
            await _loadPrescriptions();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Prescription "$prescriptionName" saved successfully',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );

              // Show dialog asking if user wants to browse medicines
              final bool? browseMedicines = await _showBrowseMedicinesDialog();
              if (browseMedicines == true) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const MedicineSearchPage(category: 'All'),
                  ),
                );
              }
            }
          } else {
            setState(() {
              _isLoadingPrescriptions = false;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to save prescription'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingPrescriptions = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<String?> _showPrescriptionNameDialog() async {
    final TextEditingController nameController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Prescription Name'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText:
                  'Enter prescription name (e.g., Dr. Smith - Antibiotics)',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.of(context).pop(name);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showBrowseMedicinesDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_pharmacy,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Browse Medicines',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: const Text(
            'Would you like to browse medicines for your uploaded prescription?',
            style: TextStyle(fontSize: 16, color: AppColors.lightText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Later',
                style: TextStyle(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Browse Now',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePrescription(PrescriptionItem prescription) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Prescription'),
          content: Text(
            'Are you sure you want to delete "${prescription.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final success = await _prescriptionService.deletePrescription(
        prescription.id,
      );
      if (success) {
        await _loadPrescriptions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Prescription deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      }
    }
  }

  void _viewPrescriptionFullScreen(PrescriptionItem prescription) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            _PrescriptionFullScreenView(prescription: prescription),
      ),
    );
  }

  Future<void> _showLogoutConfirmationDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Logout',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout from your account?',
            style: TextStyle(fontSize: 16, color: AppColors.lightText),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.lightText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      context.read<AuthenticationBloc>().add(LogoutEvent());
      context.goNamed(RouteNames.onboarding);
    }
  }

  final List<Category> _categories = [
    Category(
      name: 'Medicines',
      image: CategoryImages.medicine,
      color: AppColors.primary,
    ),
    Category(
      name: 'Health Care',
      image: CategoryImages.healthCare,
      color: AppColors.ctaAccent,
    ),
    Category(
      name: 'Baby Care',
      image: CategoryImages.babyCare,
      color: AppColors.success,
    ),
    Category(
      name: 'Supplements',
      image: CategoryImages.supplements,
      color: AppColors.warning,
    ),
    Category(
      name: 'Diabetes',
      image: CategoryImages.diabetes,
      color: AppColors.info,
    ),
    Category(
      name: 'Personal Care',
      image: CategoryImages.personalCare,
      color: AppColors.primary,
    ),
    // add more categories
    Category(
      name: 'Fitness',
      image: CategoryImages.fitness,
      color: AppColors.secondary,
    ),
    Category(
      name: 'Vitamins',
      image: CategoryImages.vitamins,
      color: AppColors.primary,
    ),
    Category(
      name: 'Ayurveda',
      image: CategoryImages.ayurveda,
      color: AppColors.ctaAccent,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LocationBloc, LocationState>(
          listener: (context, state) {
            if (state is LocationLoaded) {
              // When location is loaded, fetch nearby stores
              context.read<StoreOwnerBloc>().add(
                GetNearbyStoresEvent(
                  latitude: state.latitude,
                  longitude: state.longitude,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          centerTitle: false,
          leadingWidth: 0,
          title: BlocBuilder<LocationBloc, LocationState>(
            builder: (context, locationState) {
              return Row(
                children: [
                  Image.asset('assets/images/logow.png', height: 24),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Arogya Loop',
                          style: TextStyle(
                            color: AppColors.textOnPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.textOnPrimary,
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            // build dropdown for languages
            DropdownButton<String>(
              dropdownColor: AppColors.primary,
              focusColor: AppColors.primary,
              value: lang,
              underline: Container(),
              borderRadius: BorderRadius.circular(8),
              style: const TextStyle(color: AppColors.textOnPrimary),
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Icon(
                  Icons.language,
                  color: AppColors.textOnPrimary,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'en',
                  child: Text(
                    'English',
                    style: TextStyle(color: AppColors.textOnPrimary),
                  ),
                ),
                DropdownMenuItem(
                  value: 'hi',
                  child: Text(
                    'हिंदी',
                    style: TextStyle(color: AppColors.textOnPrimary),
                  ),
                ),
              ],
              onChanged: (value) {
                // Handle language change
                if (value != null) {
                  setState(() {
                    lang = value;
                  });
                  //
                }
              },
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textOnPrimary,
              ),
              color: AppColors.neutral,
              onSelected: (value) {
                if (value == 'logout') {
                  _showLogoutConfirmationDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(),
            _buildCategoriesTab(),
            _buildCartTab(),
            _buildPrescriptionTab(),
            _buildProfileTab(),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildHomeTab() {
    final location = context.watch<LocationBloc>().state;
    return RefreshIndicator(
      onRefresh: () async {
        context.read<LocationBloc>().add(GetCurrentLocationEvent());
        context.read<AuthenticationBloc>().add(GetProfileEvent());
      },
      child: CustomScrollView(
        slivers: [
          // App Bar

          // Search Bar
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.neutral,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search medicines, health products...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.lightText,
                        ),
                        suffixIcon: Icon(Icons.mic, color: AppColors.lightText),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  BlocBuilder<AuthenticationBloc, AuthenticationState>(
                    builder: (context, state) {
                      print(state.user);
                      return SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'Hello, ${state.user?.name != null ? state.user!.name.split(' ').first : 'User'}!',
                              style: const TextStyle(
                                color: AppColors.textOnPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              (location is LocationLoaded)
                                  ? 'Get Medicines at ${location.address}'
                                  : 'Tap to get your location',

                              style: const TextStyle(
                                color: AppColors.textOnPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                              overflow: TextOverflow.ellipsis,
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

          // Emergency Button Section

          // Featured Products Section
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/tlp_hero_pharmacy-flyer-b9b6bce9fc64f5b41cbb7ecec9f8bd14.jpg",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const EmergencyServicePage(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.error,
                        AppColors.error.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.textOnPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.emergency,
                          color: AppColors.textOnPrimary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Emergency Services',
                              style: TextStyle(
                                color: AppColors.textOnPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap for immediate emergency assistance',
                              style: TextStyle(
                                color: AppColors.textOnPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.textOnPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.textOnPrimary,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // // Emergency Services Banner
          // SliverToBoxAdapter(
          //   child: Container(
          //     margin: const EdgeInsets.all(10),
          //     padding: const EdgeInsets.all(16),
          //     decoration: BoxDecoration(
          //       gradient: LinearGradient(
          //         colors: [AppColors.ctaAccent, AppColors.ctaAccentLight],
          //       ),
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     child: Row(
          //       children: [
          //         const Icon(
          //           Icons.emergency,
          //           color: AppColors.neutral,
          //           size: 32,
          //         ),
          //         const SizedBox(width: 12),
          //         Expanded(
          //           child: Column(
          //             crossAxisAlignment: CrossAxisAlignment.start,
          //             children: [
          //               const Text(
          //                 'Emergency Medicine',
          //                 style: TextStyle(
          //                   color: AppColors.neutral,
          //                   fontSize: 16,
          //                   fontWeight: FontWeight.bold,
          //                 ),
          //               ),
          //               const Text(
          //                 '24/7 Emergency delivery available',
          //                 style: TextStyle(
          //                   color: AppColors.neutral,
          //                   fontSize: 12,
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //         ElevatedButton(
          //           onPressed: () {
          //             Navigator.of(context).push(
          //               CupertinoPageRoute(
          //                 builder: (context) => MedicineSearchPage(),
          //               ),
          //             );
          //           },
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: AppColors.neutral,
          //             foregroundColor: AppColors.ctaAccent,
          //           ),
          //           child: const Text('Order Now'),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),

          // Categories Section
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Shop by Category',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => MedicineSearchPage(
                                category: category.name == 'Medicines'
                                    ? 'All'
                                    : category.name,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    category.image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Nearby Shops Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nearby Medicine Shops',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View All',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Medicine Shops List
          BlocBuilder<StoreOwnerBloc, StoreOwnerState>(
            builder: (context, storeState) {
              if (storeState.isNearbyStoresLoading) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              if (storeState.nearbyStores.isEmpty &&
                  storeState.isNearbyStoresLoading == false) {
                return SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.neutral,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 64,
                          color: AppColors.lightText,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No nearby stores found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Try adjusting your location or search in a different area',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.lightText),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<LocationBloc>().add(
                              GetCurrentLocationEvent(),
                            );
                          },
                          child: const Text('Refresh Location'),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (storeState.nearbyStores.isEmpty &&
                  storeState.isNearbyStoresLoading == true) {
                return SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.neutral,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        const SizedBox(height: 16),
                        const Text(
                          'Fetching Nearby Store',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'this while take a while',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.lightText),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<LocationBloc>().add(
                              GetCurrentLocationEvent(),
                            );
                          },
                          child: const Text('Refresh Location'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverToBoxAdapter(
                child: Container(
                  child: CarouselSlider.builder(
                    itemCount: storeState.nearbyStores.length,
                    options: CarouselOptions(
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 2),
                      enlargeCenterPage: false,
                      enableInfiniteScroll: true,
                      viewportFraction: 1,
                    ),
                    itemBuilder: (context, index, realIdx) {
                      final shop = storeState.nearbyStores[index];

                      final shopImage = Image.asset(
                        'assets/images/4606187_2438239.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      );
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.neutral,
                          border: Border.all(color: AppColors.border, width: 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            // Shop Image
                            Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.neutralGrey,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: shopImage,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Shop Details
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            shop.shopDetails.shopName,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.darkText,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${shop.shopDetails.shopAddress.street}, ${shop.shopDetails.shopAddress.city}',
                                        style: const TextStyle(
                                          color: AppColors.lightText,
                                          fontSize: 12,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: AppColors.warning,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          const Text(
                                            '4.5',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.location_pin,
                                            color: AppColors.lightText,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          BlocBuilder<
                                            LocationBloc,
                                            LocationState
                                          >(
                                            builder: (context, locationState) {
                                              if (locationState
                                                      is LocationLoaded &&
                                                  shop.shopDetails.location !=
                                                      null) {
                                                final distance =
                                                    LocationService.calculateDistance(
                                                      locationState.latitude,
                                                      locationState.longitude,
                                                      shop
                                                          .shopDetails
                                                          .location!
                                                          .latitude,
                                                      shop
                                                          .shopDetails
                                                          .location!
                                                          .longitude,
                                                    );
                                                return Text(
                                                  LocationService.formatDistance(
                                                    distance,
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.lightText,
                                                  ),
                                                );
                                              }
                                              return const Text(
                                                'N/A',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.lightText,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Navigate to shop details or medicines
                                    },
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(120, 32),
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.textOnPrimary,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: const Text(
                                      'View',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Action Button
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      "assets/images/super_sale.png",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 150,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 26, // Spacer
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Determine crossAxisCount based on screen width
          int crossAxisCount = 2;
          double width = constraints.maxWidth;
          if (width >= 900) {
            crossAxisCount = 4;
          } else if (width >= 600) {
            crossAxisCount = 3;
          }

          double childAspectRatio = 0.95;
          if (width >= 900) {
            childAspectRatio = 1.1;
          } else if (width >= 600) {
            childAspectRatio = 1.05;
          }

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: childAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final category = _categories[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigate to category medicines
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MedicineSearchPage(
                              category: category.name == 'Medicines'
                                  ? 'All'
                                  : category.name,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.neutral,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  border: Border.all(
                                    color: AppColors.border,
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  child: Image.asset(
                                    category.image,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              width: double.infinity,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                category.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }, childCount: _categories.length),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartTab() {
    return const CartPage();
  }

  Widget _buildPrescriptionTab() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Prescription',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Take a photo or upload an image of your prescription',
              style: TextStyle(color: AppColors.lightText),
            ),
            const SizedBox(height: 24),

            // Upload options
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _handleImageCapture(ImageSource.camera),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 48,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Take Photo',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _handleImageCapture(ImageSource.gallery),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.ctaAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.ctaAccent.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.photo_library,
                            size: 48,
                            color: AppColors.ctaAccent,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'From Gallery',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.ctaAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Saved prescriptions header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Saved Prescriptions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                if (_prescriptions.isNotEmpty)
                  TextButton(
                    onPressed: _loadPrescriptions,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: 16, color: AppColors.primary),
                        const SizedBox(width: 4),
                        const Text(
                          'Refresh',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Prescriptions list
            Expanded(
              child: _isLoadingPrescriptions
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : _prescriptions.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.neutral,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: AppColors.lightText,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No prescriptions yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkText,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Upload your first prescription to get started',
                              style: TextStyle(color: AppColors.lightText),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _prescriptions.length,
                      itemBuilder: (context, index) {
                        final prescription = _prescriptions[index];
                        return _buildPrescriptionCard(prescription);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionCard(PrescriptionItem prescription) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prescription Image
          GestureDetector(
            onTap: () => _viewPrescriptionFullScreen(prescription),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                color: AppColors.neutralGrey,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: FutureBuilder<bool>(
                  future: _prescriptionService.imageExists(
                    prescription.imagePath,
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return Image.file(
                        File(prescription.imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImageErrorWidget();
                        },
                      );
                    } else {
                      return _buildImageErrorWidget();
                    }
                  },
                ),
              ),
            ),
          ),

          // Prescription Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        prescription.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'view':
                            _viewPrescriptionFullScreen(prescription);
                            break;
                          case 'delete':
                            _deletePrescription(prescription);
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'view',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 16),
                              SizedBox(width: 8),
                              Text('View Full Screen'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete,
                                size: 16,
                                color: AppColors.error,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Delete',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.mutedText,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(prescription.uploadedAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
                if (prescription.notes != null &&
                    prescription.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    prescription.notes!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.lightText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageErrorWidget() {
    return Container(
      color: AppColors.neutralGrey,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 48, color: AppColors.mutedText),
            SizedBox(height: 8),
            Text(
              'Image not found',
              style: TextStyle(color: AppColors.mutedText, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildProfileTab() {
    return SafeArea(
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Modern Profile Header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                        AppColors.primaryDark,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                    child: Column(
                      children: [
                        // Profile Avatar with Shadow
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.neutral,
                                child: Text(
                                  state.user?.name != null
                                      ? state.user!.name
                                            .substring(0, 1)
                                            .toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.neutral,
                                      width: 3,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.verified,
                                    color: AppColors.neutral,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // User Name
                        Text(
                          state.user?.name ?? 'User',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // User Email
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            state.user?.email ?? 'user@example.com',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Quick Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatCard(
                              '12',
                              'Orders',
                              Icons.shopping_bag_outlined,
                            ),
                            _buildStatCard(
                              '5',
                              'Favorites',
                              Icons.favorite_border,
                            ),
                            _buildStatCard(
                              '3',
                              'Addresses',
                              Icons.location_on_outlined,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Profile Menu Items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Account Section
                      _buildSectionHeader('Account'),
                      const SizedBox(height: 12),
                      _buildModernProfileMenuItem(
                        Icons.person_outline,
                        'Edit Profile',
                        'Update your personal information',
                        Colors.blue,
                        () {},
                      ),
                      _buildModernProfileMenuItem(
                        Icons.location_on_outlined,
                        'Delivery Addresses',
                        'Manage your delivery locations',
                        Colors.orange,
                        () {},
                      ),
                      _buildModernProfileMenuItem(
                        Icons.payment_outlined,
                        'Payment Methods',
                        'Manage cards and payment options',
                        Colors.green,
                        () {},
                      ),

                      const SizedBox(height: 24),

                      // Orders Section
                      _buildSectionHeader('Orders'),
                      const SizedBox(height: 12),
                      _buildModernProfileMenuItem(
                        Icons.history_outlined,
                        'Order History',
                        'View your past orders and receipts',
                        Colors.purple,
                        () {},
                      ),
                      _buildModernProfileMenuItem(
                        Icons.favorite_border,
                        'Wishlist',
                        'Your saved medicines and products',
                        Colors.red,
                        () {},
                      ),
                      _buildModernProfileMenuItem(
                        Icons.local_shipping_outlined,
                        'Track Orders',
                        'Track your current orders',
                        Colors.indigo,
                        () {},
                      ),

                      const SizedBox(height: 24),

                      // Settings Section
                      _buildSectionHeader('Settings'),
                      const SizedBox(height: 12),
                      _buildModernProfileMenuItem(
                        Icons.notifications_outlined,
                        'Notifications',
                        'Manage notification preferences',
                        Colors.amber,
                        () {},
                      ),
                      _buildModernProfileMenuItem(
                        Icons.security_outlined,
                        'Privacy & Security',
                        'Manage your account security',
                        Colors.teal,
                        () {},
                      ),
                      _buildModernProfileMenuItem(
                        Icons.language_outlined,
                        'Language',
                        'Choose your preferred language',
                        Colors.deepPurple,
                        () {},
                      ),

                      const SizedBox(height: 24),

                      // Support Section
                      _buildSectionHeader('Support'),
                      const SizedBox(height: 12),
                      _buildModernProfileMenuItem(
                        Icons.help_outline,
                        'Help & Support',
                        'Get help and contact our support team',
                        Colors.cyan,
                        () {},
                      ),
                      _buildModernProfileMenuItem(
                        Icons.info_outline,
                        'About',
                        'App version and company information',
                        Colors.grey,
                        () {},
                      ),

                      const SizedBox(height: 24),

                      // Logout Button
                      _buildModernProfileMenuItem(
                        Icons.logout,
                        'Logout',
                        'Sign out of your account',
                        AppColors.error,
                        _showLogoutConfirmationDialog,
                        isDestructive: true,
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.textOnPrimary, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.darkText,
        ),
      ),
    );
  }

  Widget _buildModernProfileMenuItem(
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDestructive ? AppColors.error : iconColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: isDestructive ? AppColors.error : AppColors.darkText,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.lightText, fontSize: 13),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.neutralGrey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.chevron_right,
            color: AppColors.mutedText,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.neutral,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              if (context.read<LocationBloc>().state is LocationLoading) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please wait, location is loading...'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.neutral,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.mutedText,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/images/category.png",
                  height: 24,
                  color: _currentIndex == 1
                      ? AppColors.primary
                      : AppColors.mutedText,
                ),
                label: 'Categories',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      color: _currentIndex == 2
                          ? AppColors.primary
                          : AppColors.mutedText,
                    ),
                    if (cartState.totalItems > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cartState.totalItems}',
                            style: const TextStyle(
                              color: AppColors.textOnPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Cart',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(
                  "assets/images/pres.png",
                  height: 24,
                  color: _currentIndex == 3
                      ? AppColors.primary
                      : AppColors.mutedText,
                ),
                label: 'Prescription',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}

class Category {
  final String name;
  final String image;
  final Color color;

  Category({required this.name, required this.image, required this.color});
}

class _PrescriptionFullScreenView extends StatelessWidget {
  final PrescriptionItem prescription;

  const _PrescriptionFullScreenView({required this.prescription});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          prescription.name,
          style: const TextStyle(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality will be implemented'),
                  backgroundColor: AppColors.info,
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 3.0,
          child: FutureBuilder<bool>(
            future: PrescriptionService().imageExists(prescription.imagePath),
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return Image.file(
                  File(prescription.imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildFullScreenError();
                  },
                );
              } else {
                return _buildFullScreenError();
              }
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black87,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prescription.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Uploaded: ${_formatFullDate(prescription.uploadedAt)}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            if (prescription.notes != null &&
                prescription.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                prescription.notes!,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFullScreenError() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 64, color: Colors.white54),
          SizedBox(height: 16),
          Text(
            'Image not found',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
