enum IncidentType {
  accident,
  theft,
  damage,
  loss,
  delay,
}

enum IncidentSeverity {
  low,
  medium,
  high,
  critical,
}

enum IncidentStatus {
  reported,
  investigating,
  resolved,
}

class Incident {
  final String id;
  final String incidentNumber;
  final IncidentType type;
  final IncidentSeverity severity;
  final String description;
  final String? voiceNoteUrl;
  final String? shipmentId;
  final String? tripId;
  final String reportedBy;
  final List<String> photos;
  final IncidentStatus status;
  final double? refundAmount;
  final String? refundCurrency;
  final String? adminReply;
  final DateTime createdAt;

  Incident({
    required this.id,
    required this.incidentNumber,
    required this.type,
    required this.severity,
    required this.description,
    this.voiceNoteUrl,
    this.shipmentId,
    this.tripId,
    required this.reportedBy,
    this.photos = const [],
    required this.status,
    this.refundAmount,
    this.refundCurrency,
    this.adminReply,
    required this.createdAt,
  });

  Incident copyWith({
    String? id,
    String? incidentNumber,
    IncidentType? type,
    IncidentSeverity? severity,
    String? description,
    String? voiceNoteUrl,
    String? shipmentId,
    String? tripId,
    String? reportedBy,
    List<String>? photos,
    IncidentStatus? status,
    double? refundAmount,
    String? refundCurrency,
    String? adminReply,
    DateTime? createdAt,
  }) {
    return Incident(
      id: id ?? this.id,
      incidentNumber: incidentNumber ?? this.incidentNumber,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      description: description ?? this.description,
      voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
      shipmentId: shipmentId ?? this.shipmentId,
      tripId: tripId ?? this.tripId,
      reportedBy: reportedBy ?? this.reportedBy,
      photos: photos ?? this.photos,
      status: status ?? this.status,
      refundAmount: refundAmount ?? this.refundAmount,
      refundCurrency: refundCurrency ?? this.refundCurrency,
      adminReply: adminReply ?? this.adminReply,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Incident.fromJson(Map<String, dynamic> json) {
    return Incident(
      id: json['id'],
      incidentNumber: json['incident_number'],
      type: IncidentType.values.firstWhere((e) => e.toString().split('.').last == json['type']),
      severity: IncidentSeverity.values.firstWhere((e) => e.toString().split('.').last == json['severity']),
      description: json['description'],
      voiceNoteUrl: json['voice_note_url'],
      shipmentId: json['shipment_id'],
      tripId: json['trip_id'],
      reportedBy: json['reported_by'],
      photos: List<String>.from(json['photos'] ?? []),
      status: IncidentStatus.values.firstWhere((e) => e.toString().split('.').last == json['status']),
      refundAmount: json['refund_amount'] != null ? (json['refund_amount'] as num).toDouble() : null,
      refundCurrency: json['refund_currency'],
      adminReply: json['admin_reply'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'incident_number': incidentNumber,
      'type': type.toString().split('.').last,
      'severity': severity.toString().split('.').last,
      'description': description,
      'voice_note_url': voiceNoteUrl,
      'shipment_id': shipmentId,
      'trip_id': tripId,
      'reported_by': reportedBy,
      'photos': photos,
      'status': status.toString().split('.').last,
      'refund_amount': refundAmount,
      'refund_currency': refundCurrency,
      'admin_reply': adminReply,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
