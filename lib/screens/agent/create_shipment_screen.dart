import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/shipment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/branch_provider.dart';
import '../../providers/shipment_provider.dart';
import '../../services/pdf_service.dart';
import 'package:go_router/go_router.dart';

class CreateShipmentScreen extends StatefulWidget {
  const CreateShipmentScreen({super.key});

  @override
  State<CreateShipmentScreen> createState() => _CreateShipmentScreenState();
}

class _CreateShipmentScreenState extends State<CreateShipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _senderNameController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _itemDescriptionController = TextEditingController();
  final _weightController = TextEditingController();
  final _costController = TextEditingController();
  final _valueController = TextEditingController();

  String? _destinationBranchId;
  String _currency = 'KES';
  PaymentMethod _paymentMethod = PaymentMethod.prepaid;

  @override
  Widget build(BuildContext context) {
    final branchProvider = context.watch<BranchProvider>();
    final authProvider = context.read<AuthProvider>();
    final originBranch = branchProvider.getBranchById(authProvider.user?.branchId ?? '1');

    return Scaffold(
      appBar: AppBar(title: const Text('New Shipment')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Sender Information'),
              _buildTextField(_senderNameController, 'Sender Name'),
              _buildTextField(_senderPhoneController, 'Sender Phone', keyboardType: TextInputType.phone),
              
              const SizedBox(height: 16),
              _buildSectionTitle('Receiver Information'),
              _buildTextField(_receiverNameController, 'Receiver Name'),
              _buildTextField(_receiverPhoneController, 'Receiver Phone', keyboardType: TextInputType.phone),
              
              const SizedBox(height: 16),
              _buildSectionTitle('Destination'),
              DropdownButtonFormField<String>(
                initialValue: _destinationBranchId,
                decoration: const InputDecoration(hintText: 'Select Destination Branch'),
                items: branchProvider.branches.map((b) => DropdownMenuItem(
                  value: b.id,
                  child: Text(b.name),
                )).toList(),
                onChanged: (val) => setState(() => _destinationBranchId = val),
                validator: (val) => val == null ? 'Required' : null,
              ),

              const SizedBox(height: 16),
              _buildSectionTitle('Item Details'),
              _buildTextField(_itemDescriptionController, 'Item Description'),
              Row(
                children: [
                  Expanded(child: _buildTextField(_weightController, 'Weight (kg)', keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_valueController, 'Goods Value', keyboardType: TextInputType.number)),
                ],
              ),

              const SizedBox(height: 16),
              _buildSectionTitle('Payment'),
              Row(
                children: [
                  Expanded(child: _buildTextField(_costController, 'Shipping Cost', keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _currency,
                      items: ['KES', 'SSP', 'USD'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setState(() => _currency = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<PaymentMethod>(
                initialValue: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: PaymentMethod.values.map((m) => DropdownMenuItem(
                  value: m,
                  child: Text(m.name.toUpperCase()),
                )).toList(),
                onChanged: (val) => setState(() => _paymentMethod = val!),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _submit(context, originBranch?.name ?? 'NAI'),
                  child: const Text('CREATE SHIPMENT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(hintText: label),
        keyboardType: keyboardType,
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }

  void _submit(BuildContext context, String branchName) async {
    if (_formKey.currentState!.validate()) {
      final shipmentProvider = context.read<ShipmentProvider>();
      final authProvider = context.read<AuthProvider>();
      
      final shipment = Shipment(
        id: const Uuid().v4(),
        trackingNumber: shipmentProvider.generateTrackingNumber(branchName),
        senderName: _senderNameController.text,
        senderPhone: _senderPhoneController.text,
        receiverName: _receiverNameController.text,
        receiverPhone: _receiverPhoneController.text,
        itemDescription: _itemDescriptionController.text,
        weight: double.parse(_weightController.text),
        originBranchId: authProvider.user?.branchId ?? '1',
        destinationBranchId: _destinationBranchId!,
        shippingCost: double.parse(_costController.text),
        goodsValue: double.parse(_valueController.text),
        currency: _currency,
        paymentMethod: _paymentMethod,
        status: ShipmentStatus.pending,
        createdBy: authProvider.user!.id,
        createdAt: DateTime.now(),
      );

      await shipmentProvider.createShipment(shipment);
      if (!context.mounted) return;
      
      _showSuccessDialog(context, shipment);
    }
  }

  void _showSuccessDialog(BuildContext context, Shipment shipment) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Shipment Created!'),
        content: Text('Tracking Number: ${shipment.trackingNumber}\n\nWhat would you like to do next?'),
        actions: [
          TextButton(
            onPressed: () async {
              final bytes = await PdfService.generateReceipt(shipment);
              await PdfService.printDoc(bytes);
            },
            child: const Text('PRINT RECEIPT'),
          ),
          TextButton(
            onPressed: () async {
              final bytes = await PdfService.generateReceipt(shipment);
              await PdfService.saveAndShare(bytes, 'Receipt_${shipment.trackingNumber}.pdf');
            },
            child: const Text('SHARE RECEIPT'),
          ),
          TextButton(
            onPressed: () async {
              final bytes = await PdfService.generateWaybill(shipment);
              await PdfService.saveAndShare(bytes, 'Waybill_${shipment.trackingNumber}.pdf');
            },
            child: const Text('SHARE WAYBILL'),
          ),
          TextButton(
            onPressed: () async {
              final bytes = await PdfService.generateQrLabel(shipment);
              await PdfService.printDoc(bytes);
            },
            child: const Text('PRINT QR LABEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
              context.push('/agent/load-truck');
            },
            child: const Text('ASSIGN TO TRIP'),
          ),
          ElevatedButton(
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
