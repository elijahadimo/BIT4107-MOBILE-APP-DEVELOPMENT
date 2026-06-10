enum BranchType {
  hq,
  border,
  city,
  local,
}

class Branch {
  final String id;
  final String name;
  final String location;
  final String country;
  final BranchType type;
  final double latitude;
  final double longitude;
  final int geofenceRadius;
  final bool hasAgent;
  final String? contactPhone;
  final String? contactEmail;
  final bool isActive;

  Branch({
    required this.id,
    required this.name,
    required this.location,
    required this.country,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.geofenceRadius = 500,
    required this.hasAgent,
    this.contactPhone,
    this.contactEmail,
    this.isActive = true,
  });

  Branch copyWith({
    String? id,
    String? name,
    String? location,
    String? country,
    BranchType? type,
    double? latitude,
    double? longitude,
    int? geofenceRadius,
    bool? hasAgent,
    String? contactPhone,
    String? contactEmail,
    bool? isActive,
  }) {
    return Branch(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      country: country ?? this.country,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      geofenceRadius: geofenceRadius ?? this.geofenceRadius,
      hasAgent: hasAgent ?? this.hasAgent,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      country: json['country'],
      type: BranchType.values.firstWhere((e) => e.toString().split('.').last == json['type']),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      geofenceRadius: json['geofence_radius'] ?? 500,
      hasAgent: json['has_agent'] ?? false,
      contactPhone: json['contact_phone'],
      contactEmail: json['contact_email'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'country': country,
      'type': type.toString().split('.').last,
      'latitude': latitude,
      'longitude': longitude,
      'geofence_radius': geofenceRadius,
      'has_agent': hasAgent,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'is_active': isActive,
    };
  }
}
