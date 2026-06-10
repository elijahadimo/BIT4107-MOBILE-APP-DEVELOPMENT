enum ShipmentStatus {
  pending,
  loaded,
  inTransit,
  arrived,
  delivered,
  lost,
  damaged,
}

enum PaymentMethod {
  prepaid,
  cod,
  partialCod,
}

class Shipment {
  final String id;
  final String trackingNumber;
  final String senderName;
  final String senderPhone;
  final String receiverName;
  final String receiverPhone;
  final String itemDescription;
  final double weight;
  final String originBranchId;
  final String destinationBranchId;
  final double shippingCost;
  final double goodsValue;
  final String currency; // KES, SSP, USD
  final PaymentMethod paymentMethod;
  final ShipmentStatus status;
  final List<String> photos;
  final String? tripId;
  final String createdBy;
  final String? deliveredBy;
  final double? amountCollected;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  Shipment({
    required this.id,
    required this.trackingNumber,
    required this.senderName,
    required this.senderPhone,
    required this.receiverName,
    required this.receiverPhone,
    required this.itemDescription,
    required this.weight,
    required this.originBranchId,
    required this.destinationBranchId,
    required this.shippingCost,
    required this.goodsValue,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    this.photos = const [],
    this.tripId,
    required this.createdBy,
    this.deliveredBy,
    this.amountCollected,
    required this.createdAt,
    this.deliveredAt,
  });

  Shipment copyWith({
    String? id,
    String? trackingNumber,
    String? senderName,
    String? senderPhone,
    String? receiverName,
    String? receiverPhone,
    String? itemDescription,
    double? weight,
    String? originBranchId,
    String? destinationBranchId,
    double? shippingCost,
    double? goodsValue,
    String? currency,
    PaymentMethod? paymentMethod,
    ShipmentStatus? status,
    List<String>? photos,
    String? tripId,
    String? createdBy,
    String? deliveredBy,
    double? amountCollected,
    DateTime? createdAt,
    DateTime? deliveredAt,
  }) {
    return Shipment(
      id: id ?? this.id,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      senderName: senderName ?? this.senderName,
      senderPhone: senderPhone ?? this.senderPhone,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      itemDescription: itemDescription ?? this.itemDescription,
      weight: weight ?? this.weight,
      originBranchId: originBranchId ?? this.originBranchId,
      destinationBranchId: destinationBranchId ?? this.destinationBranchId,
      shippingCost: shippingCost ?? this.shippingCost,
      goodsValue: goodsValue ?? this.goodsValue,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      photos: photos ?? this.photos,
      tripId: tripId ?? this.tripId,
      createdBy: createdBy ?? this.createdBy,
      deliveredBy: deliveredBy ?? this.deliveredBy,
      amountCollected: amountCollected ?? this.amountCollected,
      createdAt: createdAt ?? this.createdAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  factory Shipment.fromJson(Map<String, dynamic> json) {
    return Shipment(
      id: json['id'],
      trackingNumber: json['tracking_number'],
      senderName: json['sender_name'],
      senderPhone: json['sender_phone'],
      receiverName: json['receiver_name'],
      receiverPhone: json['receiver_phone'],
      itemDescription: json['item_description'],
      weight: (json['weight'] as num).toDouble(),
      originBranchId: json['origin_branch_id'],
      destinationBranchId: json['destination_branch_id'],
      shippingCost: (json['shipping_cost'] as num).toDouble(),
      goodsValue: (json['goods_value'] as num).toDouble(),
      currency: json['currency'],
      paymentMethod: PaymentMethod.values.firstWhere((e) => e.name == json['payment_method']),
      status: ShipmentStatus.values.firstWhere((e) => e.name == json['status']),
      photos: List<String>.from(json['photos'] ?? []),
      tripId: json['trip_id'],
      createdBy: json['created_by'],
      deliveredBy: json['delivered_by'],
      amountCollected: json['amount_collected'] != null ? (json['amount_collected'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['created_at']),
      deliveredAt: json['delivered_at'] != null ? DateTime.parse(json['delivered_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tracking_number': trackingNumber,
      'sender_name': senderName,
      'sender_phone': senderPhone,
      'receiver_name': receiverName,
      'receiver_phone': receiverPhone,
      'item_description': itemDescription,
      'weight': weight,
      'origin_branch_id': originBranchId,
      'destination_branch_id': destinationBranchId,
      'shipping_cost': shippingCost,
      'goods_value': goodsValue,
      'currency': currency,
      'payment_method': paymentMethod.name,
      'status': status.name,
      'photos': photos,
      'trip_id': tripId,
      'created_by': createdBy,
      'delivered_by': deliveredBy,
      'amount_collected': amountCollected,
      'created_at': createdAt.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }
}
