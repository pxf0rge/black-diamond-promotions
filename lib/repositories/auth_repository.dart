import '../core/errors/app_exception.dart';
import '../datasources/abstract/auth_data_source.dart';
import '../utils/password_hasher.dart';

class AuthRepository {
  AuthRepository(this._dataSource);

  final AuthDataSource _dataSource;

  Future<bool> isPasswordSet() => _dataSource.isPasswordSet();

  Future<bool> isBiometricEnabled() => _dataSource.isBiometricEnabled();

  Future<void> setBiometricEnabled(bool enabled) =>
      _dataSource.setBiometricEnabled(enabled);

  Future<bool> verifyPassword(String password) async {
    final hash = await _dataSource.getPasswordHash();
    if (hash == null) return false;
    return PasswordHasher.verify(password, hash);
  }

  Future<void> setPassword(String password) async {
    _validatePassword(password);
    await _dataSource.setPasswordHash(PasswordHasher.hash(password));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final valid = await verifyPassword(currentPassword);
    if (!valid) {
      throw const ValidationException('Current password is incorrect');
    }
    if (currentPassword == newPassword) {
      throw const ValidationException('New password must be different');
    }
    await setPassword(newPassword);
  }

  Future<void> removePassword(String currentPassword) async {
    final valid = await verifyPassword(currentPassword);
    if (!valid) {
      throw const ValidationException('Current password is incorrect');
    }
    await _dataSource.clearPassword();
  }

  Future<DateTime?> getLastPausedAt() => _dataSource.getLastPausedAt();

  Future<void> setLastPausedAt(DateTime? time) =>
      _dataSource.setLastPausedAt(time);

  void _validatePassword(String password) {
    if (password.length < 4) {
      throw const ValidationException('Password must be at least 4 characters');
    }
  }
}
