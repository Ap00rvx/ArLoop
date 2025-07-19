import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/colors.dart';
import '../../bloc/auth/authentication_bloc.dart';
import '../../bloc/location/location_bloc.dart';
import '../../bloc/store_owner/store_owner_bloc.dart';
import '../../services/location_service.dart';
import '../medicine/medicine_search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Get location and nearby stores when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationBloc>().add(GetCurrentLocationEvent());
      context.read<AuthenticationBloc>().add(GetProfileEvent());
    });
  }

  final List<Category> _categories = [
    Category(
      name: 'Medicines',
      icon: Icons.medical_services,
      color: AppColors.primary,
    ),
    Category(
      name: 'Health Care',
      icon: Icons.favorite,
      color: AppColors.ctaAccent,
    ),
    Category(
      name: 'Baby Care',
      icon: Icons.child_care,
      color: AppColors.success,
    ),
    Category(
      name: 'Supplements',
      icon: Icons.fitness_center,
      color: AppColors.warning,
    ),
    Category(name: 'Diabetes', icon: Icons.water_drop, color: AppColors.info),
    Category(name: 'Personal Care', icon: Icons.face, color: AppColors.primary),
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
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<LocationBloc>().add(GetCurrentLocationEvent());
          context.read<AuthenticationBloc>().add(GetProfileEvent());
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              title: BlocBuilder<LocationBloc, LocationState>(
                builder: (context, locationState) {
                  return Row(
                    spacing: 6,
                    children: [
                      Image.asset('assets/images/logow.png', height: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Arogya Loop',
                              style: TextStyle(
                                color: AppColors.textOnPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (locationState is LocationLoaded)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: AppColors.textOnPrimary,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      locationState.address,
                                      style: const TextStyle(
                                        color: AppColors.textOnPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              )
                            else if (locationState is LocationError)
                              GestureDetector(
                                onTap: () {
                                  context.read<LocationBloc>().add(
                                    GetCurrentLocationEvent(),
                                  );
                                },
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.location_off,
                                      color: AppColors.textOnPrimary,
                                      size: 12,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Tap to get location',
                                      style: TextStyle(
                                        color: AppColors.textOnPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              const Row(
                                children: [
                                  SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.textOnPrimary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Getting location...',
                                    style: TextStyle(
                                      color: AppColors.textOnPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              leadingWidth: 0,
              backgroundColor: AppColors.primary,
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textOnPrimary,
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(
                    Icons.favorite_border,
                    color: AppColors.textOnPrimary,
                  ),
                  onPressed: () {},
                ),
              ],
            ),

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
                          suffixIcon: Icon(
                            Icons.mic,
                            color: AppColors.lightText,
                          ),
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

            // Emergency Services Banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.ctaAccent, AppColors.ctaAccentLight],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.emergency,
                      color: AppColors.neutral,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Emergency Medicine',
                            style: TextStyle(
                              color: AppColors.neutral,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            '24/7 Emergency delivery available',
                            style: TextStyle(
                              color: AppColors.neutral,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neutral,
                        foregroundColor: AppColors.ctaAccent,
                      ),
                      child: const Text('Order Now'),
                    ),
                  ],
                ),
              ),
            ),

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
                  Container(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: category.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  category.icon,
                                  color: category.color,
                                  size: 28,
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

                if (storeState.nearbyStores.isEmpty) {
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
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final shop = storeState.nearbyStores[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.neutral,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.lightShadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Shop Image
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.neutralGrey,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: const Icon(
                                Icons.local_pharmacy,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Shop Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        shop.shopDetails.shopName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.darkText,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: shop.accountStatus == 'active'
                                            ? AppColors.success
                                            : AppColors.error,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        shop.accountStatus.toUpperCase(),
                                        style: const TextStyle(
                                          color: AppColors.neutral,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
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
                                    BlocBuilder<LocationBloc, LocationState>(
                                      builder: (context, locationState) {
                                        if (locationState is LocationLoaded &&
                                            shop.shopDetails.location != null) {
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
                          ),

                          // Action Button
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Navigate to shop details or medicines
                                },
                                style: ElevatedButton.styleFrom(
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
                        ],
                      ),
                    );
                  }, childCount: storeState.nearbyStores.length),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text(
              'Categories',
              style: TextStyle(color: AppColors.textOnPrimary),
            ),
            backgroundColor: AppColors.primary,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
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
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.lightShadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: category.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            category.icon,
                            color: category.color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
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
      ),
    );
  }

  Widget _buildCartTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.lightText,
          ),
          SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start shopping to add items to your cart',
            style: TextStyle(color: AppColors.lightText),
          ),
        ],
      ),
    );
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
                    onTap: () async {
                      // Take photo
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                        maxWidth: 800,
                        maxHeight: 800,
                        imageQuality: 80,
                      );

                      if (image != null) {
                        // Handle the image
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Photo captured: ${image.name}'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
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
                    onTap: () async {
                      // Pick from gallery
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 800,
                        maxHeight: 800,
                        imageQuality: 80,
                      );

                      if (image != null) {
                        // Handle the image
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Image selected: ${image.name}'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    },
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

            // Recent prescriptions
            const Text(
              'Recent Prescriptions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: Container(
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab() {
    return SafeArea(
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.neutral,
                          child: Text(
                            state.user?.name != null
                                ? state.user!.name.substring(0, 1).toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.user?.name ?? 'User',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                        Text(
                          state.user?.email ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  _buildProfileMenuItem(
                    Icons.person,
                    'Edit Profile',
                    'Update your personal information',
                    () {},
                  ),
                  _buildProfileMenuItem(
                    Icons.location_on,
                    'Delivery Address',
                    'Manage your delivery addresses',
                    () {},
                  ),
                  _buildProfileMenuItem(
                    Icons.history,
                    'Order History',
                    'View your past orders',
                    () {},
                  ),
                  _buildProfileMenuItem(
                    Icons.favorite,
                    'Wishlist',
                    'Your favorite medicines',
                    () {},
                  ),
                  _buildProfileMenuItem(
                    Icons.notifications,
                    'Notifications',
                    'Manage notification preferences',
                    () {},
                  ),
                  _buildProfileMenuItem(
                    Icons.help,
                    'Help & Support',
                    'Get help and contact support',
                    () {},
                  ),
                  _buildProfileMenuItem(
                    Icons.logout,
                    'Logout',
                    'Sign out of your account',
                    () {
                      context.read<AuthenticationBloc>().add(LogoutEvent());
                    },
                    isDestructive: true,
                  ),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? AppColors.error : AppColors.primary,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? AppColors.error : AppColors.darkText,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.lightText),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.lightText),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
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
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
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
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
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
  }
}

class Category {
  final String name;
  final IconData icon;
  final Color color;

  Category({required this.name, required this.icon, required this.color});
}
