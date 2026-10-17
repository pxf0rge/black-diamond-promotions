import '../../models/product_model.dart';
import '../abstract/product_data_source.dart';
import '../../storage/storage_service.dart';

class HiveProductDataSource implements ProductDataSource {
  HiveProductDataSource(this._storage);

  final StorageService _storage;

  @override
  Future<List<ProductModel>> getByCategoryId(String categoryId) async {
    return _storage.products.values
        .where((p) => p.categoryId == categoryId)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Future<List<ProductModel>> getByEventId(String eventId) async {
    final categoryIds = _storage.categories.values
        .where((c) => c.eventId == eventId)
        .map((c) => c.id)
        .toSet();
    return _storage.products.values
        .where((p) => categoryIds.contains(p.categoryId))
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Future<ProductModel?> getById(String id) async => _storage.products.get(id);

  @override
  Future<ProductModel> create(ProductModel product) async {
    await _storage.products.put(product.id, product);
    return product;
  }

  @override
  Future<ProductModel> update(ProductModel product) async {
    await _storage.products.put(product.id, product);
    return product;
  }

  @override
  Future<void> delete(String id) async {
    await _storage.products.delete(id);
  }

  @override
  Future<void> move(
    String productId,
    String newCategoryId,
    int sortOrder,
  ) async {
    final product = _storage.products.get(productId);
    if (product == null) return;
    await _storage.products.put(
      productId,
      product.copyWith(categoryId: newCategoryId, sortOrder: sortOrder),
    );
  }
}
