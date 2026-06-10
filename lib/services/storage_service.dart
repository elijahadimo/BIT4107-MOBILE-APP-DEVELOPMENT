import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class StorageService {
  static const String _userKey = 'user_data';
  static const String _tokenKey = 'auth_token';
  static const String _shipmentsKey = 'cached_shipments';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Auth Storage
  Future<void> saveUser(User user) async {
    await _prefs.setString(_userKey, json.encode(user.toJson()));
  }

  User? getUser() {
    final userStr = _prefs.getString(_userKey);
    if (userStr == null) return null;
    try {
      return User.fromJson(json.decode(userStr));
    } catch (e) {
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> clearAuth() async {
    await _prefs.remove(_userKey);
    await _prefs.remove(_tokenKey);
  }

  // Cache Storage
  Future<void> cacheData(String key, dynamic data) async {
    await _prefs.setString(key, json.encode(data));
  }

  dynamic getCachedData(String key) {
    final dataStr = _prefs.getString(key);
    if (dataStr == null) return null;
    try {
      return json.decode(dataStr);
    } catch (e) {
      return null;
    }
  }

  static const String _syncQueueKey = 'sync_queue';

  // ... existing methods ...

  // Sync Queue
  Future<void> addToSyncQueue(Map<String, dynamic> action) async {
    List<dynamic> queue = getSyncQueue();
    queue.add(action);
    await _prefs.setString(_syncQueueKey, json.encode(queue));
  }

  List<dynamic> getSyncQueue() {
    final queueStr = _prefs.getString(_syncQueueKey);
    if (queueStr == null) return [];
    try {
      return json.decode(queueStr);
    } catch (e) {
      return [];
    }
  }

  Future<void> clearSyncQueue() async {
    await _prefs.remove(_syncQueueKey);
  }

  Future<void> removeFromSyncQueue(int index) async {
    List<dynamic> queue = getSyncQueue();
    if (index < queue.length) {
      queue.removeAt(index);
      await _prefs.setString(_syncQueueKey, json.encode(queue));
    }
  }
}
