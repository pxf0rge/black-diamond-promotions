import '../../datasources/local/hive_auth_data_source.dart';
import '../../datasources/local/hive_cart_data_source.dart';
import '../../datasources/local/hive_category_data_source.dart';
import '../../datasources/local/hive_event_data_source.dart';
import '../../datasources/local/hive_product_data_source.dart';
import '../../datasources/local/hive_settings_data_source.dart';
import '../../datasources/local/hive_transaction_data_source.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/cart_repository.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/dashboard_repository.dart';
import '../../repositories/event_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/settings_repository.dart';
import '../../repositories/transaction_repository.dart';
import '../../services/biometric_service.dart';
import '../../services/export_service.dart';
import '../../services/receipt_service.dart';
import '../../storage/storage_service.dart';

class AppDependencies {
  AppDependencies._({
    required this.storageService,
    required this.eventRepository,
    required this.categoryRepository,
    required this.productRepository,
    required this.cartRepository,
    required this.transactionRepository,
    required this.dashboardRepository,
    required this.settingsRepository,
    required this.exportService,
    required this.backupService,
    required this.authRepository,
    required this.biometricService,
  });

  final StorageService storageService;
  final EventRepository eventRepository;
  final CategoryRepository categoryRepository;
  final ProductRepository productRepository;
  final CartRepository cartRepository;
  final TransactionRepository transactionRepository;
  final DashboardRepository dashboardRepository;
  final SettingsRepository settingsRepository;
  final ExportService exportService;
  final BackupService backupService;
  final AuthRepository authRepository;
  final BiometricService biometricService;

  static Future<AppDependencies> create() async {
    final storage = StorageService();
    await storage.init();

    final eventSource = HiveEventDataSource(storage);
    final categorySource = HiveCategoryDataSource(storage);
    final productSource = HiveProductDataSource(storage);
    final cartSource = HiveCartDataSource(storage);
    final transactionSource = HiveTransactionDataSource(storage);
    final settingsSource = HiveSettingsDataSource(storage);
    final authSource = HiveAuthDataSource(storage);

    final settingsRepository = SettingsRepository(settingsSource);
    final authRepository = AuthRepository(authSource);
    final biometricService = BiometricService();
    final eventRepository = EventRepository(eventSource);
    final categoryRepository = CategoryRepository(categorySource);
    final productRepository = ProductRepository(productSource);
    final cartRepository = CartRepository(cartSource, productSource);
    final receiptService = ReceiptService(settingsSource);
    final transactionRepository = TransactionRepository(
      transactionSource,
      cartRepository,
      receiptService,
    );
    final dashboardRepository = DashboardRepository(
      transactionSource,
      productSource,
      categorySource,
    );
    final exportService = ExportService(
      eventSource: eventSource,
      categorySource: categorySource,
      productSource: productSource,
      transactionSource: transactionSource,
      settingsSource: settingsSource,
    );
    final backupService = BackupService(storage, settingsSource);

    return AppDependencies._(
      storageService: storage,
      eventRepository: eventRepository,
      categoryRepository: categoryRepository,
      productRepository: productRepository,
      cartRepository: cartRepository,
      transactionRepository: transactionRepository,
      dashboardRepository: dashboardRepository,
      settingsRepository: settingsRepository,
      exportService: exportService,
      backupService: backupService,
      authRepository: authRepository,
      biometricService: biometricService,
    );
  }
}
