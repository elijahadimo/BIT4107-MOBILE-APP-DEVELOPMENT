import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../providers/shipment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/shipment.dart';
import 'package:go_router/go_router.dart';

enum ScannerMode {
  confirmArrival,
  confirmDispatch,
  confirmDelivery,
}

class QrScannerScreen extends StatefulWidget {
  final ScannerMode mode;

  const QrScannerScreen({super.key, required this.mode});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == ScannerMode.confirmArrival 
          ? 'Scan to Confirm Arrival' 
          : widget.mode == ScannerMode.confirmDispatch
            ? 'Scan to Confirm Dispatch'
            : 'Scan for Customer Pickup'),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (_isProcessing) return;
          
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? code = barcodes.first.rawValue;
            if (code != null) {
              _processCode(code);
            }
          }
        },
      ),
    );
  }

  Future<void> _processCode(String trackingNumber) async {
    setState(() => _isProcessing = true);
    
    final shipmentProvider = context.read<ShipmentProvider>();
    final authProvider = context.read<AuthProvider>();
    final shipment = shipmentProvider.getShipmentByTrackingNumber(trackingNumber);

    if (shipment == null) {
      _showResult('Error', 'Shipment $trackingNumber not found', Colors.red);
      return;
    }

    try {
      if (widget.mode == ScannerMode.confirmArrival) {
        await shipmentProvider.updateShipmentStatus(shipment.id, ShipmentStatus.arrived);
        _showResult('Success', 'Shipment $trackingNumber marked as ARRIVED', Colors.green);
      } else if (widget.mode == ScannerMode.confirmDispatch) {
        await shipmentProvider.updateShipmentStatus(shipment.id, ShipmentStatus.loaded);
        _showResult('Success', 'Shipment $trackingNumber marked as DISPATCHED/LOADED', Colors.green);
      } else if (widget.mode == ScannerMode.confirmDelivery) {
        // Check for COD
        if (shipment.paymentMethod == PaymentMethod.cod || shipment.paymentMethod == PaymentMethod.partialCod) {
          _showCodConfirmation(shipment, authProvider.user?.name ?? 'System Agent');
        } else {
          await shipmentProvider.updateShipmentStatus(
            shipment.id, 
            ShipmentStatus.delivered,
            deliveredBy: authProvider.user?.name,
          );
          _showResult('Success', 'Shipment $trackingNumber marked as DELIVERED by ${authProvider.user?.name}', Colors.green);
        }
      }
    } catch (e) {
      _showResult('Error', 'Failed to update shipment', Colors.red);
    }
  }

  void _showCodConfirmation(Shipment shipment, String agentName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Collect Payment (COD)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount to Collect: ${shipment.shippingCost} ${shipment.currency}', 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
            const SizedBox(height: 16),
            const Text('Has the customer paid the full amount?'),
          ],
        ),
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
              if (mounted) {
                Navigator.pop(ctx);
                _showResult('Success', 'Payment collected and shipment DELIVERED', Colors.green);
              }
            },
            child: const Text('CONFIRM PAYMENT & DELIVER'),
          ),
        ],
      ),
    );
  }

  void _showResult(String title, String message, Color color) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: TextStyle(color: color)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isProcessing = false);
            },
            child: const Text('SCAN NEXT'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }
}
