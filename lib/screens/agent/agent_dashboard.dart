import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import './qr_scanner_screen.dart';
import '../common/report_generator_widget.dart';
import '../../models/user.dart';

import '../../providers/shipment_provider.dart';
import '../../providers/trip_provider.dart';
import '../../models/trip.dart';
import '../../models/shipment.dart';
import '../../services/storage_service.dart';

class AgentDashboard extends StatelessWidget {
  const AgentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final shipmentProvider = context.watch<ShipmentProvider>();
    final authProvider = context.read<AuthProvider>();
    final myShipments = shipmentProvider.getShipmentsByBranch(authProvider.user?.branchId ?? '');
    final shipmentsAtBranch = myShipments.where((s) => s.status == ShipmentStatus.arrived || s.status == ShipmentStatus.pending).length;
    final syncQueue = context.watch<StorageService>().getSyncQueue();
    final draftCount = syncQueue.where((item) => item['status'] == 'draft').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Dashboard'),
        actions: [
          if (syncQueue.isNotEmpty)
            Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () => context.push('/sync-manager'),
                  icon: const Icon(Icons.cloud_upload_outlined),
                ),
                if (draftCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text('$draftCount', style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                    ),
                  ),
              ],
            ),
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
          _buildBranchSummaryCard(authProvider.user?.branchId ?? 'Main', shipmentsAtBranch),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildActionButton(context, Icons.add_box, 'Single', () => context.push('/agent/create-shipment'))),
              const SizedBox(width: 8),
              Expanded(child: _buildActionButton(context, Icons.dynamic_feed, 'Bulk (1-N/N-1)', () => context.push('/agent/bulk-shipment'))),
            ],
          ),
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
          const SizedBox(height: 12),
          _buildActionButton(context, Icons.badge, 'My Digital ID', () => context.push('/business-card')),
          const SizedBox(height: 24),
          const ReportGeneratorWidget(initialRole: UserRole.agent),
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

  Widget _buildBranchSummaryCard(String branchId, int count) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current Branch', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(branchId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const Icon(Icons.warehouse, color: Colors.orange, size: 30),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Shipments in Stock:', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(12)),
                  child: Text(count.toString(), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
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
