import '../../core/enums/app_enums.dart';
import '../../models/transaction_item_model.dart';
import '../../models/transaction_model.dart';
import '../abstract/transaction_data_source.dart';
import '../../storage/storage_service.dart';

class HiveTransactionDataSource implements TransactionDataSource {
  HiveTransactionDataSource(this._storage);

  final StorageService _storage;

  @override
  Future<List<TransactionModel>> getAll() async {
    return _storage.transactions.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<TransactionModel>> getByEventId(String eventId) async {
    return _storage.transactions.values
        .where((t) => t.eventId == eventId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<TransactionModel?> getById(String id) async =>
      _storage.transactions.get(id);

  @override
  Future<List<TransactionItemModel>> getItemsByTransactionId(
    String transactionId,
  ) async {
    return _storage.transactionItems.values
        .where((i) => i.transactionId == transactionId)
        .toList();
  }

  @override
  Future<TransactionModel> create(
    TransactionModel transaction,
    List<TransactionItemModel> items,
  ) async {
    await _storage.transactions.put(transaction.id, transaction);
    for (final item in items) {
      await _storage.transactionItems.put(item.id, item);
    }
    return transaction;
  }

  @override
  Future<TransactionModel> update(TransactionModel transaction) async {
    await _storage.transactions.put(transaction.id, transaction);
    return transaction;
  }

  @override
  Future<void> delete(String id) async {
    await _storage.transactions.delete(id);
    final keys = _storage.transactionItems.values
        .where((i) => i.transactionId == id)
        .map((i) => i.id)
        .toList();
    await _storage.transactionItems.deleteAll(keys);
  }

  @override
  Future<List<TransactionModel>> search({
    String? eventId,
    String? query,
    DateFilterType dateFilter = DateFilterType.all,
    DateTime? customStart,
    DateTime? customEnd,
    PaymentMethod? paymentMethod,
    TransactionSort sort = TransactionSort.newest,
  }) async {
    var results = await getAll();
    if (eventId != null) {
      results = results.where((t) => t.eventId == eventId).toList();
    }

    final range = _dateRange(dateFilter, customStart, customEnd);
    if (range != null) {
      results = results.where((t) {
        return !t.createdAt.isBefore(range.$1) &&
            !t.createdAt.isAfter(range.$2);
      }).toList();
    }

    if (paymentMethod != null) {
      results = results
          .where((t) => t.paymentMethod == paymentMethod.name)
          .toList();
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      final filtered = <TransactionModel>[];
      for (final txn in results) {
        if (txn.receiptNumber.toLowerCase().contains(q) ||
            txn.paymentMethod.toLowerCase().contains(q)) {
          filtered.add(txn);
          continue;
        }
        final items = await getItemsByTransactionId(txn.id);
        if (items.any((i) => i.productName.toLowerCase().contains(q))) {
          filtered.add(txn);
        }
      }
      results = filtered;
    }

    switch (sort) {
      case TransactionSort.newest:
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case TransactionSort.oldest:
        results.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case TransactionSort.highestTotal:
        results.sort((a, b) => b.total.compareTo(a.total));
      case TransactionSort.lowestTotal:
        results.sort((a, b) => a.total.compareTo(b.total));
    }

    return results;
  }

  (DateTime, DateTime)? _dateRange(
    DateFilterType filter,
    DateTime? customStart,
    DateTime? customEnd,
  ) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart
        .add(const Duration(days: 1))
        .subtract(const Duration(microseconds: 1));

    switch (filter) {
      case DateFilterType.all:
        return null;
      case DateFilterType.today:
        return (todayStart, todayEnd);
      case DateFilterType.yesterday:
        final start = todayStart.subtract(const Duration(days: 1));
        return (start, todayStart.subtract(const Duration(microseconds: 1)));
      case DateFilterType.last7Days:
        return (todayStart.subtract(const Duration(days: 6)), todayEnd);
      case DateFilterType.last30Days:
        return (todayStart.subtract(const Duration(days: 29)), todayEnd);
      case DateFilterType.custom:
        if (customStart == null || customEnd == null) return null;
        final end = DateTime(
          customEnd.year,
          customEnd.month,
          customEnd.day,
          23,
          59,
          59,
          999,
        );
        return (customStart, end);
    }
  }
}
