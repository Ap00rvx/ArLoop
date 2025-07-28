import 'package:flutter/material.dart';

class DynamicShopStatusIndicator extends StatefulWidget {
  const DynamicShopStatusIndicator({super.key});

  @override
  State<DynamicShopStatusIndicator> createState() =>
      _DynamicShopStatusIndicatorState();
}

class _DynamicShopStatusIndicatorState
    extends State<DynamicShopStatusIndicator> {
  bool _isShopOpen = true;

  @override
  void initState() {
    super.initState();
    _updateShopStatus();
  }

  void _updateShopStatus() {
    final now = DateTime.now();
    setState(() {
      // Auto-close shop after 10 PM or before 8 AM for demo
      _isShopOpen = now.hour >= 8 && now.hour < 22;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = _isShopOpen ? Colors.green : Colors.red;
    String statusText = _isShopOpen ? 'Open' : 'Closed';
    IconData statusIcon = _isShopOpen ? Icons.check_circle : Icons.cancel;

    return InkWell(
      onTap: () {
        setState(() {
          _isShopOpen = !_isShopOpen;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Shop status changed to ${_isShopOpen ? 'Open' : 'Closed'}',
            ),
            backgroundColor: _isShopOpen ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: statusColor.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, color: statusColor, size: 16),
            const SizedBox(width: 6),
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.touch_app,
              color: statusColor.withOpacity(0.7),
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}
