import 'dart:async';
import 'package:arloop/bloc/store_owner/store_owner_bloc.dart';
import 'package:arloop/router/route_names.dart';
import 'package:arloop/screens/vendor/home/dialogs/notifications_dialog.dart';
import 'package:arloop/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';


class VendorAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final int currentIndex;
  final List<Map<String, dynamic>> demoOrders;

  const VendorAppBar({
    super.key,
    required this.title,
    required this.currentIndex,
    required this.demoOrders,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<VendorAppBar> createState() => _VendorAppBarState();
}

class _VendorAppBarState extends State<VendorAppBar> {
  bool _isShopOpen = true;
  String _currentTime = DateTime.now()
      .toLocal()
      .toString()
      .split(' ')[1]
      .substring(0, 5);

  @override
  void initState() {
    super.initState();
    _updateCurrentTime();
    // Update time every minute
    Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        _updateCurrentTime();
      }
    });
  }

  void _updateCurrentTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      // Auto-close shop after 10 PM or before 8 AM for demo
      _isShopOpen = now.hour >= 8 && now.hour < 22;
    });
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => NotificationsDialog(demoOrders: widget.demoOrders),
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Announcements';
      case 2:
        return 'Medicines';
      case 3:
        return 'Profile';
      default:
        return 'ArLoop Vendor';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      title: Row(
        children: [
          // ArogyaLoop Logo
          Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/arloop_logo_raw.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.local_pharmacy,
                    color: AppColors.primary,
                    size: 20,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getPageTitle(widget.currentIndex),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'ArogyaLoop Vendor',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Shop Status Toggle
        InkWell(
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
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _isShopOpen ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isShopOpen ? Icons.store : Icons.store_outlined,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  _isShopOpen ? 'Open' : 'Closed',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Time Display
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            _currentTime,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        // Notifications with badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: _showNotificationsDialog,
            ),
            if (widget.demoOrders
                .where(
                  (order) =>
                      order['status'] == 'Pending' ||
                      order['status'] == 'Processing',
                )
                .isNotEmpty)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '${widget.demoOrders.where((order) => order['status'] == 'Pending' || order['status'] == 'Processing').length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        if (widget.currentIndex == 3) // Only show logout on profile page
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<StoreOwnerBloc>().add(LogoutStoreOwnerEvent());
              context.goNamed(RouteNames.splash);
            },
          ),
      ],
    );
  }
}
