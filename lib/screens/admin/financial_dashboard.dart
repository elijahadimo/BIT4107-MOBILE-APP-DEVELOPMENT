import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shipment_provider.dart';
import '../../services/pdf_service.dart';
import '../common/report_generator_widget.dart';
import 'package:intl/intl.dart';

class FinancialDashboard extends StatefulWidget {
  const FinancialDashboard({super.key});

  @override
  State<FinancialDashboard> createState() => _FinancialDashboardState();
}

class _FinancialDashboardState extends State<FinancialDashboard> {
  DateTimeRange? _selectedRange;

  @override
  Widget build(BuildContext context) {
    final shipmentProvider = context.watch<ShipmentProvider>();
    final allShipments = shipmentProvider.shipments;

    // Filter shipments if range is selected
    final filteredShipments = _selectedRange == null
        ? allShipments
        : shipmentProvider.getShipmentsByDateRange(_selectedRange!.start, _selectedRange!.end);

    final totalRevenue = filteredShipments.fold(0.0, (sum, s) => sum + s.shippingCost);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: filteredShipments.isEmpty ? null : () => _generateReport(filteredShipments),
            tooltip: 'Download Report',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(filteredShipments.length, totalRevenue),
                  const SizedBox(height: 24),
                  const ReportGeneratorWidget(),
                  const SizedBox(height: 24),
                  const Text('Shipment History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  if (filteredShipments.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No data for selected period', style: TextStyle(color: Colors.white70)),
                    ))
                  else
                    ...filteredShipments.reversed.map((s) => Card(
                      child: ListTile(
                        title: Text(s.trackingNumber),
                        subtitle: Text('From: ${s.originBranchId} | To: ${s.destinationBranchId}'),
                        trailing: Text('${s.shippingCost} ${s.currency}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        leading: Text(DateFormat('MM/dd').format(s.createdAt)),
                      ),
                    )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _selectedRange == null 
              ? 'Showing All Data' 
              : '${DateFormat('yMMMd').format(_selectedRange!.start)} - ${DateFormat('yMMMd').format(_selectedRange!.end)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range, size: 16),
            label: const Text('Filter'),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12)),
          ),
          if (_selectedRange != null)
            IconButton(
              onPressed: () => setState(() => _selectedRange = null),
              icon: const Icon(Icons.clear, color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(int count, double revenue) {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Transactions', count.toString(), Colors.blue)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Revenue', '${revenue.toStringAsFixed(0)} KES', Colors.green)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedRange,
    );
    if (picked != null) {
      setState(() => _selectedRange = picked);
    }
  }

  Future<void> _generateReport(List<dynamic> data) async {
    final title = _selectedRange == null 
      ? "Full History Report" 
      : "Report: ${DateFormat('yMMMd').format(_selectedRange!.start)} to ${DateFormat('yMMMd').format(_selectedRange!.end)}";
    
    final pdfBytes = await PdfService.generateSummaryReport(data.cast(), title);
    await PdfService.saveAndShare(pdfBytes, 'Financial_Report_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }
}
