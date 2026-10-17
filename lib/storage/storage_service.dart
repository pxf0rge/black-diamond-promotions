import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/hive_constants.dart';
import '../core/errors/app_exception.dart';
import '../models/app_settings_model.dart';
import '../models/cart_item_model.dart';
import '../models/category_model.dart';
import '../models/event_model.dart';
import '../models/product_model.dart';
import '../models/transaction_item_model.dart';
import '../models/transaction_model.dart';

class StorageService {
  bool _initialized = false;

  bool get isInitialized => _initialized;

  Box<EventModel> get events => Hive.box<EventModel>(HiveBoxes.events);
  Box<CategoryModel> get categories =>
      Hive.box<CategoryModel>(HiveBoxes.categories);
  Box<ProductModel> get products => Hive.box<ProductModel>(HiveBoxes.products);
  Box<TransactionModel> get transactions =>
      Hive.box<TransactionModel>(HiveBoxes.transactions);
  Box<TransactionItemModel> get transactionItems =>
      Hive.box<TransactionItemModel>(HiveBoxes.transactionItems);
  Box<CartItemModel> get cartItems =>
      Hive.box<CartItemModel>(HiveBoxes.cartItems);
  Box<AppSettingsModel> get settings =>
      Hive.box<AppSettingsModel>(HiveBoxes.settings);
  Box<dynamic> get meta => Hive.box<dynamic>(HiveBoxes.meta);

  Future<void> init() async {
    if (_initialized) return;

    try {
      try {
        await Hive.initFlutter();
      } catch (_) {
        Hive.init('hive_data');
      }

      if (!Hive.isAdapterRegistered(HiveTypeIds.event)) {
        Hive.registerAdapter(EventModelAdapter());
      }
      if (!Hive.isAdapterRegistered(HiveTypeIds.category)) {
        Hive.registerAdapter(CategoryModelAdapter());
      }
      if (!Hive.isAdapterRegistered(HiveTypeIds.product)) {
        Hive.registerAdapter(ProductModelAdapter());
      }
      if (!Hive.isAdapterRegistered(HiveTypeIds.cartItem)) {
        Hive.registerAdapter(CartItemModelAdapter());
      }
      if (!Hive.isAdapterRegistered(HiveTypeIds.transaction)) {
        Hive.registerAdapter(TransactionModelAdapter());
      }
      if (!Hive.isAdapterRegistered(HiveTypeIds.transactionItem)) {
        Hive.registerAdapter(TransactionItemModelAdapter());
      }
      if (!Hive.isAdapterRegistered(HiveTypeIds.appSettings)) {
        Hive.registerAdapter(AppSettingsModelAdapter());
      }

      await Future.wait([
        Hive.openBox<EventModel>(HiveBoxes.events),
        Hive.openBox<CategoryModel>(HiveBoxes.categories),
        Hive.openBox<ProductModel>(HiveBoxes.products),
        Hive.openBox<TransactionModel>(HiveBoxes.transactions),
        Hive.openBox<TransactionItemModel>(HiveBoxes.transactionItems),
        Hive.openBox<CartItemModel>(HiveBoxes.cartItems),
        Hive.openBox<AppSettingsModel>(HiveBoxes.settings),
        Hive.openBox(HiveBoxes.meta),
      ]);

      if (settings.isEmpty) {
        await settings.put('default', AppSettingsModel());
      }

      _initialized = true;
    } catch (e) {
      throw StorageException('Failed to initialize local storage: $e');
    }
  }

  Future<void> clearAll() async {
    await Future.wait([
      events.clear(),
      categories.clear(),
      products.clear(),
      transactions.clear(),
      transactionItems.clear(),
      cartItems.clear(),
      meta.clear(),
    ]);
    await settings.put('default', AppSettingsModel());
  }
}
