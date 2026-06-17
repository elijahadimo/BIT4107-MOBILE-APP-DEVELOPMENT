import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shipment_provider.dart';
import '../../models/shipment.dart';
import 'package:intl/intl.dart';

class ShipmentLedgerScreen extends StatelessWidget {
  const ShipmentLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shipmentProvider = context.watch<ShipmentProvider>();
    final shipments = shipmentProvider.shipments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipment Ledger'),
      ),
      body: shipments.isEmpty
          ? const Center(child: Text('No shipments recorded yet.'))
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Tracking No')),
                  DataColumn(label: Text('Sender')),
                  DataColumn(label: Text('Receiver')),
                  DataColumn(label: Text('Destination')),
                  DataColumn(label: Text('Item')),
                  DataColumn(label: Text('Weight')),
                  DataColumn(label: Text('Cost')),
                  DataColumn(label: Text('Status')),
                ],
                rows: shipments.map((s) => DataRow(cells: [
                  DataCell(Text(DateFormat('yy-MM-dd').format(s.createdAt))),
                  DataCell(Text(s.trackingNumber)),
                  DataCell(Text(s.senderName)),
                  DataCell(Text(s.receiverName)),
                  DataCell(Text(s.destinationBranchId)),
                  DataCell(Text(s.itemDescription, overflow: TextOverflow.ellipsis)),
                  DataCell(Text('${s.weight.toStringAsFixed(1)} kg')),
                  DataCell(Text('${s.shippingCost} ${s.currency}')),
                  DataCell(_buildStatusChip(s.status)),
                ])).toList(),
              ),
            ),
    );
  }

  Widget _buildStatusChip(ShipmentStatus status) {
    Color color;
    switch (status) {
      case ShipmentStatus.pending: color = Colors.orange; break;
      case ShipmentStatus.loaded: color = Colors.blue; break;
      case ShipmentStatus.inTransit: color = Colors.purple; break;
      case ShipmentStatus.arrived: color = Colors.teal; break;
      case ShipmentStatus.delivered: color = Colors.green; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: color)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
