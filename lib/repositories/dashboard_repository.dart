import 'package:collection/collection.dart';

import '../core/enums/app_enums.dart';
import '../datasources/abstract/category_data_source.dart';
import '../datasources/abstract/product_data_source.dart';
import '../datasources/abstract/transaction_data_source.dart';
import '../models/dashboard_stats.dart';

class DashboardRepository {
  DashboardRepository(
    this._transactionSource,
    this._productSource,
    this._categorySource,
  );

  final TransactionDataSource _transactionSource;
  final ProductDataSource _productSource;
  final CategoryDataSource _categorySource;

  Future<DashboardStats> getTodayStats(String? eventId) async {
    final txns = await _transactionSource.search(
      eventId: eventId,
      dateFilter: DateFilterType.today,
    );

    final revenue = txns.fold(0.0, (sum, t) => sum + t.total);
    final count = txns.length;
    final average = count == 0 ? 0.0 : revenue / count;

    var itemsSold = 0;
    for (final txn in txns) {
      final items = await _transactionSource.getItemsByTransactionId(txn.id);
      itemsSold += items.fold(0, (sum, i) => sum + i.quantity);
    }

    double cash = 0, venmo = 0, card = 0;
    var freeCount = 0;
    for (final txn in txns) {
      switch (PaymentMethod.fromKey(txn.paymentMethod)) {
        case PaymentMethod.cash:
          cash += txn.total;
        case PaymentMethod.venmo:
          venmo += txn.total;
        case PaymentMethod.card:
          card += txn.total;
        case PaymentMethod.free:
          freeCount++;
      }
    }

    return DashboardStats(
      todayRevenue: revenue,
      transactions: count,
      averageSale: average,
      itemsSold: itemsSold,
      cashRevenue: cash,
      venmoRevenue: venmo,
      cardRevenue: card,
      freeTransactions: freeCount,
    );
  }

  Future<Map<PaymentMethod, double>> getPaymentBreakdown({
    String? eventId,
    DateFilterType dateFilter = DateFilterType.today,
  }) async {
    final txns = await _transactionSource.search(
      eventId: eventId,
      dateFilter: dateFilter,
    );
    final map = {for (final m in PaymentMethod.values) m: 0.0};
    for (final txn in txns) {
      final method = PaymentMethod.fromKey(txn.paymentMethod);
      map[method] = (map[method] ?? 0) + txn.total;
    }
    return map;
  }

  Future<List<double>> getHourlyRevenue({
    String? eventId,
    DateFilterType dateFilter = DateFilterType.today,
  }) async {
    final txns = await _transactionSource.search(
      eventId: eventId,
      dateFilter: dateFilter,
    );
    final hours = List<double>.filled(12, 0);
    for (final txn in txns) {
      final hour = txn.createdAt.hour;
      if (hour >= 8 && hour < 20) {
        hours[hour - 8] += txn.total;
      }
    }
    return hours;
  }

  Future<List<MapEntry<String, int>>> getTopCategories({
    String? eventId,
    DateFilterType dateFilter = DateFilterType.today,
  }) async {
    final txns = await _transactionSource.search(
      eventId: eventId,
      dateFilter: dateFilter,
    );
    final counts = <String, int>{};

    for (final txn in txns) {
      final items = await _transactionSource.getItemsByTransactionId(txn.id);
      for (final item in items) {
        final product = await _productSource.getById(item.productId);
        if (product == null) continue;
        final category = await _categorySource.getById(product.categoryId);
        final name = category?.name ?? 'Other';
        counts[name] = (counts[name] ?? 0) + item.quantity;
      }
    }

    return counts.entries.sortedBy((e) => -e.value);
  }

  Future<List<MapEntry<String, int>>> getTopProducts({
    String? eventId,
    DateFilterType dateFilter = DateFilterType.today,
  }) async {
    final txns = await _transactionSource.search(
      eventId: eventId,
      dateFilter: dateFilter,
    );
    final counts = <String, int>{};

    for (final txn in txns) {
      final items = await _transactionSource.getItemsByTransactionId(txn.id);
      for (final item in items) {
        counts[item.productName] =
            (counts[item.productName] ?? 0) + item.quantity;
      }
    }

    return counts.entries.sortedBy((e) => -e.value);
  }
}
