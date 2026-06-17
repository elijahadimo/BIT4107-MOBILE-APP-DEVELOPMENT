import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../common/report_generator_widget.dart';
import '../../models/user.dart';

import '../../providers/shipment_provider.dart';
import '../../providers/branch_provider.dart';
import '../../models/shipment.dart';
import 'package:go_router/go_router.dart';

class AsstDriverDashboard extends StatelessWidget {
  const AsstDriverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final shipmentProvider = context.watch<ShipmentProvider>();
    final branchProvider = context.watch<BranchProvider>();

    // Filter for shipments that are "arrived" at branches with no agent
    final pendingDeliveries = shipmentProvider.shipments.where((s) {
      final branch = branchProvider.getBranchById(s.destinationBranchId);
      return s.status == ShipmentStatus.arrived && (branch?.hasAgent == false);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant Driver'),
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
          ElevatedButton.icon(
            onPressed: () => context.push('/business-card'),
            icon: const Icon(Icons.badge),
            label: const Text('MY DIGITAL ID'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange,
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 24),
          const ReportGeneratorWidget(initialRole: UserRole.asstDriver),
          const SizedBox(height: 24),
          const Text(
            'Deliveries at Unmanned Branches',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          if (pendingDeliveries.isEmpty)
            const Center(child: Text('No pending deliveries found', style: TextStyle(color: Colors.white70)))
          else
            ...pendingDeliveries.map((s) => _buildDeliveryCard(context, s)),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context, Shipment shipment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(shipment.trackingNumber),
        subtitle: Text('To: ${shipment.receiverName}'),
        trailing: ElevatedButton(
          onPressed: () => context.push('/asst-driver/delivery', extra: shipment),
          child: const Text('DELIVER'),
        ),
      ),
    );
  }
}
