import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/store_owner/store_owner_bloc.dart';
import '../../../../bloc/shop/shop_bloc.dart';
import '../../../../theme/colors.dart';
import '../widgets/welcome_section.dart';
import '../widgets/quick_stats_section.dart';
import '../widgets/recent_orders_section.dart';
import '../widgets/shop_details_section.dart';
import '../widgets/quick_actions_section.dart';

class DashboardPage extends StatelessWidget {
  final List<Map<String, dynamic>> demoOrders;
  final List<Map<String, dynamic>> demoMedicines;

  const DashboardPage({
    super.key,
    required this.demoOrders,
    required this.demoMedicines,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WelcomeSection(),
          const SizedBox(height: 20),
          QuickStatsSection(
            demoOrders: demoOrders,
            demoMedicines: demoMedicines,
          ),
          const SizedBox(height: 20),
          RecentOrdersSection(demoOrders: demoOrders),
          const SizedBox(height: 20),
          const ShopDetailsSection(),
          const SizedBox(height: 20),
          const QuickActionsSection(),
        ],
      ),
    );
  }
}
