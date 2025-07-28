import 'package:flutter/material.dart';
import '../../../../theme/colors.dart';
import '../dialogs/all_orders_dialog.dart';
import 'order_card.dart';

class RecentOrdersSection extends StatelessWidget {
  final List<Map<String, dynamic>> demoOrders;

  const RecentOrdersSection({super.key, required this.demoOrders});

  void _showAllOrdersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AllOrdersDialog(demoOrders: demoOrders),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAllOrdersDialog(context),
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: demoOrders.length > 5 ? 5 : demoOrders.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final order = demoOrders[index];
              return OrderCard(order: order);
            },
          ),
        ),
      ],
    );
  }
}
