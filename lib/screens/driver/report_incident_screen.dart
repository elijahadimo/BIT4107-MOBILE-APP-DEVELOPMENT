import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/incident.dart';
import '../../providers/auth_provider.dart';
import '../../providers/incident_provider.dart';
import 'package:go_router/go_router.dart';

class ReportIncidentScreen extends StatefulWidget {
  final String? tripId;
  final String? shipmentId;

  const ReportIncidentScreen({super.key, this.tripId, this.shipmentId});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _descriptionController = TextEditingController();
  IncidentType _type = IncidentType.delay;
  IncidentSeverity _severity = IncidentSeverity.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Incident')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<IncidentType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Incident Type'),
              items: IncidentType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase()))).toList(),
              onChanged: (val) => setState(() => _type = val!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<IncidentSeverity>(
              initialValue: _severity,
              decoration: const InputDecoration(labelText: 'Severity'),
              items: IncidentSeverity.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()))).toList(),
              onChanged: (val) => setState(() => _severity = val!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(hintText: 'Describe what happened...'),
              maxLines: 5,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.camera_alt),
              label: const Text('Add Photos'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('SUBMIT REPORT'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final incidentProvider = context.read<IncidentProvider>();
    final authProvider = context.read<AuthProvider>();

    final incident = Incident(
      id: const Uuid().v4(),
      incidentNumber: 'INC-${DateTime.now().millisecondsSinceEpoch}',
      type: _type,
      severity: _severity,
      description: _descriptionController.text,
      tripId: widget.tripId,
      shipmentId: widget.shipmentId,
      reportedBy: authProvider.user!.id,
      status: IncidentStatus.reported,
      createdAt: DateTime.now(),
    );

    incidentProvider.reportIncident(incident);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incident reported successfully')));
    context.pop();
  }
}
