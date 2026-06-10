import 'package:flutter/material.dart';
import '../models/incident.dart';
import '../services/storage_service.dart';

class IncidentProvider extends ChangeNotifier {
  final List<Incident> _incidents = [];
  final StorageService storageService;

  IncidentProvider({required this.storageService}) {
    _loadCachedIncidents();
  }

  List<Incident> get incidents => _incidents;

  void _loadCachedIncidents() {
    final cachedData = storageService.getCachedData('cached_incidents');
    if (cachedData != null && cachedData is List) {
      _incidents.clear();
      _incidents.addAll(cachedData.map((item) => Incident.fromJson(item)).toList());
      notifyListeners();
    }
  }

  Future<void> reportIncident(Incident incident) async {
    _incidents.add(incident);
    await storageService.cacheData('cached_incidents', _incidents.map((i) => i.toJson()).toList());
    
    try {
      // Mock API call
      // await api.post('/incidents', incident.toJson());
    } catch (e) {
      await storageService.addToSyncQueue({
        'type': 'report_incident',
        'payload': incident.toJson(),
      });
    }
    notifyListeners();
  }

  void updateIncident(Incident incident) {
    final index = _incidents.indexWhere((i) => i.id == incident.id);
    if (index != -1) {
      _incidents[index] = incident;
      storageService.cacheData('cached_incidents', _incidents.map((i) => i.toJson()).toList());
      notifyListeners();
    }
  }

  void resolveIncident(String id, String reply) {
    final index = _incidents.indexWhere((i) => i.id == id);
    if (index != -1) {
      _incidents[index] = _incidents[index].copyWith(
        status: IncidentStatus.resolved,
        adminReply: reply,
      );
      storageService.cacheData('cached_incidents', _incidents.map((i) => i.toJson()).toList());
      notifyListeners();
    }
  }
}
