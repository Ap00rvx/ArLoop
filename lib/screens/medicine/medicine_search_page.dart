import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/colors.dart';
import '../../bloc/medicine/medicine_bloc.dart';
import '../../models/medicine_response.dart';

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
      // Load medicines when page opens
      _loadMedicines();
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Medicine Search',
          style: TextStyle(color: AppColors.textOnPrimary),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
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

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: medicines!.length,
                  itemBuilder: (context, index) {
                    final medicine = medicines[index] as Medicine;
                    return _buildMedicineCard(medicine, context: context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildMedicineCard(Medicine medicine, {required BuildContext context}) {
  return Card(
    elevation: 4,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.grey.shade200, width: 1),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.6,
            builder: (_, controller) => SingleChildScrollView(
              controller: controller,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                        
                            child: Text(
                              medicine.medicineName ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        if (medicine.isFeatured == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Featured',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (medicine.category != null)
                      Chip(
                        label: Text(medicine.category!),
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    const SizedBox(height: 16),
                    if (medicine.genericName != null)
                      Text(
                        'Generic: ${medicine.genericName}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.lightText,
                        ),
                      ),
                    const SizedBox(height: 8),
                    if (medicine.manufacturer != null)
                      Text(
                        'Manufacturer: ${medicine.manufacturer}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.lightText,
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (medicine.storeOwner != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Store Details:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppColors.darkText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            medicine.storeOwner.shopDetails.shopName ??
                                'Unknown Store',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (medicine.storeOwner.shopDetails.shopAddress !=
                              null)
                            Text(
                              '${medicine.storeOwner.shopDetails.shopAddress!.street}, ${medicine.storeOwner.shopDetails.shopAddress!.city}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.lightText,
                              ),
                            ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (medicine.pricing.sellingPrice != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price: ₹${medicine.pricing.sellingPrice}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                  fontSize: 16,
                                ),
                              ),
                              if (medicine.pricing.discountPercentage != null &&
                                  medicine.pricing.discountPercentage! > 0)
                                Text(
                                  'MRP: ₹${medicine.pricing.mrp} (${medicine.pricing.discountPercentage}% off)',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.lightText,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                        if (medicine.stock.availableQuantity != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: medicine.stock.availableQuantity! > 0
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              medicine.stock.availableQuantity! > 0
                                  ? 'Available'
                                  : 'Out of Stock',
                              style: TextStyle(
                                color: medicine.stock.availableQuantity! > 0
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (medicine.prescriptionRequired == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.medical_information,
                              size: 20,
                              color: AppColors.warning,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Prescription Required',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.warning,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.medical_services_outlined,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicine.medicineName ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (medicine.genericName != null)
                    Text(
                      medicine.genericName!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.lightText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (medicine.category != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        medicine.category!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (medicine.storeOwner != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        medicine.storeOwner.shopDetails.shopName ??
                            'Unknown Store',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.lightText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (medicine.pricing.sellingPrice != null)
                  Text(
                    '₹${medicine.pricing.sellingPrice}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                      fontSize: 18,
                    ),
                  ),
                if (medicine.pricing.discountPercentage != null &&
                    medicine.pricing.discountPercentage! > 0)
                  Text(
                    '${medicine.pricing.discountPercentage}% off',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.lightText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
