import 'package:flutter_test/flutter_test.dart';
import 'package:kapoeta_logistics/providers/auth_provider.dart';
import 'package:kapoeta_logistics/models/user.dart';
import 'mock_storage_service.dart';

void main() {
  group('AuthProvider Tests', () {
    late AuthProvider authProvider;
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
      authProvider = AuthProvider(storageService: mockStorage);
    });

    test('Initial state should be unauthenticated', () {
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.user, null);
    });

    test('Login as admin', () async {
      final success = await authProvider.login('admin', 'password');
      expect(success, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.user!.role, UserRole.admin);
      expect(authProvider.user!.name, 'Admin User');
    });

    test('Login as agent', () async {
      final success = await authProvider.login('agent', 'password');
      expect(success, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.user!.role, UserRole.agent);
      expect(authProvider.user!.branchId, 'nai-1');
    });

    test('Login as driver', () async {
      final success = await authProvider.login('driver', 'password');
      expect(success, true);
      expect(authProvider.isAuthenticated, true);
      expect(authProvider.user!.role, UserRole.driver);
    });

    test('Logout', () async {
      await authProvider.login('admin', 'password');
      authProvider.logout();
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.user, null);
    });
  });
}
