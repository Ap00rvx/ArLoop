import 'package:flutter/material.dart';
import '../../../../theme/colors.dart';

class NotificationsDialog extends StatelessWidget {
  final List<Map<String, dynamic>> demoOrders;

  const NotificationsDialog({super.key, required this.demoOrders});

  @override
  Widget build(BuildContext context) {
    final pendingOrders = demoOrders
        .where(
          (order) =>
              order['status'] == 'Pending' || order['status'] == 'Processing',
        )
        .toList();

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.notifications, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text('Notifications'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${pendingOrders.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: pendingOrders.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No pending notifications'),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: pendingOrders.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final order = pendingOrders[index];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: order['status'] == 'Pending'
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        order['status'] == 'Pending'
                            ? Icons.schedule
                            : Icons.loop,
                        color: order['status'] == 'Pending'
                            ? Colors.orange
                            : Colors.blue,
                      ),
                    ),
                    title: Text('Order ${order['id']}'),
                    subtitle: Text(
                      '${order['customerName']} - ₹${order['totalAmount']}',
                    ),
                    trailing: Text(
                      order['orderTime'],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
