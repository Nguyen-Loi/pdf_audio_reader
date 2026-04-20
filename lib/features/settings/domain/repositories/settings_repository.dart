abstract class SettingsRepository {
  Future<int> getImportCount();
  Future<void> setImportCount(int count);
  Future<int> incrementImportCount();
  Future<bool> getHasShownReview();
  Future<void> setHasShownReview(bool shown);
}
