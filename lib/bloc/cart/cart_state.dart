part of 'cart_bloc.dart';

enum CartStatus { initial, loading, success, failure }

class CartState extends Equatable {
  final CartStatus status;
  final List<CartItem> cartItems;
  final int totalItems;
  final double totalAmount;
  final String? errorMessage;

  const CartState({
    this.status = CartStatus.initial,
    this.cartItems = const [],
    this.totalItems = 0,
    this.totalAmount = 0.0,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    status,
    cartItems,
    totalItems,
    totalAmount,
    errorMessage,
  ];

  bool get isInitial => status == CartStatus.initial;
  bool get isLoading => status == CartStatus.loading;
  bool get isSuccess => status == CartStatus.success;
  bool get isFailure => status == CartStatus.failure;
  bool get isEmpty => cartItems.isEmpty;

  CartState copyWith({
    CartStatus? status,
    List<CartItem>? cartItems,
    int? totalItems,
    double? totalAmount,
    String? errorMessage,
  }) {
    return CartState(
      status: status ?? this.status,
      cartItems: cartItems ?? this.cartItems,
      totalItems: totalItems ?? this.totalItems,
      totalAmount: totalAmount ?? this.totalAmount,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool isInCart(String medicineId) {
    return cartItems.any((item) => item.medicine.id == medicineId);
  }

  int getMedicineQuantity(String medicineId) {
    try {
      final item = cartItems.firstWhere(
        (item) => item.medicine.id == medicineId,
      );
      return item.quantity;
    } catch (e) {
      // Item not found in cart
      return 0;
    }
  }
}
