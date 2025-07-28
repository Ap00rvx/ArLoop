import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/store_owner/store_owner_bloc.dart';
import '../../../../theme/colors.dart';
import 'dynamic_shop_status_indicator.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreOwnerBloc, StoreOwnerState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.currentOwner?.ownerName ?? 'Store Owner',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (state.currentShop?.owner != null) ...[
                const SizedBox(height: 4),
                Text(
                  state.currentShop!.createdAt!.toLocal().toString().split(
                    ' ',
                  )[0],
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
              const SizedBox(height: 16),
              const DynamicShopStatusIndicator(),
            ],
          ),
        );
      },
    );
  }
}
