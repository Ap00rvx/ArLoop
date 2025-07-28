import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/store_owner/store_owner_bloc.dart';
import '../../../../theme/colors.dart';

class ShopDetailsSection extends StatelessWidget {
  const ShopDetailsSection({super.key});

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreOwnerBloc, StoreOwnerState>(
      builder: (context, state) {
        final shop = state.currentShop;
        final storeOwner = state.currentOwner;
        if (shop == null || storeOwner == null) {
          return const SizedBox.shrink();
        }

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
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    Icons.store,
                    'Name',
                    storeOwner.shopDetails.shopName,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.phone, 'Phone', storeOwner.phone),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.location_on,
                    'Address',
                    '${storeOwner.shopDetails.shopAddress.street}, ${storeOwner.shopDetails.shopAddress.city}, ${storeOwner.shopDetails.shopAddress.state}, ${storeOwner.shopDetails.shopAddress.pincode}',
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.access_time,
                    'Working Hours',
                    '${storeOwner.shopDetails.workingHours.openTime} - ${storeOwner.shopDetails.workingHours.closeTime}',
                  ),
                  if (storeOwner
                      .shopDetails
                      .workingHours
                      .workingDays
                      .isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Working Days',
                      storeOwner.shopDetails.workingHours.workingDays.join(
                        ', ',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
