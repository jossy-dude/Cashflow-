import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncProvider extends ChangeNotifier {
  DateTime? _lastSyncTime;
  bool _isSyncing = false;
  int _syncFrequency = 15; // minutes

  DateTime? get lastSyncTime => _lastSyncTime;
  bool get isSyncing => _isSyncing;
  int get syncFrequency => _syncFrequency;

  SyncProvider() {
    _loadSyncSettings();
  }

  Future<void> _loadSyncSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncMillis = prefs.getInt('last_sync_time');
    if (lastSyncMillis != null) {
      _lastSyncTime = DateTime.fromMillisecondsSinceEpoch(lastSyncMillis);
    }
    _syncFrequency = prefs.getInt('sync_frequency') ?? 15;
    notifyListeners();
  }

  Future<void> setSyncFrequency(int minutes) async {
    _syncFrequency = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sync_frequency', minutes);
    notifyListeners();
  }

  Future<void> updateLastSyncTime() async {
    _lastSyncTime = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_sync_time', _lastSyncTime!.millisecondsSinceEpoch);
    notifyListeners();
  }

  void setSyncing(bool syncing) {
    _isSyncing = syncing;
    notifyListeners();
  }

  String getLastSyncText() {
    if (_lastSyncTime == null) {
      return 'Never';
    }
    
    final now = DateTime.now();
    final difference = now.difference(_lastSyncTime!);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
