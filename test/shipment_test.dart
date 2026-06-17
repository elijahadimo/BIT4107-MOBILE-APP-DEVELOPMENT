import 'package:flutter_test/flutter_test.dart';
import 'package:kapoeta_logistics/providers/shipment_provider.dart';
import 'package:kapoeta_logistics/models/shipment.dart';
import 'package:uuid/uuid.dart';
import 'mock_storage_service.dart';

void main() {
  group('ShipmentProvider Tests', () {
    late ShipmentProvider shipmentProvider;
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
      shipmentProvider = ShipmentProvider(storageService: mockStorage);
    });

    test('Create and retrieve shipment', () async {
      final shipment = Shipment(
        id: const Uuid().v4(),
        trackingNumber: shipmentProvider.generateTrackingNumber('Nairobi'),
        senderName: 'Sender',
        senderPhone: '123',
        receiverName: 'Receiver',
        receiverPhone: '456',
        itemDescription: 'Test Item',
        weight: 10.0,
        originBranchId: '1',
        destinationBranchId: '6',
        shippingCost: 500.0,
        goodsValue: 1000.0,
        currency: 'KES',
        paymentMethod: PaymentMethod.prepaid,
        status: ShipmentStatus.pending,
        createdBy: 'agent-1',
        createdAt: DateTime.now(),
      );

      await shipmentProvider.createShipment(shipment);
      
      expect(shipmentProvider.shipments.length, 1);
      
      final found = shipmentProvider.getShipmentByTrackingNumber(shipment.trackingNumber);
      expect(found, isNotNull);
      expect(found!.trackingNumber, startsWith('KL-NAI-'));
    });

    test('Filter shipments by branch', () async {
      final s1 = Shipment(
        id: '1',
        trackingNumber: 'T1',
        senderName: 'S', senderPhone: 'P', receiverName: 'R', receiverPhone: 'RP',
        itemDescription: 'D', weight: 1, originBranchId: '1', destinationBranchId: '2',
        shippingCost: 1, goodsValue: 1, currency: 'KES', paymentMethod: PaymentMethod.prepaid,
        status: ShipmentStatus.pending, createdBy: 'A', createdAt: DateTime.now(),
      );
      final s2 = Shipment(
        id: '2',
        trackingNumber: 'T2',
        senderName: 'S', senderPhone: 'P', receiverName: 'R', receiverPhone: 'RP',
        itemDescription: 'D', weight: 1, originBranchId: '2', destinationBranchId: '3',
        shippingCost: 1, goodsValue: 1, currency: 'KES', paymentMethod: PaymentMethod.prepaid,
        status: ShipmentStatus.pending, createdBy: 'A', createdAt: DateTime.now(),
      );

      await shipmentProvider.createShipment(s1);
      await shipmentProvider.createShipment(s2);

      final branch1Shipments = shipmentProvider.getShipmentsByBranch('1');
      expect(branch1Shipments.length, 1);
      expect(branch1Shipments.first.id, '1');

      final branch2Shipments = shipmentProvider.getShipmentsByBranch('2');
      expect(branch2Shipments.length, 2); // Origin for s2, Destination for s1
    });
  });
}
