import 'package:flutter/material.dart';
import '../widgets/order_card.dart';

class AllOrdersDialog extends StatelessWidget {
  final List<Map<String, dynamic>> demoOrders;

  const AllOrdersDialog({super.key, required this.demoOrders});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'All Orders',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: demoOrders.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final order = demoOrders[index];
                  return OrderCard(order: order);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
