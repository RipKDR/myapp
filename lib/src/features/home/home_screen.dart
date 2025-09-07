
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ndis_connect/src/core/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NDIS Connect'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.auto_mode),
            onPressed: () => themeProvider.setSystemTheme(),
            tooltip: 'Set System Theme',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome to NDIS Connect!', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 20),
            Text('Your accessible NDIS companion.', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: () {}, child: const Text('Get Started')),
          ],
        ),
      ),
    );
  }
}
