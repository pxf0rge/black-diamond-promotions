import 'package:uuid/uuid.dart';

import '../core/enums/app_enums.dart';
import '../core/errors/app_exception.dart';
import '../datasources/abstract/transaction_data_source.dart';
import '../models/display_models.dart';
import '../models/transaction_item_model.dart';
import '../models/transaction_model.dart';
import '../services/receipt_service.dart';
import 'cart_repository.dart';

class TransactionRepository {
  TransactionRepository(
    this._dataSource,
    this._cartRepository,
    this._receiptService, {
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final TransactionDataSource _dataSource;
  final CartRepository _cartRepository;
  final ReceiptService _receiptService;
  final Uuid _uuid;

  Future<List<TransactionView>> getRecentTransactions({
    String? eventId,
    String? query,
    DateFilterType dateFilter = DateFilterType.all,
    DateTime? customStart,
    DateTime? customEnd,
    PaymentMethod? paymentMethod,
    TransactionSort sort = TransactionSort.newest,
    int? limit,
  }) async {
    final txns = await _dataSource.search(
      eventId: eventId,
      query: query,
      dateFilter: dateFilter,
      customStart: customStart,
      customEnd: customEnd,
      paymentMethod: paymentMethod,
      sort: sort,
    );

    final limited = limit != null ? txns.take(limit).toList() : txns;
    final views = <TransactionView>[];
    for (final txn in limited) {
      final items = await _dataSource.getItemsByTransactionId(txn.id);
      views.add(TransactionView(transaction: txn, items: items));
    }
    return views;
  }

  Future<TransactionModel> completePayment({
    required String eventId,
    required PaymentMethod paymentMethod,
    required double taxRate,
  }) async {
    final lines = await _cartRepository.getCartLines(eventId);
    if (lines.isEmpty) {
      throw const ValidationException('Cart is empty');
    }

    final subtotal = await _cartRepository.getSubtotal(eventId);
    final discount = await _cartRepository.getDiscount(eventId);
    final tax = await _cartRepository.getTax(eventId, taxRate);
    final total = await _cartRepository.getGrandTotal(eventId, taxRate);

    if (total < 0) {
      throw const ValidationException('Invalid transaction total');
    }

    final receiptNumber = await _receiptService.generateNext();
    final txnId = _uuid.v4();
    final now = DateTime.now();

    final transaction = TransactionModel(
      id: txnId,
      receiptNumber: receiptNumber,
      eventId: eventId,
      paymentMethod: paymentMethod.name,
      total: total,
      subtotal: subtotal,
      tax: tax,
      discount: discount,
      createdAt: now,
    );

    final items = lines
        .map(
          (line) => TransactionItemModel(
            id: _uuid.v4(),
            transactionId: txnId,
            productId: line.product.id,
            productName: line.product.name,
            price: line.product.price,
            quantity: line.quantity,
            subtotal: line.subtotal,
          ),
        )
        .toList();

    final saved = await _dataSource.create(transaction, items);
    await _cartRepository.clear(eventId);
    return saved;
  }

  Future<List<TransactionItemModel>> getItems(String transactionId) =>
      _dataSource.getItemsByTransactionId(transactionId);

  Future<void> deleteTransaction(String id) => _dataSource.delete(id);

  Future<TransactionModel> updateTransaction({
    required String id,
    PaymentMethod? paymentMethod,
    double? discount,
  }) async {
    final existing = await _dataSource.getById(id);
    if (existing == null) {
      throw const ValidationException('Transaction not found');
    }

    final newDiscount = discount ?? existing.discount;
    if (newDiscount < 0) {
      throw const ValidationException('Discount cannot be negative');
    }

    final newTotal = existing.subtotal - newDiscount + existing.tax;
    if (newTotal < 0) {
      throw const ValidationException('Invalid transaction total');
    }

    final updated = existing.copyWith(
      paymentMethod: paymentMethod?.name ?? existing.paymentMethod,
      discount: newDiscount,
      total: newTotal,
    );
    return _dataSource.update(updated);
  }
}
