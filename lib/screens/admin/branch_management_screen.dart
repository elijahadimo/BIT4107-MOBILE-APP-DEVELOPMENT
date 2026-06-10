import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/branch_provider.dart';
import '../../models/branch.dart';

class BranchManagementScreen extends StatelessWidget {
  const BranchManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final branchProvider = context.watch<BranchProvider>();
    final branches = branchProvider.branches;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Branch Management'),
        actions: [
          IconButton(
            onPressed: () => _showBranchDialog(context),
            icon: const Icon(Icons.add_location),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: branches.length,
        itemBuilder: (context, index) {
          final branch = branches[index];
          return Card(
            child: ListTile(
              title: Text(branch.name),
              subtitle: Text('${branch.location}, ${branch.country}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showBranchDialog(context, branch: branch),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => branchProvider.deleteBranch(branch.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showBranchDialog(BuildContext context, {Branch? branch}) {
    final nameController = TextEditingController(text: branch?.name);
    final locationController = TextEditingController(text: branch?.location);
    final countryController = TextEditingController(text: branch?.country);
    BranchType selectedType = branch?.type ?? BranchType.local;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(branch == null ? 'Add Branch' : 'Edit Branch'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
                TextField(controller: countryController, decoration: const InputDecoration(labelText: 'Country')),
                DropdownButtonFormField<BranchType>(
                  value: selectedType,
                  items: BranchType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
                  onChanged: (val) => setState(() => selectedType = val!),
                  decoration: const InputDecoration(labelText: 'Type'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                final newBranch = Branch(
                  id: branch?.id ?? const Uuid().v4(),
                  name: nameController.text,
                  location: locationController.text,
                  country: countryController.text,
                  type: selectedType,
                  latitude: branch?.latitude ?? 0.0,
                  longitude: branch?.longitude ?? 0.0,
                  hasAgent: branch?.hasAgent ?? true,
                );
                if (branch == null) {
                  context.read<BranchProvider>().addBranch(newBranch);
                } else {
                  context.read<BranchProvider>().updateBranch(newBranch);
                }
                Navigator.pop(ctx);
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }
}
