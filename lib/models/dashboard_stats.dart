import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  const DashboardStats({
    required this.todayRevenue,
    required this.transactions,
    required this.averageSale,
    required this.itemsSold,
    required this.cashRevenue,
    required this.venmoRevenue,
    required this.cardRevenue,
    required this.freeTransactions,
  });

  final double todayRevenue;
  final int transactions;
  final double averageSale;
  final int itemsSold;
  final double cashRevenue;
  final double venmoRevenue;
  final double cardRevenue;
  final int freeTransactions;

  @override
  List<Object?> get props => [
    todayRevenue,
    transactions,
    averageSale,
    itemsSold,
    cashRevenue,
    venmoRevenue,
    cardRevenue,
    freeTransactions,
  ];
}
