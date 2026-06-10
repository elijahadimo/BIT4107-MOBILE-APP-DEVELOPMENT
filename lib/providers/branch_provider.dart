import 'package:flutter/material.dart';
import '../models/branch.dart';
import '../services/storage_service.dart';

class BranchProvider extends ChangeNotifier {
  final List<Branch> _branches = [];
  final StorageService? storageService;

  BranchProvider({this.storageService}) {
    _loadBranches();
  }

  List<Branch> get branches => _branches;

  void _loadBranches() {
    final cachedData = storageService?.getCachedData('cached_branches');
    if (cachedData != null && cachedData is List) {
      _branches.clear();
      _branches.addAll(cachedData.map((item) => Branch.fromJson(item)).toList());
    } else {
      _branches.addAll([
        Branch(id: '1', name: 'Nairobi', location: 'Headquarters', country: 'Kenya', type: BranchType.hq, latitude: -1.2921, longitude: 36.8219, hasAgent: true),
        Branch(id: '2', name: 'Nadapal', location: 'Border Post', country: 'Kenya/South Sudan', type: BranchType.border, latitude: 4.4051, longitude: 34.2837, hasAgent: false),
        Branch(id: '3', name: 'Narus', location: 'Local Branch', country: 'South Sudan', type: BranchType.local, latitude: 4.5020, longitude: 34.1633, hasAgent: false),
        Branch(id: '4', name: 'Kapoeta', location: 'Local Branch', country: 'South Sudan', type: BranchType.local, latitude: 4.7667, longitude: 33.5833, hasAgent: true),
        Branch(id: '5', name: 'Torit', location: 'Local Branch', country: 'South Sudan', type: BranchType.local, latitude: 4.4167, longitude: 32.5667, hasAgent: false),
        Branch(id: '6', name: 'Juba', location: 'City Branch', country: 'South Sudan', type: BranchType.city, latitude: 4.8517, longitude: 31.5825, hasAgent: true),
      ]);
    }
    notifyListeners();
  }

  void addBranch(Branch branch) {
    _branches.add(branch);
    storageService?.cacheData('cached_branches', _branches.map((b) => b.toJson()).toList());
    notifyListeners();
  }

  void updateBranch(Branch branch) {
    final index = _branches.indexWhere((b) => b.id == branch.id);
    if (index != -1) {
      _branches[index] = branch;
      storageService?.cacheData('cached_branches', _branches.map((b) => b.toJson()).toList());
      notifyListeners();
    }
  }

  void deleteBranch(String id) {
    _branches.removeWhere((b) => b.id == id);
    storageService?.cacheData('cached_branches', _branches.map((b) => b.toJson()).toList());
    notifyListeners();
  }

  Branch? getBranchById(String id) {
    try {
      return _branches.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }
}
