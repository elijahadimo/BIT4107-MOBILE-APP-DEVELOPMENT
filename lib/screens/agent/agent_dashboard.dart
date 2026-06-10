import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import './qr_scanner_screen.dart';

import '../../providers/shipment_provider.dart';
import '../../providers/trip_provider.dart';
import '../../models/trip.dart';
import '../../models/shipment.dart';

class AgentDashboard extends StatelessWidget {
  const AgentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final shipmentProvider = context.watch<ShipmentProvider>();
    final authProvider = context.read<AuthProvider>();
    final myShipments = shipmentProvider.getShipmentsByBranch(authProvider.user?.branchId ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Dashboard'),
        actions: [
          IconButton(
            onPressed: () => context.push('/chat'),
            icon: const Icon(Icons.chat),
          ),
          IconButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildActionButton(context, Icons.add_box, 'Create New Shipment', () => context.push('/agent/create-shipment')),
          const SizedBox(height: 12),
          _buildActionButton(context, Icons.file_download, 'Confirm Arrivals (Scan)', () => context.push('/agent/scanner', extra: ScannerMode.confirmArrival)),
          const SizedBox(height: 12),
          _buildActionButton(context, Icons.check_circle, 'Customer Pickup (Scan)', () => context.push('/agent/scanner', extra: ScannerMode.confirmDelivery)),
          const SizedBox(height: 12),
          _buildActionButton(context, Icons.file_upload, 'Confirm Dispatched (Scan)', () => context.push('/agent/scanner', extra: ScannerMode.confirmDispatch)),
          const SizedBox(height: 12),
          _buildActionButton(context, Icons.local_shipping, 'Load Truck', () => context.push('/agent/load-truck')),
          const SizedBox(height: 12),
          _buildActionButton(context, Icons.inventory, 'Incoming Trips (Manual)', () => _showArrivedTripsDialog(context)),
          const SizedBox(height: 24),
          const Text('Recent Shipments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          if (myShipments.isEmpty)
            const Center(child: Text('No shipments yet', style: TextStyle(color: Colors.white70)))
          else
            ...myShipments.reversed.take(5).map((s) => Card(
              child: ListTile(
                title: Text(s.trackingNumber),
                subtitle: Text('To: ${s.destinationBranchId} | Status: ${s.status.name}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/agent/shipment-detail', extra: s),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.centerLeft,
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  void _showArrivedTripsDialog(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final tripProvider = context.read<TripProvider>();
    final shipmentProvider = context.read<ShipmentProvider>();
    final incomingTrips = tripProvider.getIncomingTrips(authProvider.user?.branchId ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Incoming Trips'),
        content: incomingTrips.isEmpty
            ? const Text('No active trips heading to this branch.')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: incomingTrips.length,
                  itemBuilder: (context, index) {
                    final trip = incomingTrips[index];
                    return ListTile(
                      title: Text(trip.tripNumber),
                      subtitle: Text('From: ${trip.route.split(' to ')[0]}'),
                      trailing: const Icon(Icons.check_circle_outline),
                      onTap: () async {
                        tripProvider.updateTripStatus(trip.id, TripStatus.completed);
                        await shipmentProvider.updateMultipleShipmentStatuses(
                          trip.shipmentIds,
                          ShipmentStatus.arrived,
                        );
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Trip marked as arrived. Shipments updated.')),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CLOSE')),
        ],
      ),
    );
  }
}
