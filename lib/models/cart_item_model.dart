import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'cart_item_model.g.dart';

@HiveType(typeId: 3)
class CartItemModel extends HiveObject with EquatableMixin {
  CartItemModel({
    required this.productId,
    required this.quantity,
    required this.subtotal,
  });

  @HiveField(0)
  final String productId;

  @HiveField(1)
  final int quantity;

  @HiveField(2)
  final double subtotal;

  CartItemModel copyWith({String? productId, int? quantity, double? subtotal}) {
    return CartItemModel(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  List<Object?> get props => [productId, quantity, subtotal];
}
