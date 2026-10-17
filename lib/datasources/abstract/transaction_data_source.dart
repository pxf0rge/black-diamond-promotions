import '../../core/enums/app_enums.dart';
import '../../models/transaction_item_model.dart';
import '../../models/transaction_model.dart';

abstract class TransactionDataSource {
  Future<List<TransactionModel>> getAll();
  Future<List<TransactionModel>> getByEventId(String eventId);
  Future<TransactionModel?> getById(String id);
  Future<List<TransactionItemModel>> getItemsByTransactionId(
    String transactionId,
  );
  Future<TransactionModel> create(
    TransactionModel transaction,
    List<TransactionItemModel> items,
  );
  Future<TransactionModel> update(TransactionModel transaction);
  Future<void> delete(String id);
  Future<List<TransactionModel>> search({
    String? eventId,
    String? query,
    DateFilterType dateFilter,
    DateTime? customStart,
    DateTime? customEnd,
    PaymentMethod? paymentMethod,
    TransactionSort sort,
  });
}
