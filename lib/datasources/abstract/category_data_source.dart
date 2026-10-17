import '../../models/category_model.dart';

abstract class CategoryDataSource {
  Future<List<CategoryModel>> getByEventId(String eventId);
  Future<CategoryModel?> getById(String id);
  Future<CategoryModel> create(CategoryModel category);
  Future<CategoryModel> update(CategoryModel category);
  Future<void> delete(String id);
  Future<void> reorder(String eventId, List<String> orderedIds);
  Future<Map<String, bool>> getCollapseStates();
  Future<void> setCollapseState(String categoryId, bool isExpanded);
}
