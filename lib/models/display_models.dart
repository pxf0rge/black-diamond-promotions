import 'package:equatable/equatable.dart';

import 'product_model.dart';
import 'transaction_item_model.dart';
import 'transaction_model.dart';

/// UI-facing cart line used by widgets.
class CartLine extends Equatable {
  const CartLine({required this.product, required this.quantity});

  final ProductModel product;
  final int quantity;

  double get subtotal => product.price * quantity;

  @override
  List<Object?> get props => [product, quantity];
}

/// UI-facing category group with nested products.
class CategoryGroup extends Equatable {
  const CategoryGroup({
    required this.id,
    required this.name,
    required this.emoji,
    required this.products,
    this.isExpanded = false,
  });

  final String id;
  final String name;
  final String emoji;
  final List<ProductModel> products;
  final bool isExpanded;

  int get itemCount => products.length;

  CategoryGroup copyWith({
    String? id,
    String? name,
    String? emoji,
    List<ProductModel>? products,
    bool? isExpanded,
  }) {
    return CategoryGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      products: products ?? this.products,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  @override
  List<Object?> get props => [id, name, emoji, products, isExpanded];
}

/// UI-facing transaction with line items for display.
class TransactionView extends Equatable {
  const TransactionView({required this.transaction, required this.items});

  final TransactionModel transaction;
  final List<TransactionItemModel> items;

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  @override
  List<Object?> get props => [transaction, items];
}
