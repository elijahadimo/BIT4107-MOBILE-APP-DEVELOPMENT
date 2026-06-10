import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/incident_provider.dart';
import '../../models/incident.dart';

class ComplaintManagementScreen extends StatelessWidget {
  const ComplaintManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final incidentProvider = context.watch<IncidentProvider>();
    final incidents = incidentProvider.incidents;

    return Scaffold(
      appBar: AppBar(title: const Text('Complaints & Incidents')),
      body: incidents.isEmpty
          ? const Center(child: Text('No incidents reported', style: TextStyle(color: Colors.white)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: incidents.length,
              itemBuilder: (context, index) {
                final incident = incidents[index];
                return Card(
                  child: ExpansionTile(
                    title: Text('${incident.type.name.toUpperCase()} - ${incident.incidentNumber}'),
                    subtitle: Text('Status: ${incident.status.name}'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Description: ${incident.description}'),
                            const SizedBox(height: 8),
                            if (incident.adminReply != null)
                              Text('Reply: ${incident.adminReply}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                            const SizedBox(height: 16),
                            if (incident.status != IncidentStatus.resolved)
                              ElevatedButton(
                                onPressed: () => _showReplyDialog(context, incident.id),
                                child: const Text('REPLY & RESOLVE'),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showReplyDialog(BuildContext context, String id) {
    final replyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Resolve Incident'),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(hintText: 'Enter your reply...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              context.read<IncidentProvider>().resolveIncident(id, replyController.text);
              Navigator.pop(ctx);
            },
            child: const Text('SUBMIT'),
          ),
        ],
      ),
    );
  }
}
