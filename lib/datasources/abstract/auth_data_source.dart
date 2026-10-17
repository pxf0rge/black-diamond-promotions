abstract class AuthDataSource {
  Future<bool> isPasswordSet();
  Future<String?> getPasswordHash();
  Future<void> setPasswordHash(String hash);
  Future<void> clearPassword();
  Future<bool> isBiometricEnabled();
  Future<void> setBiometricEnabled(bool enabled);
  Future<DateTime?> getLastPausedAt();
  Future<void> setLastPausedAt(DateTime? time);
}
