import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/shipment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/branch_provider.dart';
import '../../providers/shipment_provider.dart';
import 'package:go_router/go_router.dart';

enum BulkMode { oneToMany, manyToOne, oneToOne }

class BulkShipmentScreen extends StatefulWidget {
  const BulkShipmentScreen({super.key});

  @override
  State<BulkShipmentScreen> createState() => _BulkShipmentScreenState();
}

class _BulkShipmentScreenState extends State<BulkShipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  BulkMode _mode = BulkMode.oneToMany;
  
  final _senderNameController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  
  final List<BulkItem> _items = [];

  String? _commonDestinationBranchId;
  String _currency = 'KES';

  @override
  void initState() {
    super.initState();
    _items.add(BulkItem(onChanged: () => setState(() {})));
  }

  @override
  Widget build(BuildContext context) {
    final branchProvider = context.watch<BranchProvider>();
    final authProvider = context.read<AuthProvider>();
    final originBranch = branchProvider.getBranchById(authProvider.user?.branchId ?? '1');

    return Scaffold(
      appBar: AppBar(title: const Text('Advanced Bulk Logistics')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModeSelector(),
              const SizedBox(height: 16),
              
              // Common Section
              Card(
                color: Colors.white.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_mode == BulkMode.oneToMany || _mode == BulkMode.oneToOne) ...[
                        _buildSectionTitle('Common Sender'),
                        _buildTextField(_senderNameController, 'Sender Name'),
                        _buildTextField(_senderPhoneController, 'Sender Phone', keyboardType: TextInputType.phone),
                        const SizedBox(height: 16),
                      ],
                      if (_mode == BulkMode.manyToOne || _mode == BulkMode.oneToOne) ...[
                        _buildSectionTitle('Common Receiver'),
                        _buildTextField(_receiverNameController, 'Receiver Name'),
                        _buildTextField(_receiverPhoneController, 'Receiver Phone', keyboardType: TextInputType.phone),
                        const SizedBox(height: 16),
                        const Text('Destination Branch', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        DropdownButtonFormField<String>(
                          value: _commonDestinationBranchId,
                          decoration: const InputDecoration(hintText: 'Select Branch'),
                          items: branchProvider.branches.map((b) => DropdownMenuItem(
                            value: b.id,
                            child: Text(b.name),
                          )).toList(),
                          onChanged: (val) => setState(() => _commonDestinationBranchId = val),
                          validator: (val) => val == null ? 'Required' : null,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Itemized Goods List'),
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _items.add(BulkItem(onChanged: () => setState(() {})))),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('ADD ITEM'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white24),
                  ),
                ],
              ),
              
              ..._items.asMap().entries.map((entry) => _buildBulkItemCard(entry.key, entry.value, branchProvider)),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => _submit(context, originBranch?.name ?? 'NAI'),
                  child: Text('PROCESS ${_items.length} LOGISTICS ENTRIES'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _modeButton('1-to-N', BulkMode.oneToMany),
          const SizedBox(width: 4),
          _modeButton('N-to-1', BulkMode.manyToOne),
          const SizedBox(width: 4),
          _modeButton('Multi-Item 1-to-1', BulkMode.oneToOne),
        ],
      ),
    );
  }

  Widget _modeButton(String label, BulkMode mode) {
    bool isSelected = _mode == mode;
    return ChoiceChip(
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70)),
      selected: isSelected,
      onSelected: (val) => setState(() => _mode = mode),
      selectedColor: Colors.orange,
      backgroundColor: Colors.white10,
    );
  }

  Widget _buildBulkItemCard(int index, BulkItem item, BranchProvider branchProvider) {
    return Card(
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(backgroundColor: Colors.orange, radius: 12, child: Text('${index + 1}', style: const TextStyle(fontSize: 10, color: Colors.white))),
                const SizedBox(width: 8),
                Text(_getItemCardTitle(), style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (_items.length > 1)
                  IconButton(
                    onPressed: () => setState(() => _items.removeAt(index)),
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  ),
              ],
            ),
            const Divider(),
            
            if (_mode == BulkMode.oneToMany) ...[
              _buildTextField(item.nameController, 'Receiver Name'),
              _buildTextField(item.phoneController, 'Receiver Phone', keyboardType: TextInputType.phone),
              const Text('Destination Branch', style: TextStyle(color: Colors.grey, fontSize: 10)),
              DropdownButtonFormField<String>(
                value: item.destinationBranchId,
                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                items: branchProvider.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                onChanged: (val) => setState(() => item.destinationBranchId = val),
                validator: (val) => val == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
            ] else if (_mode == BulkMode.manyToOne) ...[
              _buildTextField(item.nameController, 'Sender Name'),
              _buildTextField(item.phoneController, 'Sender Phone', keyboardType: TextInputType.phone),
            ],

            _buildTextField(item.descController, 'Item Description (e.g. Sacks of Maize)'),
            
            Row(
              children: [
                Expanded(flex: 2, child: _buildTextField(item.qtyTypeController, 'Qty Type (Box, Kg)')),
                const SizedBox(width: 8),
                Expanded(flex: 1, child: _buildTextField(item.qtyController, 'Total Qty', keyboardType: TextInputType.number)),
              ],
            ),

            Row(
              children: [
                Expanded(child: _buildTextField(item.unitWeightController, 'Weight/Unit', keyboardType: TextInputType.number)),
                const SizedBox(width: 8),
                Expanded(child: _buildTextField(item.unitValueController, 'Value/Unit', keyboardType: TextInputType.number)),
              ],
            ),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  _buildSummaryRow('Total Weight:', '${item.totalWeight.toStringAsFixed(2)} Kg'),
                  _buildSummaryRow('Total Goods Value:', '${item.totalValue.toStringAsFixed(2)} $_currency'),
                  const Divider(),
                  Row(
                    children: [
                      const Text('Shipping Fee:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: item.costController,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                          decoration: const InputDecoration(hintText: '0.00', isDense: true, border: InputBorder.none),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(_currency, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getItemCardTitle() {
    switch (_mode) {
      case BulkMode.oneToMany: return 'Receiver Detail';
      case BulkMode.manyToOne: return 'Sender Detail';
      case BulkMode.oneToOne: return 'Goods Detail';
    }
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        keyboardType: keyboardType,
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      ),
    );
  }

  void _submit(BuildContext context, String branchName) async {
    if (_formKey.currentState!.validate()) {
      final shipmentProvider = context.read<ShipmentProvider>();
      final authProvider = context.read<AuthProvider>();
      
      for (var item in _items) {
        final detailedDesc = "${item.descController.text} (${item.qtyController.text} ${item.qtyTypeController.text})";

        final shipment = Shipment(
          id: const Uuid().v4(),
          trackingNumber: shipmentProvider.generateTrackingNumber(branchName),
          senderName: _mode == BulkMode.manyToOne ? item.nameController.text : _senderNameController.text,
          senderPhone: _mode == BulkMode.manyToOne ? item.phoneController.text : _senderPhoneController.text,
          receiverName: _mode == BulkMode.oneToMany ? item.nameController.text : _receiverNameController.text,
          receiverPhone: _mode == BulkMode.oneToMany ? item.phoneController.text : _receiverPhoneController.text,
          itemDescription: detailedDesc,
          weight: item.totalWeight,
          originBranchId: authProvider.user?.branchId ?? '1',
          destinationBranchId: _mode == BulkMode.oneToMany ? item.destinationBranchId! : _commonDestinationBranchId!,
          shippingCost: double.tryParse(item.costController.text) ?? 0.0,
          goodsValue: item.totalValue,
          currency: _currency,
          paymentMethod: PaymentMethod.prepaid,
          status: ShipmentStatus.pending,
          createdBy: authProvider.user!.id,
          createdAt: DateTime.now(),
        );
        await shipmentProvider.createShipment(shipment);
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bulk Processing Complete: ${_items.length} items logged.')),
      );
      context.pop();
    }
  }
}

class BulkItem {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final descController = TextEditingController();
  final qtyTypeController = TextEditingController();
  final qtyController = TextEditingController();
  final unitWeightController = TextEditingController();
  final unitValueController = TextEditingController();
  final costController = TextEditingController();
  String? destinationBranchId;

  BulkItem({required VoidCallback onChanged}) {
    qtyController.addListener(onChanged);
    unitWeightController.addListener(onChanged);
    unitValueController.addListener(onChanged);
  }

  double get totalWeight {
    final qty = double.tryParse(qtyController.text) ?? 0.0;
    final unitW = double.tryParse(unitWeightController.text) ?? 0.0;
    return qty * unitW;
  }

  double get totalValue {
    final qty = double.tryParse(qtyController.text) ?? 0.0;
    final unitV = double.tryParse(unitValueController.text) ?? 0.0;
    return qty * unitV;
  }
}
