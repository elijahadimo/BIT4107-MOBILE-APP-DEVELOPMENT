import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../common/report_generator_widget.dart';
import '../../models/user.dart';

import '../../providers/trip_provider.dart';
import '../../providers/shipment_provider.dart';
import '../../models/trip.dart';
import '../../models/shipment.dart';

class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final tripProvider = context.watch<TripProvider>();
    final activeTrip = tripProvider.getTripByDriver(authProvider.user?.id ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
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
      body: activeTrip == null
          ? const Center(child: Text('No active trips assigned', style: TextStyle(color: Colors.white)))
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(child: Icon(Icons.person)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Active Trip: ${activeTrip.tripNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Route: ${activeTrip.route}'),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.push('/business-card'),
                        icon: const Icon(Icons.badge, color: Colors.orange),
                        tooltip: 'Digital ID',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                'Current Status: ${activeTrip.status.name.toUpperCase()}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: activeTrip.status == TripStatus.inTransit ? Colors.green : Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (activeTrip.status == TripStatus.planned)
                                ElevatedButton(
                                  onPressed: () async {
                                    final tripProvider = context.read<TripProvider>();
                                    final shipmentProvider = context.read<ShipmentProvider>();
                                    
                                    tripProvider.updateTripStatus(activeTrip.id, TripStatus.inTransit);
                                    await shipmentProvider.updateMultipleShipmentStatuses(
                                      activeTrip.shipmentIds, 
                                      ShipmentStatus.inTransit
                                    );

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Journey started! Shipments are now IN TRANSIT.')),
                                      );
                                    }
                                  },
                                  child: const Text('START JOURNEY'),
                                )
                              else
                                const Text('In progress...'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        color: tripProvider.isTrackingActive ? Colors.green.shade50 : null,
                        child: SwitchListTile(
                          title: const Text('Live Tracking Activation', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(tripProvider.isTrackingActive 
                            ? 'GPS Tracking is ON' 
                            : 'Activate GPS tracking when you start your journey'),
                          value: tripProvider.isTrackingActive,
                          onChanged: activeTrip.status == TripStatus.inTransit 
                            ? (val) => tripProvider.toggleLiveTracking(activeTrip.id)
                            : null,
                          secondary: Icon(
                            Icons.location_on, 
                            color: tripProvider.isTrackingActive ? Colors.green : Colors.grey
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Update location logic
                          tripProvider.updateLocation(activeTrip.id, 4.76, 33.58);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Location updated: 4.76, 33.58')),
                          );
                        },
                        icon: const Icon(Icons.location_on),
                        label: const Text('Update My Location'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showFuelDialog(context);
                        },
                        icon: const Icon(Icons.local_gas_station),
                        label: const Text('Log Fuel Purchase'),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => context.push('/driver/report-incident', extra: {'tripId': activeTrip.id}),
                        icon: const Icon(Icons.report_problem),
                        label: const Text('Report Incident'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      ),
                      const SizedBox(height: 24),
                      const ReportGeneratorWidget(initialRole: UserRole.driver),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _showFuelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Fuel Purchase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(labelText: 'Amount (Liters)'),
              keyboardType: TextInputType.number,
            ),
            const TextField(
              decoration: InputDecoration(labelText: 'Cost'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt),
              label: const Text('Upload Receipt'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fuel purchase logged successfully')),
              );
            },
            child: const Text('LOG'),
          ),
        ],
      ),
    );
  }
}
