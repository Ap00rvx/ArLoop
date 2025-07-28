import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../theme/colors.dart';
import '../../services/cart_service.dart';
import '../tracking/order_tracking_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with TickerProviderStateMixin {
  bool _isEmergencyDelivery = false;
  bool _isProcessingOrder = false;
  bool _isOrderPlaced = false;

  late AnimationController _processingController;
  late AnimationController _successController;

  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedPaymentMethod = 'cash_on_delivery';
  String _orderEstimateTime = '30-45 minutes';
  double _deliveryCharges = 0.0;
  double _emergencyCharges = 0.0;

  @override
  void initState() {
    super.initState();
    _processingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _successController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _calculateDeliveryCharges();
  }

  @override
  void dispose() {
    _processingController.dispose();
    _successController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateDeliveryCharges() {
    setState(() {
      if (_isEmergencyDelivery) {
        _emergencyCharges = 50.0;
        _orderEstimateTime = '10-15 minutes';
      } else {
        _emergencyCharges = 0.0;
        _orderEstimateTime = '30-45 minutes';
      }
    });
  }

  double get _totalOrderAmount =>
      widget.totalAmount + _deliveryCharges + _emergencyCharges;

  @override
  Widget build(BuildContext context) {
    if (_isOrderPlaced) {
      return _buildOrderSuccessPage();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: AppColors.textOnPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        elevation: 0,
      ),
      body: _isProcessingOrder ? _buildProcessingView() : _buildCheckoutForm(),
      bottomNavigationBar: _isProcessingOrder
          ? null
          : _buildCheckoutBottomBar(),
    );
  }

  Widget _buildProcessingView() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Lottie.network(
                'https://assets6.lottiefiles.com/packages/lf20_zyiqohte.json',
                controller: _processingController,
                onLoaded: (composition) {
                  _processingController.duration = composition.duration;
                  _processingController.repeat();
                },
                errorBuilder: (context, error, stackTrace) {
                  return const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    strokeWidth: 3,
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Processing Your Order',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isEmergencyDelivery
                  ? 'Preparing for emergency delivery...'
                  : 'Confirming your order with pharmacy...',
              style: const TextStyle(fontSize: 16, color: AppColors.lightText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        _isEmergencyDelivery
                            ? Icons.local_shipping
                            : Icons.access_time,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Estimated Delivery: $_orderEstimateTime',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkText,
                        ),
                      ),
                    ],
                  ),
                  if (_isEmergencyDelivery) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.emergency,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Emergency Delivery Activated',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSuccessPage() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  child: Lottie.network(
                    'https://assets9.lottiefiles.com/packages/lf20_s2lryxtd.json',
                    controller: _successController,
                    onLoaded: (composition) {
                      _successController.duration = composition.duration;
                      _successController.forward();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          size: 100,
                          color: AppColors.success,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Order Placed Successfully!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Order ID: #ARG${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isEmergencyDelivery
                                ? Icons.emergency
                                : Icons.access_time,
                            color: _isEmergencyDelivery
                                ? AppColors.error
                                : AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Expected Delivery: $_orderEstimateTime',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.lightText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _isEmergencyDelivery
                      ? 'Your emergency order is being prepared with highest priority. You will receive updates via SMS.'
                      : 'Your order has been confirmed and is being prepared. You will receive updates via SMS.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.lightText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Items Total', widget.totalAmount),
                      _buildSummaryRow('Delivery Charges', _deliveryCharges),
                      if (_isEmergencyDelivery)
                        _buildSummaryRow(
                          'Emergency Charges',
                          _emergencyCharges,
                        ),
                      const Divider(color: AppColors.border),
                      _buildSummaryRow(
                        'Total Amount',
                        _totalOrderAmount,
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // TODO: Navigate to order tracking
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Order tracking will be available soon',
                              ),
                              backgroundColor: AppColors.info,
                            ),
                          );
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
                          'Track Order',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Order Summary Card
          _buildOrderSummaryCard(),
          const SizedBox(height: 20),

          // Emergency Delivery Option
          _buildEmergencyDeliveryCard(),
          const SizedBox(height: 20),

          // Delivery Address
          _buildDeliveryAddressCard(),
          const SizedBox(height: 20),

          // Payment Method
          _buildPaymentMethodCard(),
          const SizedBox(height: 20),

          // Order Notes
          _buildOrderNotesCard(),
          const SizedBox(height: 20),
          // terms and conditions
          const Text(
            'By placing this order, you agree to our terms and conditions.',
            style: TextStyle(fontSize: 12, color: AppColors.mutedText),
          ),
          const SizedBox(height: 30), // Space for bottom bar
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(12),
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
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.cartItems.map((item) => _buildOrderItem(item)),
          const Divider(color: AppColors.border),
          const SizedBox(height: 8),
          _buildSummaryRow('Subtotal', widget.totalAmount),
          _buildSummaryRow('Delivery Charges', _deliveryCharges),
          if (_isEmergencyDelivery)
            _buildSummaryRow('Emergency Charges', _emergencyCharges),
          const SizedBox(height: 8),
          const Divider(color: AppColors.border),
          _buildSummaryRow('Total', _totalOrderAmount, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.neutralGrey,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.medical_services,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.medicine.medicineName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Qty: ${item.quantity}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${(item.medicine.pricing.sellingPrice * item.quantity).toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyDeliveryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isEmergencyDelivery
              ? AppColors.error.withOpacity(0.3)
              : AppColors.border,
        ),
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
            children: [
              Icon(Icons.emergency, color: AppColors.error, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Emergency Delivery',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Get your medicines delivered in 10-15 minutes for urgent medical needs.',
            style: TextStyle(fontSize: 14, color: AppColors.lightText),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.error, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Additional ₹50 charges apply for emergency delivery',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(
              _isEmergencyDelivery
                  ? 'Emergency Delivery Enabled'
                  : 'Enable Emergency Delivery',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _isEmergencyDelivery
                    ? AppColors.error
                    : AppColors.darkText,
              ),
            ),
            subtitle: Text(
              _isEmergencyDelivery ? '10-15 minutes' : '30-45 minutes',
              style: const TextStyle(fontSize: 12, color: AppColors.mutedText),
            ),
            value: _isEmergencyDelivery,
            onChanged: (value) {
              setState(() {
                _isEmergencyDelivery = value;
                _calculateDeliveryCharges();
              });
            },
            activeColor: AppColors.error,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(12),
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
          const Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'Delivery Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _addressController,
            decoration: InputDecoration(
              hintText: 'Enter your complete address',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              hintText: 'Phone number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.all(12),
              prefixIcon: const Icon(Icons.phone, color: AppColors.primary),
            ),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(12),
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
          const Row(
            children: [
              Icon(Icons.payment, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RadioListTile<String>(
            title: const Text('Cash on Delivery'),
            subtitle: const Text('Pay when you receive your order'),
            value: 'cash_on_delivery',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<String>(
            title: const Text('UPI Payment'),
            subtitle: const Text('Pay now using UPI'),
            value: 'upi',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<String>(
            title: const Text('Card Payment'),
            subtitle: const Text('Pay using debit/credit card'),
            value: 'card',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderNotesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(12),
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
          const Row(
            children: [
              Icon(Icons.note_alt, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'Special Instructions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText:
                  'Any special instructions for the delivery person (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: isTotal
            ? EdgeInsets.symmetric(horizontal: 16, vertical: 12)
            : EdgeInsets.zero,
        decoration: isTotal
            ? BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              )
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
                color: AppColors.darkText,
              ),
            ),
            Text(
              amount == 0 && label.contains('Delivery')
                  ? 'FREE'
                  : '₹${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
                color: amount == 0 && label.contains('Delivery')
                    ? AppColors.success
                    : isTotal
                    ? AppColors.primary
                    : AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        boxShadow: [
          BoxShadow(
            color: AppColors.darkText.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total: ₹${_totalOrderAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  'Delivery: $_orderEstimateTime',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isEmergencyDelivery
                    ? AppColors.error
                    : AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isEmergencyDelivery) ...[
                    const Icon(Icons.emergency, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    _isEmergencyDelivery ? 'Emergency Order' : 'Place Order',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _placeOrder() async {
    // Basic validation
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter delivery address'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter phone number'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isProcessingOrder = true;
    });

    // Simulate order processing
    await Future.delayed(const Duration(seconds: 3));

    // Clear cart after successful order
    if (mounted) {
      context.read<CartBloc>().add(ClearCartEvent());
    }

    setState(() {
      _isProcessingOrder = false;
      _isOrderPlaced = true;
    });

    // Navigate to order tracking page after a short delay
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => OrderTrackingPage(
            orderId:
                'ARG${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
            totalAmount: _totalOrderAmount,
          ),
        ),
      );
    }
  }
}
