import 'package:flutter/material.dart';
import '../routes.dart';

class ProviderDashboardScreen extends StatelessWidget {
  const ProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Hub'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Roster & bookings'),
              subtitle: const Text('Manage your day and accept bookings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, Routes.roster),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Invoices & compliance'),
              subtitle: const Text('Quick NDIA submissions and status'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.people_outline),
              title: const Text('Support circle'),
              subtitle: const Text('Collaborate with participants and teams'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.green.withOpacity(0.08),
            child: const ListTile(
              leading: Icon(Icons.verified_user, color: Colors.green),
              title: Text('Compliance'),
              subtitle: Text('Your compliance bar is at 88%'),
            ),
          ),
        ],
      ),
    );
  }
}
