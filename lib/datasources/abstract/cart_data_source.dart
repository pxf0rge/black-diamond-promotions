import '../../models/cart_item_model.dart';

abstract class CartDataSource {
  Future<List<CartItemModel>> getItems(String eventId);
  Future<void> saveItems(String eventId, List<CartItemModel> items);
  Future<void> clear(String eventId);
  Future<double> getDiscount(String eventId);
  Future<void> setDiscount(String eventId, double discount);
}
