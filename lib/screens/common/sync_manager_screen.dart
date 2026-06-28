import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/storage_service.dart';
import '../../services/sync_service.dart';
import '../../providers/connectivity_provider.dart';
import 'package:intl/intl.dart';

class SyncManagerScreen extends StatefulWidget {
  const SyncManagerScreen({super.key});

  @override
  State<SyncManagerScreen> createState() => _SyncManagerScreenState();
}

class _SyncManagerScreenState extends State<SyncManagerScreen> {
  List<dynamic> _queue = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshQueue();
  }

  void _refreshQueue() {
    setState(() => _isLoading = true);
    final storage = context.read<StorageService>();
    setState(() {
      _queue = storage.getSyncQueue();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityProvider>().isOnline;
    final draftCount = _queue.where((item) => item['status'] == 'draft').length;
    final readyCount = _queue.where((item) => item['status'] == 'ready').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Sync Manager'),
        actions: [
          IconButton(onPressed: _refreshQueue, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _queue.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildSummaryBar(draftCount, readyCount, isOnline),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _queue.length,
                        itemBuilder: (context, index) {
                          final item = _queue[index];
                          return _buildSyncItemCard(item);
                        },
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: _queue.any((item) => item['status'] == 'draft')
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                onPressed: () => _confirmAllForSync(),
                child: const Text('CONFIRM ALL DRAFTS FOR SYNCING'),
              ),
            )
          : null,
    );
  }

  Widget _buildSummaryBar(int drafts, int ready, bool isOnline) {
    return Container(
      color: Colors.white10,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Drafts', drafts.toString(), Colors.orange),
          _statItem('Ready', ready.toString(), Colors.green),
          _statItem('Status', isOnline ? 'ONLINE' : 'OFFLINE', isOnline ? Colors.green : Colors.red),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_done, size: 64, color: Colors.green),
          SizedBox(height: 16),
          Text('All data is synchronized!', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildSyncItemCard(Map<String, dynamic> item) {
    final bool isDraft = item['status'] == 'draft';
    final String type = item['type'].replaceAll('_', ' ').toUpperCase();
    final String time = DateFormat('HH:mm').format(DateTime.parse(item['timestamp']));
    final payload = item['payload'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              isDraft ? Icons.edit_note : Icons.check_circle,
              color: isDraft ? Colors.orange : Colors.green,
            ),
            title: Text(type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('Created at $time • ID: ${item['id']}'),
            trailing: isDraft 
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _editItem(item)),
                    IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: () => _deleteItem(item['id'])),
                  ],
                )
              : const Text('READY', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 10)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildPayloadPreview(payload),
          ),
          if (isDraft)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: () => _confirmItemForSync(item['id']),
                child: const Text('CONFIRM THIS ITEM'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPayloadPreview(Map<String, dynamic> payload) {
    // Show first 2-3 key values as a preview
    String preview = "";
    if (payload.containsKey('tracking_number')) preview += "Tracking: ${payload['tracking_number']}\n";
    if (payload.containsKey('sender_name')) preview += "Sender: ${payload['sender_name']}\n";
    if (payload.containsKey('item_description')) preview += "Item: ${payload['item_description']}";
    
    return Text(
      preview.isEmpty ? payload.toString() : preview,
      style: const TextStyle(fontSize: 12, color: Colors.black54),
    );
  }

  void _confirmItemForSync(String id) async {
    await context.read<StorageService>().markItemAsReady(id);
    _refreshQueue();
    // Try to trigger actual sync if online
    // SyncService(storageService: ..., connectivityProvider: ...).syncReadyQueue();
  }

  void _confirmAllAllForSync() async {
    await context.read<StorageService>().markAllAsReady();
    _refreshQueue();
  }

  void _confirmAllForSync() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm for Syncing?'),
        content: const Text('This will mark all draft items as "Ready". They will be uploaded to the server as soon as you have internet connection.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              _confirmAllAllForSync();
              Navigator.pop(ctx);
            }, 
            child: const Text('CONFIRM ALL')
          ),
        ],
      ),
    );
  }

  void _deleteItem(String id) async {
    await context.read<StorageService>().removeFromSyncQueue(id);
    _refreshQueue();
  }

  void _editItem(Map<String, dynamic> item) {
    // For simplicity, we can show a JSON editor or specific forms based on type
    // In a real app, you'd route back to the original form with the data pre-filled
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit functionality would open the original form here.'))
    );
  }
}
