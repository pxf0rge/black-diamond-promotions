import '../../models/product_model.dart';

abstract class ProductDataSource {
  Future<List<ProductModel>> getByCategoryId(String categoryId);
  Future<List<ProductModel>> getByEventId(String eventId);
  Future<ProductModel?> getById(String id);
  Future<ProductModel> create(ProductModel product);
  Future<ProductModel> update(ProductModel product);
  Future<void> delete(String id);
  Future<void> move(String productId, String newCategoryId, int sortOrder);
}
