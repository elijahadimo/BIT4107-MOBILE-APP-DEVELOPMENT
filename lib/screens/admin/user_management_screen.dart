import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/user_provider.dart';
import '../../models/user.dart';

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
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isActive ? Colors.blue : Colors.grey,
          child: Text(user.name[0].toUpperCase()),
        ),
        title: Text(user.name),
        subtitle: Text('${user.role.name.toUpperCase()} | ${user.phone}'),
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
        onLongPress: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Delete User?'),
              content: Text('Are you sure you want to delete ${user.name}?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
                TextButton(
                  onPressed: () {
                    context.read<UserProvider>().deleteUser(user.id);
                    Navigator.pop(ctx);
                  },
                  child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, {User? user}) {
    final nameController = TextEditingController(text: user?.name);
    final phoneController = TextEditingController(text: user?.phone);
    UserRole selectedRole = user?.role ?? UserRole.agent;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(user == null ? 'Add New User' : 'Edit User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  value: selectedRole,
                  items: UserRole.values.map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role.name.toUpperCase()),
                  )).toList(),
                  onChanged: (val) => setState(() => selectedRole = val!),
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  final updatedUser = User(
                    id: user?.id ?? const Uuid().v4(),
                    name: nameController.text,
                    phone: phoneController.text,
                    role: selectedRole,
                    isActive: user?.isActive ?? true,
                  );
                  
                  if (user == null) {
                    context.read<UserProvider>().addUser(updatedUser);
                  } else {
                    context.read<UserProvider>().updateUser(updatedUser);
                  }
                  Navigator.pop(ctx);
                }
              },
              child: Text(user == null ? 'ADD' : 'SAVE'),
            ),
          ],
        ),
      ),
    );
  }
}
