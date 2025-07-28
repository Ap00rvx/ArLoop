import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/store_owner/store_owner_bloc.dart';
import '../../../bloc/shop/shop_bloc.dart';
import '../../../bloc/medicine/medicine_bloc.dart';
import '../../../theme/colors.dart';
import 'components/dashboard_page.dart';
import 'components/announcements_page.dart';
import 'components/medicines_page.dart';
import 'components/profile_page.dart';
import 'widgets/vendor_app_bar.dart';

class VendorHome extends StatefulWidget {
  const VendorHome({super.key});

  @override
  State<VendorHome> createState() => _VendorHomeState();
}

class _VendorHomeState extends State<VendorHome> {
  int _currentIndex = 0;

  // Demo medicines data - Enhanced for demo
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
    {
      'name': 'Omeprazole 20mg',
      'category': 'Gastric',
      'price': 65.00,
      'stock': 80,
      'prescription': false,
      'image': 'assets/images/med.png',
    },
    {
      'name': 'Crocin Advance',
      'category': 'Pain Relief',
      'price': 28.00,
      'stock': 120,
      'prescription': false,
      'image': 'assets/images/med.png',
    },
    {
      'name': 'Azithromycin 500mg',
      'category': 'Antibiotic',
      'price': 95.00,
      'stock': 45,
      'prescription': true,
      'image': 'assets/images/med.png',
    },
  ];

  // Demo orders data for investor demo
  final List<Map<String, dynamic>> _demoOrders = [
    {
      'id': 'ORD001',
      'customerName': 'Rajesh Kumar',
      'customerPhone': '+91 98765 43210',
      'items': ['Paracetamol 500mg x2', 'Vitamin D3 x1'],
      'totalAmount': 171.00,
      'status': 'Pending',
      'orderTime': '2 hours ago',
      'deliveryAddress': 'MG Road, Bangalore',
      'paymentStatus': 'Paid',
    },
    {
      'id': 'ORD002',
      'customerName': 'Priya Sharma',
      'customerPhone': '+91 87654 32109',
      'items': ['Crocin Advance x1', 'Omeprazole 20mg x2'],
      'totalAmount': 158.00,
      'status': 'Processing',
      'orderTime': '4 hours ago',
      'deliveryAddress': 'Koramangala, Bangalore',
      'paymentStatus': 'Paid',
    },
    {
      'id': 'ORD003',
      'customerName': 'Amit Patel',
      'customerPhone': '+91 76543 21098',
      'items': ['Insulin 100IU x1', 'Aspirin 75mg x3'],
      'totalAmount': 495.00,
      'status': 'Delivered',
      'orderTime': '1 day ago',
      'deliveryAddress': 'Whitefield, Bangalore',
      'paymentStatus': 'Paid',
    },
    {
      'id': 'ORD004',
      'customerName': 'Sneha Reddy',
      'customerPhone': '+91 65432 10987',
      'items': ['Azithromycin 500mg x1', 'Paracetamol 500mg x1'],
      'totalAmount': 120.50,
      'status': 'Ready for Pickup',
      'orderTime': '30 minutes ago',
      'deliveryAddress': 'HSR Layout, Bangalore',
      'paymentStatus': 'COD',
    },
    {
      'id': 'ORD005',
      'customerName': 'Vikram Singh',
      'customerPhone': '+91 54321 09876',
      'items': ['Amoxicillin 250mg x2', 'Vitamin D3 x1'],
      'totalAmount': 290.00,
      'status': 'Cancelled',
      'orderTime': '6 hours ago',
      'deliveryAddress': 'Indiranagar, Bangalore',
      'paymentStatus': 'Refunded',
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

  // Get different pages based on bottom nav selection
  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return DashboardPage(
          demoOrders: _demoOrders,
          demoMedicines: _demoMedicines,
        );
      case 1:
        return const AnnouncementsPage();
      case 2:
        return const MedicinesPage();
      case 3:
        return const ProfilePage();
      default:
        return DashboardPage(
          demoOrders: _demoOrders,
          demoMedicines: _demoMedicines,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: VendorAppBar(
        title: 'Vendor Dashboard',
        currentIndex: _currentIndex,
        demoOrders: _demoOrders,
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
              // Handle medicine bloc state changes if needed
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
}
