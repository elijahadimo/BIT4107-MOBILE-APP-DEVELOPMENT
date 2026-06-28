import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/user_provider.dart';
import '../../providers/branch_provider.dart';
import '../../models/user.dart';
import 'dart:math';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final users = userProvider.allUsers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            onPressed: () => _showAddUserDialog(context),
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
      body: users.isEmpty
          ? const Center(child: Text('No users found', style: TextStyle(color: Colors.white)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _buildUserTile(context, user);
              },
            ),
    );
  }

  Widget _buildUserTile(BuildContext context, User user) {
    final branch = user.branchId != null 
        ? context.read<BranchProvider>().getBranchById(user.branchId!) 
        : null;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isActive ? Colors.blue : Colors.grey,
          child: Text(user.name[0].toUpperCase()),
        ),
        title: Text(user.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${user.role.name.toUpperCase()} | ${user.phone}'),
            if (branch != null) 
              Text('Branch: ${branch.name}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            if (user.mustChangePassword)
              const Text('⚠️ Pending Password Change', style: TextStyle(color: Colors.orange, fontSize: 10)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showAddUserDialog(context, user: user),
            ),
            Switch(
              value: user.isActive,
              onChanged: (val) {
                context.read<UserProvider>().toggleUserStatus(user.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, {User? user}) {
    final nameController = TextEditingController(text: user?.name);
    final phoneController = TextEditingController(text: user?.phone);
    UserRole selectedRole = user?.role ?? UserRole.agent;
    String? selectedBranchId = user?.branchId;
    String tempPassword = _generateRandomPassword();
    
    final branches = context.read<BranchProvider>().branches;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(user == null ? 'Onboard New Staff' : 'Edit Staff Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number (Username)'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  value: selectedRole,
                  items: UserRole.values.where((r) => r != UserRole.customer).map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role.name.toUpperCase()),
                  )).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedRole = val!;
                      if (selectedRole != UserRole.agent) {
                        selectedBranchId = null;
                      }
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Assign Role'),
                ),
                if (selectedRole == UserRole.agent) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedBranchId,
                    hint: const Text('Select Branch'),
                    items: branches.map((branch) => DropdownMenuItem(
                      value: branch.id,
                      child: Text(branch.name),
                    )).toList(),
                    onChanged: (val) => setState(() => selectedBranchId = val),
                    decoration: const InputDecoration(labelText: 'Work Branch'),
                  ),
                ],
                if (user == null) ...[
                  const SizedBox(height: 24),
                  const Text('Generated Login Credentials:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Username: ${phoneController.text.isEmpty ? "[Enter Phone]" : phoneController.text}', style: const TextStyle(fontSize: 12)),
                        Text('Password: $tempPassword', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),
                  const Text('Give these to the staff. They will be forced to change password on first login.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  final newUser = User(
                    id: user?.id ?? const Uuid().v4(),
                    name: nameController.text,
                    phone: phoneController.text,
                    role: selectedRole,
                    branchId: selectedBranchId,
                    isActive: user?.isActive ?? true,
                    mustChangePassword: user == null, // True only for new users
                  );
                  
                  if (user == null) {
                    context.read<UserProvider>().addUser(newUser);
                    // In a real app, you'd send an SMS here with the credentials
                  } else {
                    context.read<UserProvider>().updateUser(newUser);
                  }
                  Navigator.pop(ctx);
                }
              },
              child: Text(user == null ? 'ONBOARD STAFF' : 'SAVE CHANGES'),
            ),
          ],
        ),
      ),
    );
  }

  String _generateRandomPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join().toUpperCase();
  }
}
