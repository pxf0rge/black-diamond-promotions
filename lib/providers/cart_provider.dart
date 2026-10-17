import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../models/display_models.dart';
import '../models/product_model.dart';
import '../repositories/cart_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/settings_repository.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({
    required CartRepository cartRepository,
    required EventRepository eventRepository,
    required SettingsRepository settingsRepository,
  }) : _cartRepository = cartRepository,
       _eventRepository = eventRepository,
       _settingsRepository = settingsRepository;

  final CartRepository _cartRepository;
  final EventRepository _eventRepository;
  final SettingsRepository _settingsRepository;

  List<CartLine> _items = [];
  double _subtotal = 0;
  double _tax = 0;
  double _discount = 0;
  double _grandTotal = 0;
  int _totalItems = 0;
  double _taxRate = 8;
  String? _eventId;
  String? _errorMessage;

  List<CartLine> get items => _items;
  double get subtotal => _subtotal;
  double get tax => _tax;
  double get discount => _discount;
  double get grandTotal => _grandTotal;
  int get totalItems => _totalItems;
  bool get isEmpty => _totalItems == 0;
  String? get errorMessage => _errorMessage;

  Future<void> init() => _reload();

  Future<void> _reload() async {
    final event = await _eventRepository.getCurrentEvent();
    _eventId = event?.id;
    if (_eventId == null) {
      _items = [];
      _subtotal = _tax = _discount = _grandTotal = 0;
      _totalItems = 0;
      notifyListeners();
      return;
    }

    final settings = await _settingsRepository.getSettings();
    _taxRate = settings.taxPercentage;
    _items = await _cartRepository.getCartLines(_eventId!);
    _subtotal = await _cartRepository.getSubtotal(_eventId!);
    _discount = await _cartRepository.getDiscount(_eventId!);
    _tax = await _cartRepository.getTax(_eventId!, _taxRate);
    _grandTotal = await _cartRepository.getGrandTotal(_eventId!, _taxRate);
    _totalItems = await _cartRepository.getTotalItems(_eventId!);
    notifyListeners();
  }

  Future<int> getQuantity(String productId) async {
    if (_eventId == null) return 0;
    return _cartRepository.getQuantity(_eventId!, productId);
  }

  int getQuantitySync(String productId) {
    final item = _items.where((i) => i.product.id == productId).firstOrNull;
    return item?.quantity ?? 0;
  }

  Future<void> addProduct(ProductModel product) async {
    if (_eventId == null) return;
    try {
      await _cartRepository.addProduct(_eventId!, product);
      await _reload();
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> increment(String productId) async {
    if (_eventId == null) return;
    try {
      await _cartRepository.increment(_eventId!, productId);
      await _reload();
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> decrement(String productId) async {
    if (_eventId == null) return;
    try {
      await _cartRepository.decrement(_eventId!, productId);
      await _reload();
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> clear() async {
    if (_eventId == null) return;
    await _cartRepository.clear(_eventId!);
    await _reload();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
