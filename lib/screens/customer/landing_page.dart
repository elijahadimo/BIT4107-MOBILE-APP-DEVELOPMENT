import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/shipment_provider.dart';
import '../../providers/cms_provider.dart';
import '../../models/shipment.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _trackingController = TextEditingController();
  Shipment? _foundShipment;
  bool _searched = false;

  @override
  Widget build(BuildContext context) {
    final cms = context.watch<CmsProvider>().content;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/icon.png',
                          height: 100,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.local_shipping, size: 80, color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          cms.title,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cms.subtitle,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  if (cms.notices.isNotEmpty)
                    Container(
                      height: 40,
                      color: Colors.orange.withOpacity(0.2),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: cms.notices.length,
                        itemBuilder: (context, index) => Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(cms.notices[index], style: const TextStyle(color: Colors.orange)),
                          ),
                        ),
                      ),
                    ),
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _trackingController,
                            decoration: const InputDecoration(
                              hintText: 'Enter Tracking Number',
                              prefixIcon: Icon(Icons.search),
                              fillColor: Colors.black12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _foundShipment = context.read<ShipmentProvider>().getShipmentByTrackingNumber(_trackingController.text);
                                  _searched = true;
                                });
                              },
                              child: const Text('TRACK SHIPMENT'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_searched)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: context.watch<ShipmentProvider>().error != null
                          ? Card(
                              child: ListTile(
                                leading: const Icon(Icons.warning, color: Colors.orange),
                                title: Text(context.read<ShipmentProvider>().error!),
                              ),
                            )
                          : (_foundShipment != null
                              ? _buildShipmentTimeline(_foundShipment!)
                              : const Card(
                                  child: ListTile(
                                    leading: Icon(Icons.error, color: Colors.red),
                                    title: Text('Shipment not found'),
                                    subtitle: Text('Please check the tracking number and try again.'),
                                  ),
                                )),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Are you a staff member? "),
                      TextButton(
                        onPressed: () => context.push('/login'),
                        child: const Text('Login here', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShipmentTimeline(Shipment shipment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tracking: ${shipment.trackingNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const Divider(),
            const SizedBox(height: 8),
            _buildStatusRow(Icons.check_circle, 'PENDING', shipment.status.index >= 0),
            _buildStatusRow(Icons.local_shipping, 'LOADED', shipment.status.index >= 1),
            _buildStatusRow(Icons.route, 'IN TRANSIT', shipment.status.index >= 2),
            _buildStatusRow(Icons.apartment, 'ARRIVED', shipment.status.index >= 3),
            _buildStatusRow(Icons.done_all, 'DELIVERED', shipment.status.index >= 4),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(IconData icon, String label, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: completed ? Colors.green : Colors.grey),
          const SizedBox(width: 16),
          Text(label,
              style: TextStyle(
                color: completed ? Colors.black : Colors.grey,
                fontWeight: completed ? FontWeight.bold : FontWeight.normal,
              )),
          const Spacer(),
          if (completed) const Icon(Icons.check, color: Colors.green),
        ],
      ),
    );
  }
}
