enum SyncStatus { idle, syncing, success, error }

class SyncService {
  SyncStatus _status = SyncStatus.idle;
  DateTime? _lastSyncAt;

  SyncStatus get status => _status;
  DateTime? get lastSyncAt => _lastSyncAt;

  Future<void> sync() async {
    _status = SyncStatus.syncing;
    notify();

    // Simulate sync
    await Future.delayed(const Duration(seconds: 2));

    _status = SyncStatus.success;
    _lastSyncAt = DateTime.now();
    notify();
  }

  void notify() {
    // In real implementation, this would update a provider
  }
}
