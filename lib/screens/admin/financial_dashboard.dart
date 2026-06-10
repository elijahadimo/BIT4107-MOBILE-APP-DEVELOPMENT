import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FinancialDashboard extends StatelessWidget {
  const FinancialDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics & Reports')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatCard('Total Shipments', '1,432', Colors.blue),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('Active Trips', '12', Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Resolved Incidents', '85%', Colors.green)),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatCard('Total Revenue (KES)', '1,250,000', Colors.green),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard('USD', '\$5,400', Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('SSP', '450,000', Colors.orange)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Revenue Trends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 3),
                        const FlSpot(1, 1),
                        const FlSpot(2, 4),
                        const FlSpot(3, 2),
                        const FlSpot(4, 5),
                      ],
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: true, color: Colors.orange.withValues(alpha: 0.2)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Recent System Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            _buildActivityLog('Agent "Nairobi" created new shipment KL-NAI-001'),
            _buildActivityLog('Driver "John" started trip TRP-2024-005'),
            _buildActivityLog('Admin updated branch "Kapoeta" contact info'),
            _buildActivityLog('Incident INC-992 resolved by Admin'),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityLog(String message) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.history, size: 20),
        title: Text(message, style: const TextStyle(fontSize: 13)),
        trailing: Text('${DateTime.now().hour}:${DateTime.now().minute}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
