import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shipment_provider.dart';
import '../../providers/trip_provider.dart';
import '../../providers/branch_provider.dart';
import '../../services/pdf_service.dart';
import '../../models/user.dart';
import 'dart:typed_data';

class ReportGeneratorWidget extends StatefulWidget {
  final UserRole? initialRole; // If null, allow selector
  final String? userId; 

  const ReportGeneratorWidget({super.key, this.initialRole, this.userId});

  @override
  State<ReportGeneratorWidget> createState() => _ReportGeneratorWidgetState();
}

class _ReportGeneratorWidgetState extends State<ReportGeneratorWidget> {
  DateTimeRange? _selectedRange;
  bool _isGenerating = false;
  UserRole? _selectedRole;
  String? _selectedBranchId;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final branchProvider = context.watch<BranchProvider>();
    final isAdmin = auth.user?.role == UserRole.admin;

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assessment, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Activity Report Generator',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black, fontSize: 18),
                ),
              ],
            ),
            const Divider(height: 24),
            
            if (isAdmin && widget.initialRole == null) ...[
              const Text('Select Report Type:', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: UserRole.values.map((role) => DropdownMenuItem(
                  value: role,
                  child: Text(role.name.toUpperCase()),
                )).toList(),
                onChanged: (val) => setState(() => _selectedRole = val),
              ),
              const SizedBox(height: 16),
            ],

            if (_selectedRole == UserRole.agent || _selectedRole == UserRole.admin) ...[
              const Text('Filter by Branch (Optional for Admin):', style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedBranchId,
                hint: const Text('All Branches'),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: [
                  const DropdownMenuItem<String>(value: null, child: Text('All Branches')),
                  ...branchProvider.branches.map((b) => DropdownMenuItem(
                    value: b.id,
                    child: Text(b.name),
                  )),
                ],
                onChanged: isAdmin ? (val) => setState(() => _selectedBranchId = val) : null,
              ),
              const SizedBox(height: 16),
            ],

            const Text('Select Date Range:', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDateRange,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range, size: 20, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      _selectedRange == null
                          ? 'Tap to select dates'
                          : '${DateFormat('yMMMd').format(_selectedRange!.start)} - ${DateFormat('yMMMd').format(_selectedRange!.end)}',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _selectedRange == null || _isGenerating || _selectedRole == null ? null : _generateReport,
                icon: _isGenerating 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.picture_as_pdf),
                label: Text(_isGenerating ? 'GENERATING...' : 'GENERATE PDF REPORT'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _selectedRange,
    );
    if (picked != null) {
      setState(() => _selectedRange = picked);
    }
  }

  Future<void> _generateReport() async {
    setState(() => _isGenerating = true);
    try {
      final auth = context.read<AuthProvider>();
      final branchProvider = context.read<BranchProvider>();
      final currentUser = auth.user!;
      
      // Determine target branch
      String? branchId = _selectedBranchId;
      if (currentUser.role == UserRole.agent) {
        branchId = currentUser.branchId;
      }
      
      String? branchName;
      if (branchId != null) {
        branchName = branchProvider.getBranchById(branchId)?.name;
      }

      final targetUserId = widget.userId ?? currentUser.id;
      final targetUserName = widget.userId != null ? "User ID: ${widget.userId}" : currentUser.name;

      final title = "Report: ${DateFormat('yMMMd').format(_selectedRange!.start)} to ${DateFormat('yMMMd').format(_selectedRange!.end)}";
      
      late Uint8List pdfBytes;

      if (_selectedRole == UserRole.agent || _selectedRole == UserRole.admin || _selectedRole == UserRole.customer) {
        final shipments = context.read<ShipmentProvider>().getShipmentsByDateRange(
          _selectedRange!.start, 
          _selectedRange!.end,
          branchId: branchId,
        );
        pdfBytes = await PdfService.generateSummaryReport(shipments, title, branchName: branchName);
      } else if (_selectedRole == UserRole.driver || _selectedRole == UserRole.asstDriver) {
        final trips = context.read<TripProvider>().getTripsByDateRange(
          _selectedRange!.start, 
          _selectedRange!.end,
          driverId: _selectedRole == UserRole.driver ? targetUserId : null
        );
        pdfBytes = await PdfService.generateDriverReport(trips, targetUserName, title);
      } else {
        throw Exception("Reporting for this role not implemented yet");
      }

      await PdfService.saveAndShare(
        pdfBytes, 
        'Activity_Report_${_selectedRole!.name}_${DateTime.now().millisecondsSinceEpoch}.pdf'
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report generated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report: $e')),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }
}
