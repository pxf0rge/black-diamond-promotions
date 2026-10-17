import 'package:flutter/foundation.dart';

import '../core/errors/app_exception.dart';
import '../models/app_settings_model.dart';
import '../repositories/settings_repository.dart';
import '../services/export_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider({
    required SettingsRepository settingsRepository,
    required ExportService exportService,
    required BackupService backupService,
  }) : _settingsRepository = settingsRepository,
       _exportService = exportService,
       _backupService = backupService;

  final SettingsRepository _settingsRepository;
  final ExportService _exportService;
  final BackupService _backupService;

  AppSettingsModel? _settings;
  String? _errorMessage;
  String? _lastExportPath;

  AppSettingsModel? get settings => _settings;
  String? get errorMessage => _errorMessage;
  String? get lastExportPath => _lastExportPath;

  Future<void> init() => _load();

  Future<void> _load() async {
    _settings = await _settingsRepository.getSettings();
    notifyListeners();
  }

  Future<void> updateSettings(AppSettingsModel settings) async {
    try {
      _settings = await _settingsRepository.updateSettings(settings);
      notifyListeners();
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<String> exportTransactions() async {
    _lastExportPath = await _exportService.exportTransactionsCsv();
    notifyListeners();
    return _lastExportPath!;
  }

  Future<String> exportProducts() async {
    _lastExportPath = await _exportService.exportProductsCsv();
    notifyListeners();
    return _lastExportPath!;
  }

  Future<String> exportCategories() async {
    _lastExportPath = await _exportService.exportCategoriesCsv();
    notifyListeners();
    return _lastExportPath!;
  }

  Future<String> createBackup() async {
    _lastExportPath = await _backupService.createBackup();
    notifyListeners();
    return _lastExportPath!;
  }

  Future<void> restoreBackup(String path) async {
    await _backupService.restoreBackup(path);
    notifyListeners();
  }
}
