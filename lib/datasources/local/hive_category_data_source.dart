import '../../core/constants/hive_constants.dart';
import '../../models/category_model.dart';
import '../abstract/category_data_source.dart';
import '../../storage/storage_service.dart';

class HiveCategoryDataSource implements CategoryDataSource {
  HiveCategoryDataSource(this._storage);

  final StorageService _storage;

  Map<String, bool> _readCollapseMap() {
    final raw = _storage.meta.get(MetaKeys.categoryCollapse);
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v == true));
    }
    return {};
  }

  @override
  Future<List<CategoryModel>> getByEventId(String eventId) async {
    return _storage.categories.values
        .where((c) => c.eventId == eventId)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Future<CategoryModel?> getById(String id) async =>
      _storage.categories.get(id);

  @override
  Future<CategoryModel> create(CategoryModel category) async {
    await _storage.categories.put(category.id, category);
    return category;
  }

  @override
  Future<CategoryModel> update(CategoryModel category) async {
    await _storage.categories.put(category.id, category);
    return category;
  }

  @override
  Future<void> delete(String id) async {
    await _storage.categories.delete(id);
    final map = _readCollapseMap()..remove(id);
    await _storage.meta.put(MetaKeys.categoryCollapse, map);
  }

  @override
  Future<void> reorder(String eventId, List<String> orderedIds) async {
    for (var i = 0; i < orderedIds.length; i++) {
      final category = _storage.categories.get(orderedIds[i]);
      if (category != null && category.eventId == eventId) {
        await _storage.categories.put(
          category.id,
          category.copyWith(sortOrder: i, updatedAt: DateTime.now()),
        );
      }
    }
  }

  @override
  Future<Map<String, bool>> getCollapseStates() async => _readCollapseMap();

  @override
  Future<void> setCollapseState(String categoryId, bool isExpanded) async {
    final map = _readCollapseMap()..[categoryId] = isExpanded;
    await _storage.meta.put(MetaKeys.categoryCollapse, map);
  }
}
