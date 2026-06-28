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
    // We still listen for connectivity, but we only sync 'ready' items
    connectivityProvider.addListener(_onConnectivityChanged);
  }

  void _onConnectivityChanged() {
    if (connectivityProvider.isOnline && !_isSyncing) {
      syncReadyQueue();
    }
  }

  // Called when internet returns OR when user manually triggers a sync
  Future<void> syncReadyQueue() async {
    final queue = storageService.getSyncQueue();
    final readyItems = queue.where((item) => item['status'] == 'ready').toList();
    
    if (readyItems.isEmpty || !connectivityProvider.isOnline) return;

    _isSyncing = true;
    final token = storageService.getToken();

    for (var action in readyItems) {
      try {
        await _processAction(action, token);
        // Successful sync, remove from the main queue using its ID
        await storageService.removeFromSyncQueue(action['id']);
      } catch (e) {
        // If an item fails, we stop to preserve order (if important) 
        // or just log it and move to next
        print('Sync failed for item ${action['id']}: $e');
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
