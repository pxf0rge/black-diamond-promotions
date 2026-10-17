import 'package:flutter/foundation.dart';

import '../core/enums/app_enums.dart';
import '../core/errors/app_exception.dart';
import '../models/dashboard_stats.dart';
import '../models/display_models.dart';
import '../repositories/dashboard_repository.dart';
import '../repositories/event_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/transaction_repository.dart';
import '../services/export_service.dart';

class TransactionProvider extends ChangeNotifier {
  TransactionProvider({
    required TransactionRepository transactionRepository,
    required DashboardRepository dashboardRepository,
    required EventRepository eventRepository,
    required SettingsRepository settingsRepository,
    required ExportService exportService,
  }) : _transactionRepository = transactionRepository,
       _dashboardRepository = dashboardRepository,
       _eventRepository = eventRepository,
       _settingsRepository = settingsRepository,
       _exportService = exportService;

  final TransactionRepository _transactionRepository;
  final DashboardRepository _dashboardRepository;
  final EventRepository _eventRepository;
  final SettingsRepository _settingsRepository;
  final ExportService _exportService;

  List<TransactionView> _transactions = [];
  DashboardStats? _stats;
  Map<PaymentMethod, double> _paymentBreakdown = {};
  List<double> _hourlyRevenue = List.filled(12, 0);
  List<MapEntry<String, int>> _topCategories = [];
  List<MapEntry<String, int>> _topProducts = [];

  String _searchQuery = '';
  DateFilterType _dateFilter = DateFilterType.today;
  DateTime? _customStart;
  DateTime? _customEnd;
  PaymentMethod? _paymentFilter;
  TransactionSort _sort = TransactionSort.newest;
  bool _isRefreshing = false;
  String? _errorMessage;
  String? _eventId;

  List<TransactionView> get transactions => _transactions;
  List<TransactionView> get filteredTransactions => _transactions;
  DashboardStats? get stats => _stats;
  String get searchQuery => _searchQuery;
  DateFilterType get dateFilter => _dateFilter;
  DateTime? get customStart => _customStart;
  DateTime? get customEnd => _customEnd;
  PaymentMethod? get paymentFilter => _paymentFilter;
  TransactionSort get sort => _sort;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;

  double get todayRevenue => _stats?.todayRevenue ?? 0;
  int get todayTransactionCount => _stats?.transactions ?? 0;
  double get averageSale => _stats?.averageSale ?? 0;
  int get itemsSoldToday => _stats?.itemsSold ?? 0;
  Map<PaymentMethod, double> get paymentBreakdown => _paymentBreakdown;
  List<double> get hourlyRevenue => _hourlyRevenue;
  List<MapEntry<String, int>> get topCategories => _topCategories;
  List<MapEntry<String, int>> get topProducts => _topProducts;

  Future<void> init() => _reload();

  Future<void> _reload() async {
    try {
      final event = await _eventRepository.getCurrentEvent();
      _eventId = event?.id;

      _transactions = await _transactionRepository.getRecentTransactions(
        eventId: _eventId,
        query: _searchQuery.isEmpty ? null : _searchQuery,
        dateFilter: _dateFilter,
        customStart: _customStart,
        customEnd: _customEnd,
        paymentMethod: _paymentFilter,
        sort: _sort,
      );

      _stats = await _dashboardRepository.getTodayStats(_eventId);
      _paymentBreakdown = await _dashboardRepository.getPaymentBreakdown(
        eventId: _eventId,
        dateFilter: _dateFilter,
      );
      _hourlyRevenue = await _dashboardRepository.getHourlyRevenue(
        eventId: _eventId,
        dateFilter: _dateFilter,
      );
      _topCategories = await _dashboardRepository.getTopCategories(
        eventId: _eventId,
        dateFilter: _dateFilter,
      );
      _topProducts = await _dashboardRepository.getTopProducts(
        eventId: _eventId,
        dateFilter: _dateFilter,
      );
      _errorMessage = null;
    } on AppException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load transactions';
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _reload();
  }

  void setDateFilter(DateFilterType filter, {DateTime? start, DateTime? end}) {
    _dateFilter = filter;
    _customStart = start;
    _customEnd = end;
    _reload();
  }

  void setPaymentFilter(PaymentMethod? method) {
    _paymentFilter = method;
    _reload();
  }

  void setSort(TransactionSort sort) {
    _sort = sort;
    _reload();
  }

  void clearFilters() {
    _searchQuery = '';
    _dateFilter = DateFilterType.today;
    _customStart = null;
    _customEnd = null;
    _paymentFilter = null;
    _sort = TransactionSort.newest;
    _reload();
  }

  Future<void> refresh() async {
    _isRefreshing = true;
    notifyListeners();
    await _reload();
    _isRefreshing = false;
    notifyListeners();
  }

  Future<TransactionView?> completePayment(PaymentMethod method) async {
    if (_eventId == null) return null;
    try {
      final settings = await _settingsRepository.getSettings();
      final txn = await _transactionRepository.completePayment(
        eventId: _eventId!,
        paymentMethod: method,
        taxRate: settings.taxPercentage,
      );
      final items = await _transactionRepository.getItems(txn.id);
      await _reload();
      return TransactionView(transaction: txn, items: items);
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      await _transactionRepository.deleteTransaction(id);
      await _reload();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Failed to delete transaction';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction({
    required String id,
    PaymentMethod? paymentMethod,
    double? discount,
  }) async {
    try {
      await _transactionRepository.updateTransaction(
        id: id,
        paymentMethod: paymentMethod,
        discount: discount,
      );
      await _reload();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Failed to update transaction';
      notifyListeners();
      return false;
    }
  }

  Future<String> exportTransactions() => _exportService.exportTransactionsCsv();

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
