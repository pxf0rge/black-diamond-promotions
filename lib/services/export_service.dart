import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../datasources/abstract/category_data_source.dart';
import '../datasources/abstract/event_data_source.dart';
import '../datasources/abstract/product_data_source.dart';
import '../datasources/abstract/settings_data_source.dart';
import '../datasources/abstract/transaction_data_source.dart';
import '../models/app_settings_model.dart';
import '../models/category_model.dart';
import '../models/event_model.dart';
import '../models/product_model.dart';
import '../models/transaction_item_model.dart';
import '../models/transaction_model.dart';
import '../storage/storage_service.dart';

class ExportService {
  ExportService({
    required EventDataSource eventSource,
    required CategoryDataSource categorySource,
    required ProductDataSource productSource,
    required TransactionDataSource transactionSource,
    required SettingsDataSource settingsSource,
  }) : _eventSource = eventSource,
       _categorySource = categorySource,
       _productSource = productSource,
       _transactionSource = transactionSource,
       _settingsSource = settingsSource;

  final EventDataSource _eventSource;
  final CategoryDataSource _categorySource;
  final ProductDataSource _productSource;
  final TransactionDataSource _transactionSource;
  final SettingsDataSource _settingsSource;

  Future<String> exportTransactionsCsv() async {
    final txns = await _transactionSource.getAll();
    final buffer = StringBuffer(
      'Receipt,Date,Payment,Subtotal,Tax,Discount,Total\n',
    );

    for (final txn in txns) {
      buffer.writeln(
        '${txn.receiptNumber},'
        '${txn.createdAt.toIso8601String()},'
        '${txn.paymentMethod},'
        '${txn.subtotal},'
        '${txn.tax},'
        '${txn.discount},'
        '${txn.total}',
      );
    }

    return _writeFile('transactions_export.csv', buffer.toString());
  }

  Future<String> exportProductsCsv() async {
    final events = await _eventSource.getAll();
    final buffer = StringBuffer('Event,Category,Product,Price,Active\n');

    for (final event in events) {
      final categories = await _categorySource.getByEventId(event.id);
      for (final category in categories) {
        final products = await _productSource.getByCategoryId(category.id);
        for (final product in products) {
          buffer.writeln(
            '${event.name},'
            '${category.name},'
            '${product.name},'
            '${product.price},'
            '${product.isActive}',
          );
        }
      }
    }

    return _writeFile('products_export.csv', buffer.toString());
  }

  Future<String> exportCategoriesCsv() async {
    final events = await _eventSource.getAll();
    final buffer = StringBuffer('Event,Category,SortOrder\n');

    for (final event in events) {
      final categories = await _categorySource.getByEventId(event.id);
      for (final category in categories) {
        buffer.writeln('${event.name},${category.name},${category.sortOrder}');
      }
    }

    return _writeFile('categories_export.csv', buffer.toString());
  }

  Future<String> _writeFile(String name, String content) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsString(content);
    return file.path;
  }
}

class BackupService {
  BackupService(this._storage, this._settingsSource);

  final StorageService _storage;
  final SettingsDataSource _settingsSource;

  Future<String> createBackup() async {
    final events = _storage.events.values.map((e) => e.toJson()).toList();
    final categories = _storage.categories.values
        .map((e) => e.toJson())
        .toList();
    final products = _storage.products.values.map((e) => e.toJson()).toList();
    final transactions = _storage.transactions.values
        .map((e) => e.toJson())
        .toList();
    final transactionItems = _storage.transactionItems.values
        .map((e) => e.toJson())
        .toList();
    final settings = (await _settingsSource.getSettings()).toJson();
    final meta = Map<String, dynamic>.from(_storage.meta.toMap());

    final backup = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'events': events,
      'categories': categories,
      'products': products,
      'transactions': transactions,
      'transactionItems': transactionItems,
      'settings': settings,
      'meta': meta,
    };

    final dir = await getApplicationDocumentsDirectory();
    final fileName =
        'ticket_tracker_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(backup),
    );
    return file.path;
  }

  Future<void> restoreBackup(String filePath) async {
    final file = File(filePath);
    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;

    await _storage.clearAll();

    for (final item in json['events'] as List) {
      await _storage.events.put(
        item['id'],
        EventModel.fromJson(Map<String, dynamic>.from(item as Map)),
      );
    }
    for (final item in json['categories'] as List) {
      await _storage.categories.put(
        item['id'],
        CategoryModel.fromJson(Map<String, dynamic>.from(item as Map)),
      );
    }
    for (final item in json['products'] as List) {
      await _storage.products.put(
        item['id'],
        ProductModel.fromJson(Map<String, dynamic>.from(item as Map)),
      );
    }
    for (final item in json['transactions'] as List) {
      await _storage.transactions.put(
        item['id'],
        TransactionModel.fromJson(Map<String, dynamic>.from(item as Map)),
      );
    }
    for (final item in json['transactionItems'] as List) {
      await _storage.transactionItems.put(
        item['id'],
        TransactionItemModel.fromJson(Map<String, dynamic>.from(item as Map)),
      );
    }

    final settings = AppSettingsModel.fromJson(
      Map<String, dynamic>.from(json['settings'] as Map),
    );
    await _storage.settings.put('default', settings);

    final meta = Map<String, dynamic>.from(json['meta'] as Map);
    for (final entry in meta.entries) {
      await _storage.meta.put(entry.key, entry.value);
    }
  }
}
