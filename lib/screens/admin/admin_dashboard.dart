import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

import 'package:go_router/go_router.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _buildCard(context, Icons.people, 'Users', () => context.push('/admin/users')),
          _buildCard(context, Icons.business, 'Branches', () => context.push('/admin/branches')),
          _buildCard(context, Icons.warning, 'Incidents', () => context.push('/admin/incidents')),
          _buildCard(context, Icons.edit, 'CMS', () => context.push('/admin/cms')),
          _buildCard(context, Icons.chat, 'Chat', () => context.push('/chat')),
          _buildCard(context, Icons.attach_money, 'Financial', () => context.push('/admin/financial')),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
