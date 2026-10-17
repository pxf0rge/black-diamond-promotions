import 'package:flutter/foundation.dart' hide Category;

import '../core/errors/app_exception.dart';
import '../models/display_models.dart';
import '../models/product_model.dart';
import '../repositories/category_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/product_repository.dart';

class CatalogProvider extends ChangeNotifier {
  CatalogProvider({
    required CategoryRepository categoryRepository,
    required ProductRepository productRepository,
    required EventRepository eventRepository,
  }) : _categoryRepository = categoryRepository,
       _productRepository = productRepository,
       _eventRepository = eventRepository;

  final CategoryRepository _categoryRepository;
  final ProductRepository _productRepository;
  final EventRepository _eventRepository;

  List<CategoryGroup> _categories = [];
  Map<String, bool> _collapseStates = {};
  String _searchQuery = '';
  String? _eventId;
  String? _errorMessage;
  bool _isLoading = false;

  List<CategoryGroup> get categories => _categories;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  List<CategoryGroup> get filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    final query = _searchQuery.toLowerCase();
    final results = <CategoryGroup>[];
    for (final category in _categories) {
      final matchingProducts = category.products
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
      if (category.name.toLowerCase().contains(query)) {
        results.add(category);
      } else if (matchingProducts.isNotEmpty) {
        results.add(category.copyWith(products: matchingProducts));
      }
    }
    return results;
  }

  Future<void> init() => _reload();

  Future<void> _reload({bool activeOnly = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final event = await _eventRepository.getCurrentEvent();
      _eventId = event?.id;
      if (_eventId == null) {
        _categories = [];
        return;
      }

      final cats = await _categoryRepository.getCategories(_eventId!);
      _collapseStates = await _categoryRepository.getCollapseStates();

      final groups = <CategoryGroup>[];
      for (final cat in cats) {
        var products = await _productRepository.getByCategory(cat.id);
        if (activeOnly) {
          products = products.where((p) => p.isActive).toList();
        }
        groups.add(
          CategoryGroup(
            id: cat.id,
            name: cat.name,
            emoji: cat.emoji,
            products: products,
            isExpanded: _collapseStates[cat.id] ?? false,
          ),
        );
      }
      _categories = groups;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load catalog';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadForSell() => _reload(activeOnly: true);
  Future<void> reloadForManage() => _reload(activeOnly: false);

  ProductModel? getProductById(String id) {
    for (final category in _categories) {
      for (final product in category.products) {
        if (product.id == id) return product;
      }
    }
    return null;
  }

  String? getCategoryNameForProduct(String productId) {
    for (final category in _categories) {
      if (category.products.any((p) => p.id == productId)) {
        return category.name;
      }
    }
    return null;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> toggleCategory(String categoryId) async {
    final index = _categories.indexWhere((c) => c.id == categoryId);
    if (index == -1) return;
    final expanded = !_categories[index].isExpanded;
    _categories[index] = _categories[index].copyWith(isExpanded: expanded);
    await _categoryRepository.toggleCollapse(categoryId, expanded);
    notifyListeners();
  }

  Future<void> addCategory(String name) async {
    if (_eventId == null) return;
    try {
      await _categoryRepository.addCategory(eventId: _eventId!, name: name);
      await reloadForManage();
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _categoryRepository.deleteCategory(categoryId);
      await reloadForManage();
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> renameCategory(String categoryId, String newName) async {
    try {
      await _categoryRepository.renameCategory(categoryId, newName);
      await reloadForManage();
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> addProduct(String categoryId, String name, double price) async {
    try {
      await _productRepository.addProduct(
        categoryId: categoryId,
        name: name,
        price: price,
      );
      await reloadForManage();
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> updateProduct(
    String categoryId,
    String productId,
    String name,
    double price,
  ) async {
    try {
      await _productRepository.updateProduct(
        id: productId,
        name: name,
        price: price,
      );
      await reloadForManage();
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String categoryId, String productId) async {
    try {
      await _productRepository.deleteProduct(productId);
      await reloadForManage();
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
