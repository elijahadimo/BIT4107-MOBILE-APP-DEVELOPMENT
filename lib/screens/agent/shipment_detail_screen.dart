import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/shipment.dart';
import '../../providers/shipment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/pdf_service.dart';

class ShipmentDetailScreen extends StatelessWidget {
  final Shipment shipment;

  const ShipmentDetailScreen({super.key, required this.shipment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(shipment.trackingNumber)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text('Shipment QR Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    QrImageView(
                      data: shipment.trackingNumber,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                    const SizedBox(height: 16),
                    Text(shipment.trackingNumber, style: const TextStyle(fontSize: 16, letterSpacing: 2)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Sender', shipment.senderName),
            _buildDetailRow('Receiver', shipment.receiverName),
            _buildDetailRow('Status', shipment.status.name.toUpperCase()),
            _buildDetailRow('Cost', '${shipment.shippingCost} ${shipment.currency}'),
            const SizedBox(height: 32),
            if (shipment.status == ShipmentStatus.arrived)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final auth = context.read<AuthProvider>();
                    if (shipment.paymentMethod == PaymentMethod.cod || shipment.paymentMethod == PaymentMethod.partialCod) {
                      _showCodDialog(context, shipment, auth.user?.name ?? 'Agent');
                    } else {
                      await context.read<ShipmentProvider>().updateShipmentStatus(
                        shipment.id, 
                        ShipmentStatus.delivered,
                        deliveredBy: auth.user?.name,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Shipment marked as DELIVERED')),
                        );
                        Navigator.pop(context);
                      }
                    }
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('MARK AS DELIVERED / PICKED UP'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final bytes = await PdfService.generateWaybill(shipment);
                  await PdfService.saveAndShare(bytes, 'Waybill_${shipment.trackingNumber}.pdf');
                },
                icon: const Icon(Icons.description),
                label: const Text('GENERATE & SHARE WAYBILL'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final bytes = await PdfService.generateReceipt(shipment);
                  await PdfService.printDoc(bytes);
                },
                icon: const Icon(Icons.print),
                label: const Text('PRINT RECEIPT'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final bytes = await PdfService.generateReceipt(shipment);
                  await PdfService.saveAndShare(bytes, 'Receipt_${shipment.trackingNumber}.pdf');
                },
                icon: const Icon(Icons.share),
                label: const Text('SHARE RECEIPT'),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  void _showCodDialog(BuildContext context, Shipment shipment, String agentName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cash on Delivery'),
        content: Text('Please collect ${shipment.shippingCost} ${shipment.currency} from the customer before completing delivery.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              await context.read<ShipmentProvider>().updateShipmentStatus(
                shipment.id, 
                ShipmentStatus.delivered,
                deliveredBy: agentName,
                amountCollected: shipment.shippingCost,
              );
              if (context.mounted) {
                Navigator.pop(ctx);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment collected and delivery completed.')),
                );
              }
            },
            child: const Text('PAYMENT RECEIVED'),
          ),
        ],
      ),
    );
  }
}
