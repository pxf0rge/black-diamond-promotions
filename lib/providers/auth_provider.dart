import 'package:flutter/foundation.dart';

import '../core/constants.dart';
import '../core/errors/app_exception.dart';
import '../repositories/auth_repository.dart';
import '../services/biometric_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required AuthRepository authRepository,
    required BiometricService biometricService,
  }) : _authRepository = authRepository,
       _biometricService = biometricService;

  final AuthRepository _authRepository;
  final BiometricService _biometricService;

  bool _isInitialized = false;
  bool _isLocked = true;
  bool _isPasswordSet = false;
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  String? _errorMessage;

  bool get isInitialized => _isInitialized;
  bool get isLocked => _isLocked;
  bool get isPasswordSet => _isPasswordSet;
  bool get biometricEnabled => _biometricEnabled;
  bool get biometricAvailable => _biometricAvailable;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    _isPasswordSet = await _authRepository.isPasswordSet();
    _biometricEnabled = await _authRepository.isBiometricEnabled();
    _biometricAvailable = await _biometricService.canCheckBiometrics();
    _isLocked = _isPasswordSet;
    _isInitialized = true;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> setupPassword(String password, String confirm) async {
    if (password != confirm) {
      _errorMessage = 'Passwords do not match';
      notifyListeners();
      return false;
    }
    try {
      await _authRepository.setPassword(password);
      _isPasswordSet = true;
      _isLocked = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> unlockWithPassword(String password) async {
    try {
      final valid = await _authRepository.verifyPassword(password);
      if (!valid) {
        _errorMessage = 'Incorrect password';
        notifyListeners();
        return false;
      }
      _isLocked = false;
      _errorMessage = null;
      await _authRepository.setLastPausedAt(null);
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> unlockWithBiometric() async {
    if (!_biometricEnabled || !_biometricAvailable) return false;

    final success = await _biometricService.authenticate(
      reason: 'Unlock Ticket Tracker',
    );
    if (success) {
      _isLocked = false;
      _errorMessage = null;
      await _authRepository.setLastPausedAt(null);
      notifyListeners();
    }
    return success;
  }

  Future<bool> changePassword({
    required String current,
    required String newPassword,
    required String confirm,
  }) async {
    if (newPassword != confirm) {
      _errorMessage = 'New passwords do not match';
      notifyListeners();
      return false;
    }
    try {
      await _authRepository.changePassword(
        currentPassword: current,
        newPassword: newPassword,
      );
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> removePassword(String currentPassword) async {
    try {
      await _authRepository.removePassword(currentPassword);
      _isPasswordSet = false;
      _isLocked = false;
      _biometricEnabled = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> setBiometricEnabled(bool enabled) async {
    if (enabled) {
      if (!_biometricAvailable) {
        _errorMessage = 'Biometric authentication is not available';
        notifyListeners();
        return false;
      }
      final verified = await _biometricService.authenticate(
        reason: 'Enable biometric unlock',
      );
      if (!verified) return false;
    }

    await _authRepository.setBiometricEnabled(enabled);
    _biometricEnabled = enabled;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  void lock() {
    if (!_isPasswordSet || _isLocked) return;
    _isLocked = true;
    notifyListeners();
  }

  Future<void> onAppPaused() async {
    if (!_isPasswordSet || _isLocked) return;
    await _authRepository.setLastPausedAt(DateTime.now());
  }

  Future<void> onAppResumed() async {
    if (!_isPasswordSet || _isLocked) return;

    final pausedAt = await _authRepository.getLastPausedAt();
    if (pausedAt == null) return;

    final elapsed = DateTime.now().difference(pausedAt);
    if (elapsed >= AppConstants.backgroundLockTimeout) {
      lock();
    }
    await _authRepository.setLastPausedAt(null);
  }
}
