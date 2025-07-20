import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/medicine_response.dart';
import '../../services/cart_service.dart';

part 'cart_events.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartService _cartService;

  CartBloc({required CartService cartService})
    : _cartService = cartService,
      super(const CartState()) {
    on<InitialCartEvent>(_onInitialCart);
    on<LoadCartEvent>(_onLoadCart);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<ClearCartEvent>(_onClearCart);
    on<CheckMedicineInCartEvent>(_onCheckMedicineInCart);
  }

  Future<void> _onInitialCart(
    InitialCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      final cartItems = await _cartService.getCartItems();
      final totalItems = await _cartService.getCartItemCount();
      final totalAmount = await _cartService.getCartTotal();
      print("Cart items loaded: ${cartItems.length}");

      emit(
        state.copyWith(
          status: CartStatus.success,
          cartItems: cartItems,
          totalItems: totalItems,
          totalAmount: totalAmount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CartStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onLoadCart(LoadCartEvent event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      final cartItems = await _cartService.getCartItems();
      final totalItems = await _cartService.getCartItemCount();
      final totalAmount = await _cartService.getCartTotal();
      print("Cart items loaded: ${cartItems.length}");
      print("Cart items loaded: ${totalAmount}");
      print("Cart items loaded: ${cartItems}");

      emit(
        state.copyWith(
          status: CartStatus.success,
          cartItems: cartItems,
          totalItems: totalItems,
          totalAmount: totalAmount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CartStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAddToCart(
    AddToCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      await _cartService.addToCart(event.medicine, quantity: event.quantity);

      final cartItems = await _cartService.getCartItems();
      final totalItems = await _cartService.getCartItemCount();
      final totalAmount = await _cartService.getCartTotal();

      emit(
        state.copyWith(
          status: CartStatus.success,
          cartItems: cartItems,
          totalItems: totalItems,
          totalAmount: totalAmount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CartStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onRemoveFromCart(
    RemoveFromCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      await _cartService.removeFromCart(event.medicineId);

      final cartItems = await _cartService.getCartItems();
      final totalItems = await _cartService.getCartItemCount();
      final totalAmount = await _cartService.getCartTotal();

      emit(
        state.copyWith(
          status: CartStatus.success,
          cartItems: cartItems,
          totalItems: totalItems,
          totalAmount: totalAmount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CartStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUpdateQuantity(
    UpdateQuantityEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      await _cartService.updateQuantity(event.medicineId, event.quantity);

      final cartItems = await _cartService.getCartItems();
      final totalItems = await _cartService.getCartItemCount();
      final totalAmount = await _cartService.getCartTotal();

      emit(
        state.copyWith(
          status: CartStatus.success,
          cartItems: cartItems,
          totalItems: totalItems,
          totalAmount: totalAmount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CartStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CartStatus.loading));
    try {
      await _cartService.clearCart();

      emit(
        state.copyWith(
          status: CartStatus.success,
          cartItems: [],
          totalItems: 0,
          totalAmount: 0.0,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CartStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onCheckMedicineInCart(
    CheckMedicineInCartEvent event,
    Emitter<CartState> emit,
  ) async {
    try {
      final isInCart = await _cartService.isInCart(event.medicineId);
      final quantity = await _cartService.getMedicineQuantity(event.medicineId);

      // Update state without changing loading status
      emit(state.copyWith(status: CartStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: CartStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
