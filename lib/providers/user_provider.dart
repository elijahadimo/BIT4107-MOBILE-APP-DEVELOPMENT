import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

class UserProvider extends ChangeNotifier {
  final List<User> _users = [];
  final StorageService? storageService;

  UserProvider({this.storageService}) {
    _loadUsers();
  }

  List<User> get allUsers => _users;
  List<User> get drivers => _users.where((u) => u.role == UserRole.driver).toList();
  List<User> get asstDrivers => _users.where((u) => u.role == UserRole.asstDriver).toList();
  List<User> get agents => _users.where((u) => u.role == UserRole.agent).toList();

  void _loadUsers() {
    final cachedData = storageService?.getCachedData('cached_users');
    if (cachedData != null && cachedData is List) {
      _users.clear();
      _users.addAll(cachedData.map((item) => User.fromJson(item)).toList());
    } else {
      // Default mock users
      _users.addAll([
        User(id: '1', name: 'Admin User', phone: '0711111111', role: UserRole.admin),
        User(id: '2', name: 'Nairobi Agent', phone: '0722222222', role: UserRole.agent, branchId: '1'),
        User(id: '3', name: 'John Driver', phone: '0733333333', role: UserRole.driver),
        User(id: '4', name: 'Kapoeta Agent', phone: '0744444444', role: UserRole.agent, branchId: '4'),
        User(id: '5', name: 'Mike Asst', phone: '0755555555', role: UserRole.asstDriver),
      ]);
    }
    notifyListeners();
  }

  void addUser(User user) {
    _users.add(user);
    _saveToCache();
    notifyListeners();
  }

  void updateUser(User user) {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
      _saveToCache();
      notifyListeners();
    }
  }

  void transferAgent(String userId, String newBranchId) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final user = _users[index];
      _users[index] = User(
        id: user.id,
        name: user.name,
        phone: user.phone,
        email: user.email,
        role: user.role,
        branchId: newBranchId,
        isActive: user.isActive,
      );
      _saveToCache();
      notifyListeners();
    }
  }

  void toggleUserStatus(String id) {
    final index = _users.indexWhere((u) => u.id == id);
    if (index != -1) {
      final user = _users[index];
      _users[index] = User(
        id: user.id,
        name: user.name,
        phone: user.phone,
        email: user.email,
        role: user.role,
        branchId: user.branchId,
        isActive: !user.isActive,
      );
      _saveToCache();
      notifyListeners();
    }
  }

  void deleteUser(String id) {
    _users.removeWhere((u) => u.id == id);
    _saveToCache();
    notifyListeners();
  }

  void _saveToCache() {
    storageService?.cacheData('cached_users', _users.map((u) => u.toJson()).toList());
  }

  User? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }
}
