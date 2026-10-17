import 'package:uuid/uuid.dart';

import '../core/errors/app_exception.dart';
import '../datasources/abstract/category_data_source.dart';
import '../models/category_model.dart';

class CategoryRepository {
  CategoryRepository(this._dataSource, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final CategoryDataSource _dataSource;
  final Uuid _uuid;

  Future<List<CategoryModel>> getCategories(String eventId) =>
      _dataSource.getByEventId(eventId);

  Future<CategoryModel> addCategory({
    required String eventId,
    required String name,
    String emoji = '📦',
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Category name cannot be empty');
    }

    final existing = await _dataSource.getByEventId(eventId);
    if (existing.any((c) => c.name.toLowerCase() == trimmed.toLowerCase())) {
      throw const ValidationException('Category name already exists');
    }

    final now = DateTime.now();
    final category = CategoryModel(
      id: _uuid.v4(),
      eventId: eventId,
      name: trimmed,
      sortOrder: existing.length,
      createdAt: now,
      updatedAt: now,
      emoji: emoji,
    );
    return _dataSource.create(category);
  }

  Future<CategoryModel> renameCategory(String id, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      throw const ValidationException('Category name cannot be empty');
    }
    final category = await _dataSource.getById(id);
    if (category == null) {
      throw const ValidationException('Category not found');
    }

    final siblings = await _dataSource.getByEventId(category.eventId);
    if (siblings.any(
      (c) => c.id != id && c.name.toLowerCase() == trimmed.toLowerCase(),
    )) {
      throw const ValidationException('Category name already exists');
    }

    return _dataSource.update(
      category.copyWith(name: trimmed, updatedAt: DateTime.now()),
    );
  }

  Future<void> deleteCategory(String id) => _dataSource.delete(id);

  Future<void> reorderCategories(String eventId, List<String> orderedIds) =>
      _dataSource.reorder(eventId, orderedIds);

  Future<Map<String, bool>> getCollapseStates() =>
      _dataSource.getCollapseStates();

  Future<void> toggleCollapse(String categoryId, bool isExpanded) =>
      _dataSource.setCollapseState(categoryId, isExpanded);
}
