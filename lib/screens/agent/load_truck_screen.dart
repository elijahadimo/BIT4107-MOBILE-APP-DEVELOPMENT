import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/trip.dart';
import '../../models/shipment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/branch_provider.dart';
import '../../providers/shipment_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/user_provider.dart';
import 'package:go_router/go_router.dart';

class LoadTruckScreen extends StatefulWidget {
  const LoadTruckScreen({super.key});

  @override
  State<LoadTruckScreen> createState() => _LoadTruckScreenState();
}

class _LoadTruckScreenState extends State<LoadTruckScreen> {
  final _truckPlateController = TextEditingController();
  String? _selectedDriverId;
  String? _selectedAsstDriverId;
  String? _destinationBranchId;
  final List<String> _selectedShipmentIds = [];

  @override
  Widget build(BuildContext context) {
    final shipmentProvider = context.watch<ShipmentProvider>();
    final userProvider = context.watch<UserProvider>();
    final branchProvider = context.watch<BranchProvider>();
    final authProvider = context.read<AuthProvider>();

    final pendingShipments = shipmentProvider.shipments
        .where((s) => s.status == ShipmentStatus.pending && s.originBranchId == authProvider.user?.branchId)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Load Truck & Create Trip')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Truck & Crew', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            const SizedBox(height: 8),
            TextField(
              controller: _truckPlateController,
              decoration: const InputDecoration(hintText: 'Truck Plate Number'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedDriverId,
              decoration: const InputDecoration(hintText: 'Select Driver'),
              items: userProvider.drivers.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
              onChanged: (val) => setState(() => _selectedDriverId = val),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedAsstDriverId,
              decoration: const InputDecoration(hintText: 'Select Assistant Driver (Optional)'),
              items: userProvider.asstDrivers.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
              onChanged: (val) => setState(() => _selectedAsstDriverId = val),
            ),
            const SizedBox(height: 24),
            const Text('Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _destinationBranchId,
              decoration: const InputDecoration(hintText: 'Trip Final Destination'),
              items: branchProvider.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
              onChanged: (val) => setState(() => _destinationBranchId = val),
            ),
            const SizedBox(height: 24),
            Text('Select Shipments (${_selectedShipmentIds.length} selected)', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            const SizedBox(height: 8),
            if (pendingShipments.isEmpty)
              const Center(child: Text('No pending shipments to load', style: TextStyle(color: Colors.white70)))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pendingShipments.length,
                itemBuilder: (context, index) {
                  final s = pendingShipments[index];
                  final isSelected = _selectedShipmentIds.contains(s.id);
                  return Card(
                    color: isSelected ? Colors.orange.shade100 : Colors.white,
                    child: CheckboxListTile(
                      title: Text(s.trackingNumber),
                      subtitle: Text('To: ${branchProvider.getBranchById(s.destinationBranchId)?.name}'),
                      value: isSelected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedShipmentIds.add(s.id);
                          } else {
                            _selectedShipmentIds.remove(s.id);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedShipmentIds.isEmpty || _selectedDriverId == null || _destinationBranchId == null
                    ? null
                    : _submit,
                child: const Text('CREATE TRIP & LOAD'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    final tripProvider = context.read<TripProvider>();
    final authProvider = context.read<AuthProvider>();
    final branchProvider = context.read<BranchProvider>();
    
    final originBranch = branchProvider.getBranchById(authProvider.user?.branchId ?? '1');
    final destBranch = branchProvider.getBranchById(_destinationBranchId!);

    final trip = Trip(
      id: const Uuid().v4(),
      tripNumber: 'TRP-${DateTime.now().year}-${(tripProvider.trips.length + 1).toString().padLeft(3, '0')}',
      truckPlate: _truckPlateController.text,
      driverId: _selectedDriverId!,
      asstDriverId: _selectedAsstDriverId,
      route: '${originBranch?.name} to ${destBranch?.name}',
      departureBranchId: originBranch?.id ?? '1',
      arrivalBranchId: _destinationBranchId!,
      departureTime: DateTime.now(),
      estimatedArrival: DateTime.now().add(const Duration(days: 1)),
      status: TripStatus.planned,
      shipmentIds: _selectedShipmentIds,
    );

    await tripProvider.createTrip(trip);
    
    // Update shipment statuses
    if (mounted) {
      await context.read<ShipmentProvider>().updateMultipleShipmentStatuses(
        _selectedShipmentIds, 
        ShipmentStatus.loaded
      );
    }
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip created and shipments loaded!')),
      );
      context.pop();
    }
  }
}
