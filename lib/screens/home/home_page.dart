import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/colors.dart';
import '../../bloc/auth/authentication_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Demo data for nearby medicine shops
  final List<MedicineShop> _nearbyShops = [
    MedicineShop(
      name: 'Apollo Pharmacy',
      address: '123 Health Street, Medical District',
      distance: 0.5,
      rating: 4.5,
      isOpen: true,
      image: 'assets/images/pharmacy1.jpg',
      deliveryTime: '15-20 min',
    ),
    MedicineShop(
      name: 'MedPlus Mart',
      address: '456 Care Avenue, Wellness Zone',
      distance: 1.2,
      rating: 4.3,
      isOpen: true,
      image: 'assets/images/pharmacy1.jpg',
      deliveryTime: '20-25 min',
    ),
    MedicineShop(
      name: 'Guardian Pharmacy',
      address: '789 Medicine Road, Health Hub',
      distance: 2.1,
      rating: 4.7,
      isOpen: false,
      image: 'assets/images/pharmacy1.jpg',
      deliveryTime: '30-35 min',
    ),
    MedicineShop(
      name: 'HealthKart Store',
      address: '321 Wellness Street, Care Center',
      distance: 3.5,
      rating: 4.2,
      isOpen: true,
      image: 'assets/images/pharmacy1.jpg',
      deliveryTime: '40-45 min',
    ),
  ];

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
    return Scaffold(
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
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            title: Row(
              spacing: 6,
              children: [
                Image.asset('assets/images/logow.png', height: 24),
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
                      return SizedBox(
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            Text(
                              'Hello, ${state.user?.name?.split(' ').first ?? 'User'}!',
                              style: const TextStyle(
                                color: AppColors.textOnPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Text(
                              'Find medicines near you',
                              style: TextStyle(
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
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final shop = _nearbyShops[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                        child: Image.asset(
                          shop.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.local_pharmacy,
                              size: 40,
                              color: AppColors.primary,
                            );
                          },
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
                                  shop.name,
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
                                  color: shop.isOpen
                                      ? AppColors.success
                                      : AppColors.error,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  shop.isOpen ? 'OPEN' : 'CLOSED',
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
                            shop.address,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.lightText,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${shop.distance} km',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(width: 16),

                              Icon(
                                Icons.star,
                                size: 14,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                shop.rating.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.darkText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                              const SizedBox(width: 16),

                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: AppColors.lightText,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                shop.deliveryTime,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.lightText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }, childCount: _nearbyShops.length),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return const Center(
      child: Text('Categories Page', style: TextStyle(fontSize: 24)),
    );
  }

  Widget _buildCartTab() {
    return const Center(
      child: Text('Cart Page', style: TextStyle(fontSize: 24)),
    );
  }

  Widget _buildPrescriptionTab() {
    return const Center(
      child: Text('Prescription Page', style: TextStyle(fontSize: 24)),
    );
  }

  Widget _buildProfileTab() {
    return const Center(
      child: Text('Profile Page', style: TextStyle(fontSize: 24)),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Data models
class MedicineShop {
  final String name;
  final String address;
  final double distance;
  final double rating;
  final bool isOpen;
  final String image;
  final String deliveryTime;

  MedicineShop({
    required this.name,
    required this.address,
    required this.distance,
    required this.rating,
    required this.isOpen,
    required this.image,
    required this.deliveryTime,
  });
}

class Category {
  final String name;
  final IconData icon;
  final Color color;

  Category({required this.name, required this.icon, required this.color});
}
