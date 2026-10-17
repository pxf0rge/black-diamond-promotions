import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'transaction_item_model.g.dart';

@HiveType(typeId: 5)
class TransactionItemModel extends HiveObject with EquatableMixin {
  TransactionItemModel({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String transactionId;

  @HiveField(2)
  final String productId;

  @HiveField(3)
  final String productName;

  @HiveField(4)
  final double price;

  @HiveField(5)
  final int quantity;

  @HiveField(6)
  final double subtotal;

  Map<String, dynamic> toJson() => {
    'id': id,
    'transactionId': transactionId,
    'productId': productId,
    'productName': productName,
    'price': price,
    'quantity': quantity,
    'subtotal': subtotal,
  };

  factory TransactionItemModel.fromJson(Map<String, dynamic> json) =>
      TransactionItemModel(
        id: json['id'] as String,
        transactionId: json['transactionId'] as String,
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        price: (json['price'] as num).toDouble(),
        quantity: json['quantity'] as int,
        subtotal: (json['subtotal'] as num).toDouble(),
      );

  @override
  List<Object?> get props => [
    id,
    transactionId,
    productId,
    productName,
    price,
    quantity,
    subtotal,
  ];
}
