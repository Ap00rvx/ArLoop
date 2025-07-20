part of 'cart_bloc.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class InitialCartEvent extends CartEvent {}

class LoadCartEvent extends CartEvent {}

class AddToCartEvent extends CartEvent {
  final Medicine medicine;
  final int quantity;

  const AddToCartEvent(this.medicine, {this.quantity = 1});

  @override
  List<Object> get props => [medicine, quantity];
}

class RemoveFromCartEvent extends CartEvent {
  final String medicineId;

  const RemoveFromCartEvent(this.medicineId);

  @override
  List<Object> get props => [medicineId];
}

class UpdateQuantityEvent extends CartEvent {
  final String medicineId;
  final int quantity;

  const UpdateQuantityEvent(this.medicineId, this.quantity);

  @override
  List<Object> get props => [medicineId, quantity];
}

class ClearCartEvent extends CartEvent {}

class CheckMedicineInCartEvent extends CartEvent {
  final String medicineId;

  const CheckMedicineInCartEvent(this.medicineId);

  @override
  List<Object> get props => [medicineId];
}
