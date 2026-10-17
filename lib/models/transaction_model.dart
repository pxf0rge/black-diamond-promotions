import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '../core/enums/app_enums.dart';

part 'transaction_model.g.dart';

@HiveType(typeId: 4)
class TransactionModel extends HiveObject with EquatableMixin {
  TransactionModel({
    required this.id,
    required this.receiptNumber,
    required this.eventId,
    required this.paymentMethod,
    required this.total,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.createdAt,
    this.status = 'completed',
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String receiptNumber;

  @HiveField(2)
  final String eventId;

  @HiveField(3)
  final String paymentMethod;

  @HiveField(4)
  final double total;

  @HiveField(5)
  final double subtotal;

  @HiveField(6)
  final double tax;

  @HiveField(7)
  final double discount;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final String status;

  PaymentMethod get paymentMethodEnum => PaymentMethod.fromKey(paymentMethod);

  TransactionStatus get statusEnum {
    return TransactionStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => TransactionStatus.completed,
    );
  }

  TransactionModel copyWith({
    String? id,
    String? receiptNumber,
    String? eventId,
    String? paymentMethod,
    double? total,
    double? subtotal,
    double? tax,
    double? discount,
    DateTime? createdAt,
    String? status,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      eventId: eventId ?? this.eventId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      total: total ?? this.total,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'receiptNumber': receiptNumber,
    'eventId': eventId,
    'paymentMethod': paymentMethod,
    'total': total,
    'subtotal': subtotal,
    'tax': tax,
    'discount': discount,
    'createdAt': createdAt.toIso8601String(),
    'status': status,
  };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'] as String,
        receiptNumber: json['receiptNumber'] as String,
        eventId: json['eventId'] as String,
        paymentMethod: json['paymentMethod'] as String,
        total: (json['total'] as num).toDouble(),
        subtotal: (json['subtotal'] as num).toDouble(),
        tax: (json['tax'] as num).toDouble(),
        discount: (json['discount'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        status: json['status'] as String? ?? 'completed',
      );

  @override
  List<Object?> get props => [
    id,
    receiptNumber,
    eventId,
    paymentMethod,
    total,
    subtotal,
    tax,
    discount,
    createdAt,
    status,
  ];
}
