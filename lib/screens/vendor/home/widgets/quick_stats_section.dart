import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/shop/shop_bloc.dart';
import '../../../../theme/colors.dart';
import 'stat_card.dart';

class QuickStatsSection extends StatelessWidget {
  final List<Map<String, dynamic>> demoOrders;
  final List<Map<String, dynamic>> demoMedicines;

  const QuickStatsSection({
    super.key,
    required this.demoOrders,
    required this.demoMedicines,
  });

  @override
  Widget build(BuildContext context) {
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
                    child: StatCard(
                      title: 'Total Orders',
                      value: state.statistics!.metrics.totalOrders.toString(),
                      icon: Icons.shopping_cart,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Total Customers',
                      value:
                          '${state.statistics!.metrics.totalCustomers.toStringAsFixed(0)}',
                      icon: Icons.currency_rupee,
                      color: Colors.green,
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Orders',
                      value: '${demoOrders.length}',
                      icon: Icons.shopping_cart,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Revenue',
                      value:
                          '₹${demoOrders.fold(0.0, (sum, order) => sum + (order['totalAmount'] as double)).toStringAsFixed(0)}',
                      icon: Icons.currency_rupee,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Avg Rating',
                    value: '4.8',
                    icon: Icons.star,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Medicines',
                    value: demoMedicines.length.toString(),
                    icon: Icons.medication,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
