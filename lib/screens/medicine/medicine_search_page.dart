import 'dart:math';
import 'package:badges/badges.dart' as badges;
import 'package:arloop/bloc/location/location_bloc.dart';
import 'package:arloop/screens/home/cart_page.dart';
import 'package:arloop/static/demo_images.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/colors.dart';
import '../../bloc/medicine/medicine_bloc.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../models/medicine_response.dart';
import '../../services/cart_service.dart';

class MedicineSearchPage extends StatefulWidget {
  final String? category;

  const MedicineSearchPage({super.key, this.category});

  @override
  State<MedicineSearchPage> createState() => _MedicineSearchPageState();
}

class _MedicineSearchPageState extends State<MedicineSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;

  final List<String> _categories = [
    'All',
    'Antibiotics',
    'Analgesics',
    'Antiseptics',
    'Cardiovascular',
    'Diabetes',
    'Respiratory',
    'Gastrointestinal',
    'Dermatology',
    'Vitamins',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category ?? 'All';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load medicines and cart when page opens
      _loadMedicines();
      context.read<CartBloc>().add(LoadCartEvent());
    });
  }

  void _loadMedicines() {
    if (_selectedCategory == 'All') {
      context.read<MedicineBloc>().add(const SearchMedicinesEvent());
    } else {
      context.read<MedicineBloc>().add(
        SearchMedicinesEvent(category: _selectedCategory),
      );
    }
  }

  void _searchMedicines(String query) {
    if (query.isEmpty) {
      _loadMedicines();
    } else {
      context.read<MedicineBloc>().add(
        SearchMedicinesEvent(
          search: query,
          category: _selectedCategory == 'All' ? null : _selectedCategory,
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartBloc(cartService: CartService()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Medicine Search',
            style: TextStyle(color: AppColors.textOnPrimary),
          ),
          backgroundColor: AppColors.primary,
          iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        ),
        floatingActionButton: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            return badges.Badge(
              badgeContent: Text(
                state.totalItems.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              child: FloatingActionButton(
                onPressed: () {
                  context.read<CartBloc>().add(LoadCartEvent());
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => const CartPage()),
                  );
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.shopping_cart),
              ),
            );
          },
        ),
        body: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primary,
              child: Container(
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
                  onChanged: _searchMedicines,
                  decoration: const InputDecoration(
                    hintText: 'Search medicines...',
                    prefixIcon: Icon(Icons.search, color: AppColors.lightText),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),

            // Category Filter
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;

                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                        _loadMedicines();
                      },
                      backgroundColor: AppColors.neutral,
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.darkText,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Medicine List
            Expanded(
              child: BlocBuilder<MedicineBloc, MedicineState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.isFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Error loading medicines',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.errorMessage ?? 'Something went wrong',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.lightText),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadMedicines,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final medicines =
                      state.searchResults?.data.medicines.isNotEmpty ?? false
                      ? state.searchResults?.data.medicines.cast<Medicine>()
                      : state.medicines;

                  if ((medicines == null || medicines.isEmpty) &&
                      state.isSuccess) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.medical_services_outlined,
                            size: 64,
                            color: AppColors.lightText,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No medicines found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Try searching with different terms or categories',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.lightText),
                          ),
                        ],
                      ),
                    );
                  }
                  context.read<CartBloc>().add(LoadCartEvent());
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: medicines!.length,
                    itemBuilder: (context, index) {
                      final meds = medicines as List<Medicine>;
                      // sort medicine base upon the distance
                      meds.sort((a, b) {
                        final locationState = context
                            .read<LocationBloc>()
                            .state;
                        if (locationState is LocationLoaded) {
                          final userLat = locationState.latitude;
                          final userLng = locationState.longitude;

                          final distanceA = calculateDistance(
                            a.storeOwner.shopDetails.location.latitude,
                            a.storeOwner.shopDetails.location.longitude,
                            userLat,
                            userLng,
                          );
                          final distanceB = calculateDistance(
                            b.storeOwner.shopDetails.location.latitude,
                            b.storeOwner.shopDetails.location.longitude,
                            userLat,
                            userLng,
                          );
                          return distanceA.compareTo(distanceB);
                        }
                        return 0; // Default case if location is not loaded
                      });
                      context.read<CartBloc>().add(LoadCartEvent());
                      return _buildMedicineCard(
                        meds[index],
                        context: context,
                        index: index,
                        length: medicines.length,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// function to calcute distance betwwen store and user current location
String calculateDistance(
  double storeLat,
  double storeLng,
  double userLat,
  double userLng,
) {
  const double earthRadius = 6371; // Radius of the Earth in kilometers

  final dLat = (storeLat - userLat) * (3.141592653589793 / 180);
  final dLng = (storeLng - userLng) * (3.141592653589793 / 180);

  final a =
      (sin(dLat / 2) * sin(dLat / 2)) +
      cos(userLat * (3.141592653589793 / 180)) *
          cos(storeLat * (3.141592653589793 / 180)) *
          (sin(dLng / 2) * sin(dLng / 2));

  final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return '${(earthRadius * c).toStringAsFixed(2)} km';
}

Widget _buildMedicineCard(
  Medicine medicine, {
  required BuildContext context,
  required int index,
  required int length,
}) {
  final location = context.read<LocationBloc>().state as LocationLoaded;
  final userLng = location.longitude;
  final userLat = location.latitude;
  final images = DemoImages.meds;
  return Card(
    elevation: 4,

    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        return;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.neutral,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),

                child: Image.network(
                  images[index % images.length],
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.medical_services_outlined,
                      size: 60,
                      color: AppColors.lightText,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      Text(
                        medicine.medicineName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      Text(
                        "(${medicine.genericName})",
                        style: const TextStyle(
                          fontSize: 24,
                          color: AppColors.lightText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  if (medicine.category != null)
                    Text(
                      medicine.category!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  if (medicine.storeOwner != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              medicine.storeOwner.shopDetails.shopName,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.lightText,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            Text(
                              ' ,${medicine.storeOwner.shopDetails.shopAddress.street}, ${medicine.storeOwner.shopDetails.shopAddress.city}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.lightText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Text(
                          "${calculateDistance(medicine.storeOwner.shopDetails.location.latitude, medicine.storeOwner.shopDetails.location.longitude, userLat, userLng)}",
                        ),
                      ],
                    ),
                ],
              ),
            ),
            SizedBox(width: double.infinity, height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // if (medicine.pricing.sellingPrice != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '₹${medicine.pricing.sellingPrice}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '₹${medicine.pricing.mrp}',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              fontSize: 20,
                              color: AppColors.lightText,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ],
                      ),
                      // if (medicine.pricing.discountPercentage != null &&
                      //     medicine.pricing.discountPercentage! > 0)
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red.withOpacity(0.8),
                          ),
                          borderRadius: BorderRadius.circular(8),
                          // ignore: deprecated_member_use
                          color: Colors.red.withOpacity(0.1),
                        ),
                        child: Text(
                          '${medicine.pricing.discountPercentage}% off',
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.lightText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Quick Add to Cart button on card
                  BlocConsumer<CartBloc, CartState>(
                    listener: (context, state) {
                      print("Cart State: ${state.status}");
                      if (state.status == CartStatus.initial) {
                        context.read<CartBloc>().add(LoadCartEvent());
                      }
                    },
                    builder: (context, cartState) {
                      final isInCart = cartState.isInCart(medicine.id);
                      final quantity = cartState.getMedicineQuantity(
                        medicine.id,
                      );
                      final isOutOfStock =
                          medicine.stock.availableQuantity! <= 0;

                      if (isOutOfStock) {
                        return Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Out of Stock',
                              style: TextStyle(
                                color: AppColors.error,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }

                      if (!isInCart) {
                        return Container(
                          width: double.infinity,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: cartState.isLoading
                                  ? null
                                  : () {
                                      context.read<CartBloc>().add(
                                        AddToCartEvent(medicine),
                                      );
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (cartState.isLoading)
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    else
                                      const Icon(
                                        Icons.add_shopping_cart,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    const SizedBox(width: 8),
                                    Text(
                                      cartState.isLoading
                                          ? 'Adding...'
                                          : 'Add to Cart',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      // Enhanced quantity controls when item is in cart
                      return Container(
                        width: double.infinity,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // Decrease button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                ),
                                onTap: cartState.isLoading
                                    ? null
                                    : () {
                                        if (quantity > 1) {
                                          context.read<CartBloc>().add(
                                            UpdateQuantityEvent(
                                              medicine.id,
                                              quantity - 1,
                                            ),
                                          );
                                        } else {
                                          context.read<CartBloc>().add(
                                            RemoveFromCartEvent(medicine.id),
                                          );
                                        }
                                      },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: quantity > 1
                                        ? AppColors.primary.withOpacity(0.1)
                                        : AppColors.error.withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                  ),
                                  child: Icon(
                                    quantity > 1
                                        ? Icons.remove
                                        : Icons.delete_outline,
                                    size: 18,
                                    color: quantity > 1
                                        ? AppColors.primary
                                        : AppColors.error,
                                  ),
                                ),
                              ),
                            ),

                            // Quantity display
                            Expanded(
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.symmetric(
                                    vertical: BorderSide(
                                      color: AppColors.primary.withOpacity(0.2),
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    quantity.toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Increase button
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                onTap: cartState.isLoading
                                    ? null
                                    : () {
                                        context.read<CartBloc>().add(
                                          UpdateQuantityEvent(
                                            medicine.id,
                                            quantity + 1,
                                          ),
                                        );
                                      },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
