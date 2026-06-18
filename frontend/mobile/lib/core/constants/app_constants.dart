/// App-wide constants that do not belong in any single feature layer.
abstract final class AppConstants {
  static const String appName = 'ASAR';

  // Base API URL — switch this out per environment via a .env file or
  // build flavor; this default points to local dev
  static const String baseApiUrl = 'http://192.168.1.146:8000/api';

  // Secure storage keys — keep these in one place to avoid typo drift
  static const String storageKeyAccessToken = 'access_token';
  static const String storageKeyRefreshToken = 'refresh_token';
  static const String storageKeyWorkerId = 'worker_id';
  static const String storageKeyWorkerName = 'worker_name';

  // Chat polling interval in seconds for workers on weak connectivity
  static const int chatPollIntervalSeconds = 15;

  // Maximum photos per job completion submission
  static const int maxVerificationPhotos = 5;

  // How many completed jobs to show per page in the ledger
  static const int ledgerPageSize = 20;
}
