import 'package:uuid/uuid.dart';

import '../core/errors/app_exception.dart';
import '../datasources/abstract/product_data_source.dart';
import '../models/product_model.dart';

class ProductRepository {
  ProductRepository(this._dataSource, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final ProductDataSource _dataSource;
  final Uuid _uuid;

  Future<List<ProductModel>> getByCategory(String categoryId) =>
      _dataSource.getByCategoryId(categoryId);

  Future<List<ProductModel>> getByEvent(String eventId) =>
      _dataSource.getByEventId(eventId);

  Future<ProductModel?> getById(String id) => _dataSource.getById(id);

  Future<ProductModel> addProduct({
    required String categoryId,
    required String name,
    required double price,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Product name cannot be empty');
    }
    if (price < 0) {
      throw const ValidationException('Price cannot be negative');
    }

    final siblings = await _dataSource.getByCategoryId(categoryId);
    final product = ProductModel(
      id: _uuid.v4(),
      categoryId: categoryId,
      name: trimmed,
      price: price,
      isFree: price == 0,
      sortOrder: siblings.length,
      isActive: true,
      createdAt: DateTime.now(),
    );
    return _dataSource.create(product);
  }

  Future<ProductModel> updateProduct({
    required String id,
    required String name,
    required double price,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Product name cannot be empty');
    }
    if (price < 0) {
      throw const ValidationException('Price cannot be negative');
    }

    final product = await _dataSource.getById(id);
    if (product == null) {
      throw const ValidationException('Product not found');
    }

    return _dataSource.update(
      product.copyWith(name: trimmed, price: price, isFree: price == 0),
    );
  }

  Future<void> deleteProduct(String id) => _dataSource.delete(id);

  Future<ProductModel> setActive(String id, bool isActive) async {
    final product = await _dataSource.getById(id);
    if (product == null) {
      throw const ValidationException('Product not found');
    }
    return _dataSource.update(product.copyWith(isActive: isActive));
  }

  Future<void> moveProduct(String productId, String newCategoryId) async {
    final products = await _dataSource.getByCategoryId(newCategoryId);
    await _dataSource.move(productId, newCategoryId, products.length);
  }
}
