import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/exceptions.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService();
  final StorageService storageService;

  AuthProvider({required this.storageService}) {
    _loadUser();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;

  void _loadUser() {
    _user = storageService.getUser();
    notifyListeners();
  }

  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Mock Logic for Demo
      await Future.delayed(const Duration(seconds: 1));
      
      if (password != 'password') {
        throw ValidationException('Invalid password. For demo use "password"');
      }

      final identifier = phone.trim().toLowerCase();
      User user;
      if (identifier == 'admin') {
        user = User(id: '1', name: 'Admin User', phone: 'admin', role: UserRole.admin);
      } else if (identifier == 'agent') {
        user = User(id: '2', name: 'Agent User', phone: 'agent', role: UserRole.agent, branchId: 'nai-1');
      } else if (identifier == 'driver') {
        user = User(id: '3', name: 'Driver User', phone: 'driver', role: UserRole.driver);
      } else if (identifier == 'asst') {
        user = User(id: '4', name: 'Assistant Driver', phone: 'asst', role: UserRole.asstDriver);
      } else {
        throw ValidationException('User not found. Use admin, agent, driver, or asst');
      }

      _user = user;
      await storageService.saveUser(user);
      await storageService.saveToken('dummy_token_123'); // Save a mock token

      _isLoading = false;
      notifyListeners();
      return true;

    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    await storageService.clearAuth();
    notifyListeners();
  }
}
