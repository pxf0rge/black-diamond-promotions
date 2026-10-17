import '../../models/cart_item_model.dart';
import '../abstract/cart_data_source.dart';
import '../../storage/storage_service.dart';

class HiveCartDataSource implements CartDataSource {
  HiveCartDataSource(this._storage);

  final StorageService _storage;

  String _cartKey(String eventId) => 'cart_$eventId';
  String _discountKey(String eventId) => 'discount_$eventId';

  @override
  Future<List<CartItemModel>> getItems(String eventId) async {
    final raw = _storage.meta.get(_cartKey(eventId));
    if (raw is List) {
      return raw.cast<CartItemModel>();
    }
    return [];
  }

  @override
  Future<void> saveItems(String eventId, List<CartItemModel> items) async {
    await _storage.meta.put(_cartKey(eventId), items);
  }

  @override
  Future<void> clear(String eventId) async {
    await _storage.meta.delete(_cartKey(eventId));
    await _storage.meta.delete(_discountKey(eventId));
  }

  @override
  Future<double> getDiscount(String eventId) async {
    final value = _storage.meta.get(_discountKey(eventId));
    if (value is num) return value.toDouble();
    return 0;
  }

  @override
  Future<void> setDiscount(String eventId, double discount) async {
    await _storage.meta.put(_discountKey(eventId), discount);
  }
}
