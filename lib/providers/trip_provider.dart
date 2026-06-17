import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/storage_service.dart';

class TripProvider extends ChangeNotifier {
  final List<Trip> _trips = [];
  bool _isLoading = false;
  final StorageService storageService;

  TripProvider({required this.storageService}) {
    _loadCachedTrips();
  }

  List<Trip> get trips => _trips;
  bool get isLoading => _isLoading;

  void _loadCachedTrips() {
    final cachedData = storageService.getCachedData('cached_trips');
    if (cachedData != null && cachedData is List) {
      _trips.clear();
      _trips.addAll(cachedData.map((item) => Trip.fromJson(item)).toList());
    } else {
      // Default mock data if no cache
      _trips.add(Trip(
        id: 't1',
        tripNumber: 'TRP-2024-001',
        truckPlate: 'KBA 123X',
        driverId: '3',
        route: 'Nairobi to Kapoeta',
        departureBranchId: '1',
        arrivalBranchId: '4',
        departureTime: DateTime.now(),
        estimatedArrival: DateTime.now().add(const Duration(days: 2)),
        status: TripStatus.planned,
        shipmentIds: ['s1'],
      ));
    }
    notifyListeners();
  }

  Future<void> createTrip(Trip trip) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Mock API call simulation
      // await api.post('/trips', trip.toJson());
      
      _trips.add(trip);
      await storageService.cacheData('cached_trips', _trips.map((t) => t.toJson()).toList());
    } catch (e) {
      await storageService.addToSyncQueue({
        'type': 'create_trip',
        'payload': trip.toJson(),
      });
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Trip? getTripByDriver(String driverId) {
    try {
      return _trips.firstWhere((t) => t.driverId == driverId && t.status != TripStatus.completed);
    } catch (e) {
      return null;
    }
  }

  void updateLocation(String tripId, double lat, double lng) {
    final index = _trips.indexWhere((t) => t.id == tripId);
    if (index != -1) {
      _trips[index] = _trips[index].copyWith(
        currentLatitude: lat,
        currentLongitude: lng,
      );
      storageService.cacheData('cached_trips', _trips.map((t) => t.toJson()).toList());
      notifyListeners();
    }
  }

  void updateTripStatus(String tripId, TripStatus status) {
    final index = _trips.indexWhere((t) => t.id == tripId);
    if (index != -1) {
      _trips[index] = _trips[index].copyWith(status: status);
      storageService.cacheData('cached_trips', _trips.map((t) => t.toJson()).toList());
      notifyListeners();
    }
  }

  List<Trip> getIncomingTrips(String branchId) {
    return _trips.where((t) => t.arrivalBranchId == branchId && t.status != TripStatus.completed).toList();
  }

  List<Trip> getTripsByDateRange(DateTime start, DateTime end, {String? driverId}) {
    return _trips.where((t) {
      final matchesDate = t.departureTime.isAfter(start) && t.departureTime.isBefore(end.add(const Duration(days: 1)));
      final matchesDriver = driverId == null || t.driverId == driverId;
      return matchesDate && matchesDriver;
    }).toList();
  }
}
