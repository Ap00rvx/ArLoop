import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderId;
  final double totalAmount;

  const OrderTrackingPage({
    super.key,
    required this.orderId,
    required this.totalAmount,
  });

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _isDelivered = false;
  late AnimationController _deliveryController;
  late AnimationController _successController;

  final List<OrderStep> _orderSteps = [
    OrderStep(
      title: 'Order Confirmed',
      subtitle: 'Your order has been confirmed',
      icon: Icons.check_circle,
      isCompleted: true,
    ),
    OrderStep(
      title: 'Preparing Order',
      subtitle: 'Pharmacy is preparing your medicines',
      icon: Icons.local_pharmacy,
      isCompleted: false,
    ),
    OrderStep(
      title: 'Out for Delivery',
      subtitle: 'Your order is on the way',
      icon: Icons.delivery_dining,
      isCompleted: false,
    ),
    OrderStep(
      title: 'Delivered',
      subtitle: 'Order delivered successfully',
      icon: Icons.home,
      isCompleted: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _deliveryController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _startOrderProgress();
  }

  @override
  void dispose() {
    _deliveryController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _startOrderProgress() async {
    // Simulate order progress
    for (int i = 1; i < _orderSteps.length; i++) {
      await Future.delayed(const Duration(seconds: 4));
      if (mounted) {
        setState(() {
          _currentStep = i;
          _orderSteps[i].isCompleted = true;
        });

        if (i == _orderSteps.length - 1) {
          // Order delivered
          setState(() {
            _isDelivered = true;
          });
          _successController.forward();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Track Order',
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Order Info Card
              _buildOrderInfoCard(),

              const SizedBox(height: 24),

              // Delivery Status
              if (_isDelivered) _buildDeliveredCard() else _buildTrackingCard(),

              const SizedBox(height: 24),

              // Order Steps
              _buildOrderSteps(),

              const SizedBox(height: 24),

              // Delivery Person Info (when out for delivery)
              if (_currentStep >= 2 && !_isDelivered)
                _buildDeliveryPersonCard(),

              const SizedBox(height: 24),

              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _isDelivered
                      ? AppColors.success.withOpacity(0.1)
                      : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isDelivered ? 'Delivered' : 'In Progress',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isDelivered ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.receipt, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Order ID: ${widget.orderId}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.currency_rupee,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Total: ₹${widget.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Ordered: ${DateTime.now().toString().substring(0, 16)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.lightText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 2),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.rotate(
                  angle: value * 6.28, // 2π radians = full rotation
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.textOnPrimary.withOpacity(0.2),
                    ),
                    child: const Icon(
                      Icons.delivery_dining,
                      size: 40,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _orderSteps[_currentStep].title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _orderSteps[_currentStep].subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (_currentStep >= 2 && !_isDelivered) ...[
            const Text(
              'Estimated Delivery Time',
              style: TextStyle(fontSize: 14, color: AppColors.textOnPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              '15-20 minutes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textOnPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeliveredCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 1),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.5 + (value * 0.5),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.textOnPrimary.withOpacity(0.2),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 60,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Order Delivered!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your medicines have been delivered successfully',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppColors.textOnPrimary),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.textOnPrimary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Thank you for choosing Arogya Loop!',
                  style: TextStyle(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSteps() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(_orderSteps.length, (index) {
            final step = _orderSteps[index];
            final isLast = index == _orderSteps.length - 1;

            return Row(
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: step.isCompleted
                            ? AppColors.success
                            : index == _currentStep
                            ? AppColors.primary
                            : AppColors.neutralGrey,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        step.isCompleted ? Icons.check : step.icon,
                        color: AppColors.textOnPrimary,
                        size: 20,
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        color: step.isCompleted
                            ? AppColors.success.withOpacity(0.3)
                            : AppColors.neutralGrey,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: step.isCompleted || index == _currentStep
                              ? AppColors.darkText
                              : AppColors.mutedText,
                        ),
                      ),
                      Text(
                        step.subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: step.isCompleted || index == _currentStep
                              ? AppColors.lightText
                              : AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDeliveryPersonCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Partner',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rajesh Kumar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                    const Text(
                      'Delivery Partner',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        const Text(
                          '4.8',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.phone, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_isDelivered) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue Shopping',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Rate order functionality
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Rate Your Experience',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                // Cancel order functionality
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel Order',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class OrderStep {
  final String title;
  final String subtitle;
  final IconData icon;
  bool isCompleted;

  OrderStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isCompleted,
  });
}
