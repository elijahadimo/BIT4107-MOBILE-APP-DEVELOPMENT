import 'package:kapoeta_logistics/services/storage_service.dart';
import 'package:kapoeta_logistics/models/user.dart';

class MockStorageService implements StorageService {
  User? _user;
  String? _token;
  final Map<String, dynamic> _cache = {};

  @override
  Future<void> cacheData(String key, dynamic data) async {
    _cache[key] = data;
  }

  @override
  dynamic getCachedData(String key) {
    return _cache[key];
  }

  @override
  User? getUser() => _user;

  @override
  Future<void> saveUser(User user) async {
    _user = user;
  }

  @override
  String? getToken() => _token;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<void> clearAuth() async {
    _user = null;
    _token = null;
  }

  @override
  Future<void> addToSyncQueue(Map<String, dynamic> item) async {}
  
  @override
  List<Map<String, dynamic>> getSyncQueue() => [];
  
  @override
  Future<void> clearSyncQueue() async {}

  @override
  bool get onboardingComplete => true;

  @override
  Future<void> setOnboardingComplete() async {}
}
