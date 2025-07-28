import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/store_owner/store_owner_bloc.dart';

class ProfileDetails extends StatelessWidget {
  const ProfileDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreOwnerBloc, StoreOwnerState>(
      builder: (context, state) {
        final owner = state.currentOwner;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shop Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _DetailCard(
              icon: Icons.store,
              title: 'Shop Name',
              value: owner?.shopDetails.shopName ?? 'ArogyaLoop Pharmacy',
            ),
            const SizedBox(height: 12),
            _DetailCard(
              icon: Icons.person,
              title: 'Owner Name',
              value: owner?.ownerName ?? 'John Doe',
            ),
            const SizedBox(height: 12),
            _DetailCard(
              icon: Icons.email,
              title: 'Email',
              value: owner?.email ?? 'john.doe@example.com',
            ),
            const SizedBox(height: 12),
            _DetailCard(
              icon: Icons.phone,
              title: 'Phone',
              value:   '+91 9876543210',
            ),
            const SizedBox(height: 12),
            _DetailCard(
              icon: Icons.location_on,
              title: 'Address',
              value: owner?.shopDetails.shopAddress.street ?? '123 Main Street, City, State 12345',
            ),
            const SizedBox(height: 12),
            _DetailCard(
              icon: Icons.badge,
              title: 'License Number',
              value: owner?.shopDetails.licenseNumber ?? 'PH-2024-001234',
            ),
            const SizedBox(height: 12),
            _DetailCard(
              icon: Icons.calendar_today,
              title: 'Member Since',
              value: owner?.createdAt != null
                  ? '${owner!.createdAt!.day}/${owner!.createdAt!.month}/${owner!.createdAt!.year}'
                  : '15/01/2024',
            ),
          ],
        );
      },
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
