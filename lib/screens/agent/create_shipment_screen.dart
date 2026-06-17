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
  final _itemDescController = TextEditingController();
  final _qtyTypeController = TextEditingController(text: 'Sacks');
  final _qtyController = TextEditingController(text: '1');
  final _unitWeightController = TextEditingController(text: '0');
  final _unitValueController = TextEditingController(text: '0');
  final _costController = TextEditingController();

  String? _destinationBranchId;
  String _currency = 'KES';
  PaymentMethod _paymentMethod = PaymentMethod.prepaid;

  double _totalWeight = 0;
  double _totalValue = 0;

  @override
  void initState() {
    super.initState();
    _qtyController.addListener(_calculateTotals);
    _unitWeightController.addListener(_calculateTotals);
    _unitValueController.addListener(_calculateTotals);
  }

  void _calculateTotals() {
    final qty = double.tryParse(_qtyController.text) ?? 0;
    final w = double.tryParse(_unitWeightController.text) ?? 0;
    final v = double.tryParse(_unitValueController.text) ?? 0;
    setState(() {
      _totalWeight = qty * w;
      _totalValue = qty * v;
    });
  }

  @override
  Widget build(BuildContext context) {
    final branchProvider = context.watch<BranchProvider>();
    final authProvider = context.read<AuthProvider>();
    final originBranch = branchProvider.getBranchById(authProvider.user?.branchId ?? '1');

    return Scaffold(
      appBar: AppBar(title: const Text('New Smart Shipment')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('SENDER & RECEIVER'),
              Row(
                children: [
                  Expanded(child: _buildTextField(_senderNameController, 'Sender Name')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTextField(_receiverNameController, 'Receiver Name')),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildTextField(_senderPhoneController, 'Sender Phone', keyboardType: TextInputType.phone)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTextField(_receiverPhoneController, 'Receiver Phone', keyboardType: TextInputType.phone)),
                ],
              ),
              
              const SizedBox(height: 16),
              _buildSectionTitle('DESTINATION'),
              DropdownButtonFormField<String>(
                value: _destinationBranchId,
                decoration: const InputDecoration(hintText: 'Select Destination Branch'),
                items: branchProvider.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                onChanged: (val) => setState(() => _destinationBranchId = val),
                validator: (val) => val == null ? 'Required' : null,
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('GOODS & QUANTITY'),
              _buildTextField(_itemDescController, 'Item Description (e.g. Cement)'),
              Row(
                children: [
                  Expanded(flex: 2, child: _buildTextField(_qtyTypeController, 'Qty Type (Sacks, Boxes)')),
                  const SizedBox(width: 8),
                  Expanded(flex: 1, child: _buildTextField(_qtyController, 'Total Qty', keyboardType: TextInputType.number)),
                ],
              ),
              Row(
                children: [
                  Expanded(child: _buildTextField(_unitWeightController, 'Weight per Unit (Kg)', keyboardType: TextInputType.number)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildTextField(_unitValueController, 'Value per Unit', keyboardType: TextInputType.number)),
                ],
              ),

              // Summary Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    _buildSummaryLine('Calculated Total Weight:', '$_totalWeight Kg'),
                    _buildSummaryLine('Calculated Total Value:', '$_totalValue $_currency'),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _buildSectionTitle('PAYMENT & FEES'),
              Row(
                children: [
                  Expanded(child: _buildTextField(_costController, 'Shipping Fee', keyboardType: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _currency,
                      items: ['KES', 'SSP', 'USD'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) => setState(() => _currency = val!),
                    ),
                  ),
                ],
              ),
              DropdownButtonFormField<PaymentMethod>(
                value: _paymentMethod,
                decoration: const InputDecoration(labelText: 'Payment Method'),
                items: PaymentMethod.values.map((m) => DropdownMenuItem(value: m, child: Text(m.name.toUpperCase()))).toList(),
                onChanged: (val) => setState(() => _paymentMethod = val!),
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
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

  Widget _buildSummaryLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.orange)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
        keyboardType: keyboardType,
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }

  void _submit(BuildContext context, String branchName) async {
    if (_formKey.currentState!.validate()) {
      final shipmentProvider = context.read<ShipmentProvider>();
      final authProvider = context.read<AuthProvider>();
      
      final detailedDesc = "${_itemDescController.text} (${_qtyController.text} ${_qtyTypeController.text})";

      final shipment = Shipment(
        id: const Uuid().v4(),
        trackingNumber: shipmentProvider.generateTrackingNumber(branchName),
        senderName: _senderNameController.text,
        senderPhone: _senderPhoneController.text,
        receiverName: _receiverNameController.text,
        receiverPhone: _receiverPhoneController.text,
        itemDescription: detailedDesc,
        weight: _totalWeight,
        originBranchId: authProvider.user?.branchId ?? '1',
        destinationBranchId: _destinationBranchId!,
        shippingCost: double.parse(_costController.text),
        goodsValue: _totalValue,
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
        content: Text('Tracking Number: ${shipment.trackingNumber}\n\nWeight: ${shipment.weight} Kg'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('DONE')),
        ],
      ),
    );
  }
}
