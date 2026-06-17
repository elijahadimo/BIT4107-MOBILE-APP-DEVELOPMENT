import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/trip_provider.dart';
import '../../models/trip.dart';

class FleetMapScreen extends StatefulWidget {
  const FleetMapScreen({super.key});

  @override
  State<FleetMapScreen> createState() => _FleetMapScreenState();
}

class _FleetMapScreenState extends State<FleetMapScreen> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final activeTrips = tripProvider.trips.where((t) => t.status == TripStatus.inTransit).toList();

    Set<Marker> markers = activeTrips.map((trip) {
      return Marker(
        markerId: MarkerId(trip.id),
        position: LatLng(trip.currentLatitude, trip.currentLongitude),
        infoWindow: InfoIDWindow(
          title: trip.tripNumber,
          snippet: 'Route: ${trip.route}\nTruck: ${trip.truckPlate}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      );
    }).toSet();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Fleet Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: activeTrips.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: Colors.white70),
                  SizedBox(height: 16),
                  Text('No active trips currently in transit', style: TextStyle(color: Colors.white)),
                ],
              ),
            )
          : GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(4.85, 31.58), // Center roughly on South Sudan/Kenya border
                zoom: 6,
              ),
              markers: markers,
              onMapCreated: (controller) => _mapController = controller,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
            ),
      bottomNavigationBar: activeTrips.isEmpty ? null : Container(
        height: 100,
        color: Colors.white,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: activeTrips.length,
          itemBuilder: (context, index) {
            final trip = activeTrips[index];
            return InkWell(
              onTap: () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    LatLng(trip.currentLatitude, trip.currentLongitude), 
                    12
                  ),
                );
              },
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trip.tripNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(trip.truckPlate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const Spacer(),
                    const Row(
                      children: [
                        Icon(Icons.circle, size: 10, color: Colors.green),
                        SizedBox(width: 4),
                        Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class InfoIDWindow extends InfoWindow {
  const InfoIDWindow({super.title, super.snippet});
}
