import '../core/errors/app_exception.dart';
import '../datasources/abstract/cart_data_source.dart';
import '../datasources/abstract/product_data_source.dart';
import '../models/cart_item_model.dart';
import '../models/display_models.dart';
import '../models/product_model.dart';

class CartRepository {
  CartRepository(this._cartSource, this._productSource);

  final CartDataSource _cartSource;
  final ProductDataSource _productSource;

  Future<List<CartLine>> getCartLines(String eventId) async {
    final items = await _cartSource.getItems(eventId);
    final lines = <CartLine>[];
    for (final item in items) {
      final product = await _productSource.getById(item.productId);
      if (product != null && product.isActive) {
        lines.add(CartLine(product: product, quantity: item.quantity));
      }
    }
    return lines;
  }

  Future<double> getSubtotal(String eventId) async {
    final lines = await getCartLines(eventId);
    return lines.fold<double>(0.0, (sum, line) => sum + line.subtotal);
  }

  Future<double> getDiscount(String eventId) =>
      _cartSource.getDiscount(eventId);

  Future<double> getTax(String eventId, double taxRate) async {
    final subtotal = await getSubtotal(eventId);
    final discount = await getDiscount(eventId);
    return (subtotal - discount) * (taxRate / 100);
  }

  Future<double> getGrandTotal(String eventId, double taxRate) async {
    final subtotal = await getSubtotal(eventId);
    final discount = await getDiscount(eventId);
    final tax = await getTax(eventId, taxRate);
    final total = subtotal - discount + tax;
    if (total < 0) {
      throw const ValidationException('Invalid cart total');
    }
    return total;
  }

  Future<void> addProduct(String eventId, ProductModel product) async {
    final items = await _cartSource.getItems(eventId);
    final map = {for (final i in items) i.productId: i};
    final existing = map[product.id];
    final qty = (existing?.quantity ?? 0) + 1;
    map[product.id] = CartItemModel(
      productId: product.id,
      quantity: qty,
      subtotal: product.price * qty,
    );
    await _cartSource.saveItems(eventId, map.values.toList());
  }

  Future<void> increment(String eventId, String productId) async {
    final product = await _productSource.getById(productId);
    if (product == null) return;
    await addProduct(eventId, product);
  }

  Future<void> decrement(String eventId, String productId) async {
    final items = await _cartSource.getItems(eventId);
    final map = {for (final i in items) i.productId: i};
    final existing = map[productId];
    if (existing == null) return;

    final product = await _productSource.getById(productId);
    if (product == null) return;

    if (existing.quantity <= 1) {
      map.remove(productId);
    } else {
      final qty = existing.quantity - 1;
      map[productId] = CartItemModel(
        productId: productId,
        quantity: qty,
        subtotal: product.price * qty,
      );
    }
    await _cartSource.saveItems(eventId, map.values.toList());
  }

  Future<void> removeItem(String eventId, String productId) async {
    final items = await _cartSource.getItems(eventId);
    final updated = items.where((i) => i.productId != productId).toList();
    await _cartSource.saveItems(eventId, updated);
  }

  Future<void> setDiscount(String eventId, double discount) async {
    if (discount < 0) {
      throw const ValidationException('Discount cannot be negative');
    }
    await _cartSource.setDiscount(eventId, discount);
  }

  Future<void> clear(String eventId) => _cartSource.clear(eventId);

  Future<int> getTotalItems(String eventId) async {
    final items = await _cartSource.getItems(eventId);
    return items.fold<int>(0, (sum, i) => sum + i.quantity);
  }

  Future<int> getQuantity(String eventId, String productId) async {
    final items = await _cartSource.getItems(eventId);
    return items
        .where((i) => i.productId == productId)
        .fold<int>(0, (sum, i) => sum + i.quantity);
  }
}
