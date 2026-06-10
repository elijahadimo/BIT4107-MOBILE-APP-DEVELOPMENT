import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  final List<User> _users = [
    User(id: 'd1', name: 'John Doe', phone: '0712345678', role: UserRole.driver),
    User(id: 'd2', name: 'Jane Smith', phone: '0787654321', role: UserRole.driver),
    User(id: 'ad1', name: 'Mike Ross', phone: '0700000000', role: UserRole.asstDriver),
  ];

  List<User> get allUsers => _users;
  List<User> get drivers => _users.where((u) => u.role == UserRole.driver).toList();
  List<User> get asstDrivers => _users.where((u) => u.role == UserRole.asstDriver).toList();

  void addUser(User user) {
    _users.add(user);
    notifyListeners();
  }

  void updateUser(User user) {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      _users[index] = user;
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
      notifyListeners();
    }
  }

  void deleteUser(String id) {
    _users.removeWhere((u) => u.id == id);
    notifyListeners();
  }

  User? getUserById(String id) {
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (e) {
      return null;
    }
  }
}
