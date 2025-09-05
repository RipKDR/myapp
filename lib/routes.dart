import 'package:flutter/material.dart';

import 'screens/participant_dashboard.dart';
import 'screens/provider_dashboard.dart';
import 'screens/calendar_screen.dart';
import 'screens/budget_screen.dart';
import 'controllers/auth_controller.dart';
import 'screens/chat_screen.dart';
import 'screens/service_map_screen.dart';
import 'screens/checklist_screen.dart';
import 'screens/snapshot_screen.dart';
import 'screens/support_circle_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/provider_roster_screen.dart';

class Routes {
  static const bootstrap = '/';
  static const participantDashboard = '/participant';
  static const providerDashboard = '/provider';
  static const calendar = '/calendar';
  static const budget = '/budget';
  static const chat = '/chat';
  static const map = '/map';
  static const checklist = '/checklist';
  static const snapshot = '/snapshot';
  static const circle = '/circle';
  static const auth = '/auth';
  static const roster = '/roster';

  static Map<String, WidgetBuilder> get routes => {
        bootstrap: (context) => const _BootstrapScreen(),
        participantDashboard: (context) => const ParticipantDashboardScreen(),
        providerDashboard: (context) => const ProviderDashboardScreen(),
        calendar: (context) => const CalendarScreen(),
        budget: (context) => const BudgetScreen(),
        chat: (context) => const ChatScreen(),
        map: (context) => const ServiceMapScreen(),
        checklist: (context) => const ChecklistScreen(),
        snapshot: (context) => const SnapshotScreen(),
        circle: (context) => const SupportCircleScreen(),
        auth: (context) => const AuthScreen(),
        roster: (context) => const ProviderRosterScreen(),
      };
}

class _BootstrapScreen extends StatelessWidget {
  const _BootstrapScreen();

  @override
  Widget build(BuildContext context) {
    // Decide where to go based on role selection.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = AuthController.of(context);
      final role = auth.role;
      if (!auth.signedIn) {
        Navigator.of(context).pushReplacementNamed(Routes.auth);
      } else if (role == UserRole.provider) {
        Navigator.of(context).pushReplacementNamed(Routes.providerDashboard);
      } else if (role == UserRole.participant) {
        Navigator.of(context).pushReplacementNamed(Routes.participantDashboard);
      } else {
        // No role yet: prompt selection via dialog for now.
        _showRolePicker(context);
      }
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }

  void _showRolePicker(BuildContext context) async {
    final auth = AuthController.of(context);
    final choice = await showDialog<UserRole>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Choose your role'),
        content: const Text('Select how you want to use NDIS Connect.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, UserRole.participant),
            child: const Text('Participant'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, UserRole.provider),
            child: const Text('Provider'),
          ),
        ],
      ),
    );
    if (choice != null) {
      await auth.setRole(choice);
      if (!context.mounted) return;
      if (choice == UserRole.provider) {
        Navigator.of(context).pushReplacementNamed(Routes.providerDashboard);
      } else {
        Navigator.of(context).pushReplacementNamed(Routes.participantDashboard);
      }
    }
  }
}
