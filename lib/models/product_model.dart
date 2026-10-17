import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'product_model.g.dart';

@HiveType(typeId: 2)
class ProductModel extends HiveObject with EquatableMixin {
  ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.isFree,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final bool isFree;

  @HiveField(5)
  final int sortOrder;

  @HiveField(6)
  final bool isActive;

  @HiveField(7)
  final DateTime createdAt;

  ProductModel copyWith({
    String? id,
    String? categoryId,
    String? name,
    double? price,
    bool? isFree,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      price: price ?? this.price,
      isFree: isFree ?? this.isFree,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'name': name,
    'price': price,
    'isFree': isFree,
    'sortOrder': sortOrder,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'] as String,
    categoryId: json['categoryId'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
    isFree: json['isFree'] as bool,
    sortOrder: json['sortOrder'] as int,
    isActive: json['isActive'] as bool,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  @override
  List<Object?> get props => [
    id,
    categoryId,
    name,
    price,
    isFree,
    sortOrder,
    isActive,
    createdAt,
  ];
}
