import 'dart:async';
import 'api_service.dart';
import 'storage_service.dart';
import '../providers/connectivity_provider.dart';

class SyncService {
  final ApiService _apiService = ApiService();
  final StorageService storageService;
  final ConnectivityProvider connectivityProvider;
  bool _isSyncing = false;

  SyncService({
    required this.storageService,
    required this.connectivityProvider,
  }) {
    // Listen for connectivity changes to trigger sync
    connectivityProvider.addListener(_onConnectivityChanged);
  }

  void _onConnectivityChanged() {
    if (connectivityProvider.isOnline && !_isSyncing) {
      syncQueue();
    }
  }

  Future<void> syncQueue() async {
    final queue = storageService.getSyncQueue();
    if (queue.isEmpty) return;

    _isSyncing = true;
    final token = storageService.getToken();

    for (int i = 0; i < queue.length; i++) {
      final action = queue[i];
      try {
        await _processAction(action, token);
        // If successful, we'll remove it after the loop or one by one
        // One by one is safer if sync fails in the middle
        await storageService.removeFromSyncQueue(0); 
        i--; // Adjust index because we removed an item
      } catch (e) {
        // If an action fails, stop syncing (maybe server is down but internet is up)
        break;
      }
    }

    _isSyncing = false;
  }

  Future<void> _processAction(Map<String, dynamic> action, String? token) async {
    final String type = action['type'];
    final Map<String, dynamic> payload = action['payload'];

    switch (type) {
      case 'create_shipment':
        await _apiService.post('/shipments', payload, token: token);
        break;
      case 'update_shipment_status':
        await _apiService.post('/shipments/update-status', payload, token: token);
        break;
      case 'create_trip':
        await _apiService.post('/trips', payload, token: token);
        break;
      case 'report_incident':
        await _apiService.post('/incidents', payload, token: token);
        break;
      default:
        print('Unknown sync action type: $type');
    }
  }
}
