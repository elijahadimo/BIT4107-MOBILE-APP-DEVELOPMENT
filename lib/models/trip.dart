enum TripStatus {
  planned,
  inTransit,
  completed,
}

class Trip {
  final String id;
  final String tripNumber;
  final String truckPlate;
  final String driverId;
  final String? asstDriverId;
  final String route;
  final String departureBranchId;
  final String arrivalBranchId;
  final DateTime departureTime;
  final DateTime estimatedArrival;
  final DateTime? actualArrival;
  final TripStatus status;
  final double currentLatitude;
  final double currentLongitude;
  final List<String> shipmentIds;

  Trip({
    required this.id,
    required this.tripNumber,
    required this.truckPlate,
    required this.driverId,
    this.asstDriverId,
    required this.route,
    required this.departureBranchId,
    required this.arrivalBranchId,
    required this.departureTime,
    required this.estimatedArrival,
    this.actualArrival,
    required this.status,
    this.currentLatitude = 0.0,
    this.currentLongitude = 0.0,
    this.shipmentIds = const [],
  });

  Trip copyWith({
    String? id,
    String? tripNumber,
    String? truckPlate,
    String? driverId,
    String? asstDriverId,
    String? route,
    String? departureBranchId,
    String? arrivalBranchId,
    DateTime? departureTime,
    DateTime? estimatedArrival,
    DateTime? actualArrival,
    TripStatus? status,
    double? currentLatitude,
    double? currentLongitude,
    List<String>? shipmentIds,
  }) {
    return Trip(
      id: id ?? this.id,
      tripNumber: tripNumber ?? this.tripNumber,
      truckPlate: truckPlate ?? this.truckPlate,
      driverId: driverId ?? this.driverId,
      asstDriverId: asstDriverId ?? this.asstDriverId,
      route: route ?? this.route,
      departureBranchId: departureBranchId ?? this.departureBranchId,
      arrivalBranchId: arrivalBranchId ?? this.arrivalBranchId,
      departureTime: departureTime ?? this.departureTime,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      actualArrival: actualArrival ?? this.actualArrival,
      status: status ?? this.status,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
      shipmentIds: shipmentIds ?? this.shipmentIds,
    );
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      tripNumber: json['trip_number'],
      truckPlate: json['truck_plate'],
      driverId: json['driver_id'],
      asstDriverId: json['asst_driver_id'],
      route: json['route'],
      departureBranchId: json['departure_branch_id'],
      arrivalBranchId: json['arrival_branch_id'],
      departureTime: DateTime.parse(json['departure_time']),
      estimatedArrival: DateTime.parse(json['estimated_arrival']),
      actualArrival: json['actual_arrival'] != null ? DateTime.parse(json['actual_arrival']) : null,
      status: TripStatus.values.firstWhere((e) => e.name == json['status']),
      currentLatitude: (json['current_latitude'] as num).toDouble(),
      currentLongitude: (json['current_longitude'] as num).toDouble(),
      shipmentIds: List<String>.from(json['shipment_ids'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_number': tripNumber,
      'truck_plate': truckPlate,
      'driver_id': driverId,
      'asst_driver_id': asstDriverId,
      'route': route,
      'departure_branch_id': departureBranchId,
      'arrival_branch_id': arrivalBranchId,
      'departure_time': departureTime.toIso8601String(),
      'estimated_arrival': estimatedArrival.toIso8601String(),
      'actual_arrival': actualArrival?.toIso8601String(),
      'status': status.name,
      'current_latitude': currentLatitude,
      'current_longitude': currentLongitude,
      'shipment_ids': shipmentIds,
    };
  }
}
