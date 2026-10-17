import '../../core/constants/hive_constants.dart';
import '../../storage/storage_service.dart';
import '../abstract/auth_data_source.dart';

class HiveAuthDataSource implements AuthDataSource {
  HiveAuthDataSource(this._storage);

  final StorageService _storage;

  @override
  Future<bool> isPasswordSet() async {
    return _storage.meta.get(MetaKeys.authPasswordSet) == true;
  }

  @override
  Future<String?> getPasswordHash() async {
    return _storage.meta.get(MetaKeys.authPasswordHash) as String?;
  }

  @override
  Future<void> setPasswordHash(String hash) async {
    await _storage.meta.put(MetaKeys.authPasswordHash, hash);
    await _storage.meta.put(MetaKeys.authPasswordSet, true);
  }

  @override
  Future<void> clearPassword() async {
    await _storage.meta.delete(MetaKeys.authPasswordHash);
    await _storage.meta.put(MetaKeys.authPasswordSet, false);
    await _storage.meta.put(MetaKeys.authBiometricEnabled, false);
  }

  @override
  Future<bool> isBiometricEnabled() async {
    return _storage.meta.get(MetaKeys.authBiometricEnabled) == true;
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.meta.put(MetaKeys.authBiometricEnabled, enabled);
  }

  @override
  Future<DateTime?> getLastPausedAt() async {
    final value = _storage.meta.get(MetaKeys.authLastPausedAt);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  Future<void> setLastPausedAt(DateTime? time) async {
    if (time == null) {
      await _storage.meta.delete(MetaKeys.authLastPausedAt);
    } else {
      await _storage.meta.put(
        MetaKeys.authLastPausedAt,
        time.toIso8601String(),
      );
    }
  }
}
