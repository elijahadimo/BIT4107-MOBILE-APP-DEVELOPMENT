import 'package:flutter/material.dart';
import '../models/shipment.dart';
import '../services/api_service.dart';
import '../services/exceptions.dart';
import '../services/storage_service.dart';

class ShipmentProvider extends ChangeNotifier {
  final List<Shipment> _shipments = [];
  bool _isLoading = false;
  String? _error;
  final ApiService _apiService = ApiService();
  final StorageService storageService;

  ShipmentProvider({required this.storageService}) {
    _loadCachedShipments();
  }

  List<Shipment> get shipments => _shipments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _loadCachedShipments() {
    final cachedData = storageService.getCachedData('cached_shipments');
    if (cachedData != null && cachedData is List) {
      _shipments.clear();
      _shipments.addAll(cachedData.map((item) => Shipment.fromJson(item)).toList());
      notifyListeners();
    }
  }

  Future<void> fetchShipments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = storageService.getToken();
      // Real API call
      // final List<dynamic> data = await _apiService.get('/shipments', token: token);
      
      // Mocking successful fetch for demo
      await Future.delayed(const Duration(seconds: 1));
      
      // If we had real data, we would update _shipments and cache it
      // _shipments.clear();
      // _shipments.addAll(data.map((item) => Shipment.fromJson(item)).toList());
      // await storageService.cacheData('cached_shipments', _shipments.map((s) => s.toJson()).toList());
      
    } on ApiException catch (e) {
      _error = e.message;
    } on NetworkException {
      _error = 'Offline: Showing cached data';
    } catch (e) {
      _error = 'Failed to load shipments';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createShipment(Shipment shipment) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = storageService.getToken();
      // Try real API call
      // await _apiService.post('/shipments', shipment.toJson(), token: token);
      
      // Update local state and cache immediately
      _shipments.add(shipment);
      await storageService.cacheData('cached_shipments', _shipments.map((s) => s.toJson()).toList());
    } catch (e) {
      // If API fails (e.g. offline), add to sync queue
      await storageService.addToSyncQueue({
        'type': 'create_shipment',
        'payload': shipment.toJson(),
      });
      _error = 'Offline: Shipment saved locally and will sync later.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ... (tracking number and getters) ...

  Future<void> updateShipmentStatus(String id, ShipmentStatus status, {String? deliveredBy, double? amountCollected}) async {
    final index = _shipments.indexWhere((s) => s.id == id);
    if (index != -1) {
      final updatedShipment = _shipments[index].copyWith(
        status: status,
        deliveredBy: deliveredBy,
        amountCollected: amountCollected,
        deliveredAt: status == ShipmentStatus.delivered ? DateTime.now() : null,
      );
      
      _shipments[index] = updatedShipment;
      await storageService.cacheData('cached_shipments', _shipments.map((s) => s.toJson()).toList());
      
      // Try to sync with API
      try {
        // await _apiService.post('/shipments/update-status', {
        //   'id': id,
        //   'status': status.name,
        //   'delivered_by': deliveredBy,
        //   'amount_collected': amountCollected,
        // });
      } catch (e) {
        // Add to sync queue if offline
        await storageService.addToSyncQueue({
          'type': 'update_shipment_status',
          'payload': {
            'id': id,
            'status': status.name,
            'delivered_by': deliveredBy,
            'amount_collected': amountCollected,
          },
        });
      }
      notifyListeners();
    }
  }

  Future<void> updateMultipleShipmentStatuses(List<String> ids, ShipmentStatus status) async {
    for (var id in ids) {
      final index = _shipments.indexWhere((s) => s.id == id);
      if (index != -1) {
        _shipments[index] = _shipments[index].copyWith(status: status);
      }
    }
    await storageService.cacheData('cached_shipments', _shipments.map((s) => s.toJson()).toList());
    notifyListeners();
  }
}
