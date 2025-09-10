import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../features/onboarding/screens/splash_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/onboarding/screens/link_portal_screen.dart';
import '../features/dashboard/screens/participant_dashboard_screen.dart';
import '../features/dashboard/screens/provider_dashboard_screen.dart';
import '../features/budget/screens/budgets_screen.dart';
import '../features/claims/screens/claims_screen.dart';
import '../features/services/screens/services_map_screen.dart';
import '../features/messages/screens/messages_screen.dart';
import '../features/support/screens/support_circle_screen.dart';
import '../features/calendar/screens/calendar_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/dev/screens/dev_panel_screen.dart';

/// App Router Configuration
/// Uses go_router for modern navigation with deep linking support
class AppRouter {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String linkPortal = '/link';
  static const String participantDashboard = '/dashboard';
  static const String providerDashboard = '/provider';
  static const String budgets = '/budgets';
  static const String claims = '/claims';
  static const String services = '/services';
  static const String messages = '/messages';
  static const String support = '/support';
  static const String calendar = '/calendar';
  static const String settings = '/settings';
  static const String devPanel = '/dev';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    debugLogDiagnostics: true,
    redirect: (final context, final state) {
      final auth = context.read<AuthController>();
      final isSignedIn = auth.signedIn;
      final role = auth.role;
      final location = state.uri.toString();

      // Don't redirect if already on splash or onboarding
      if (location == splash || location == onboarding) {
        return null;
      }

      // Redirect to onboarding if not signed in
      if (!isSignedIn) {
        return onboarding;
      }

      // Redirect based on role
      if (role == UserRole.participant) {
        if (location == providerDashboard) {
          return participantDashboard;
        }
      } else if (role == UserRole.provider) {
        if (location == participantDashboard) {
          return providerDashboard;
        }
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (final context, final state) => const SplashScreen(),
      ),

      // Onboarding Flow
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (final context, final state) => const OnboardingScreen(),
      ),

      // Link Portal (placeholder)
      GoRoute(
        path: linkPortal,
        name: 'linkPortal',
        builder: (final context, final state) => const LinkPortalScreen(),
      ),

      // Participant Dashboard
      GoRoute(
        path: participantDashboard,
        name: 'participantDashboard',
        builder: (final context, final state) => const ParticipantDashboardScreen(),
      ),

      // Provider Dashboard
      GoRoute(
        path: providerDashboard,
        name: 'providerDashboard',
        builder: (final context, final state) => const ProviderDashboardScreen(),
      ),

      // Budget Management
      GoRoute(
        path: budgets,
        name: 'budgets',
        builder: (final context, final state) => const BudgetsScreen(),
      ),

      // Claims Management
      GoRoute(
        path: claims,
        name: 'claims',
        builder: (final context, final state) => const ClaimsScreen(),
      ),

      // Services Map
      GoRoute(
        path: services,
        name: 'services',
        builder: (final context, final state) => const ServicesMapScreen(),
      ),

      // Messages
      GoRoute(
        path: messages,
        name: 'messages',
        builder: (final context, final state) => const MessagesScreen(),
      ),

      // Support Circle
      GoRoute(
        path: support,
        name: 'support',
        builder: (final context, final state) => const SupportCircleScreen(),
      ),

      // Calendar
      GoRoute(
        path: calendar,
        name: 'calendar',
        builder: (final context, final state) => const CalendarScreen(),
      ),

      // Settings
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (final context, final state) => const SettingsScreen(),
      ),

      // Dev Panel (development only)
      GoRoute(
        path: devPanel,
        name: 'devPanel',
        builder: (final context, final state) => const DevPanelScreen(),
      ),
    ],
    errorBuilder: (final context, final state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.uri}" could not be found.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(splash),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Navigation Helper Extensions
extension AppRouterExtensions on BuildContext {
  void goToSplash() => go(AppRouter.splash);
  void goToOnboarding() => go(AppRouter.onboarding);
  void goToLinkPortal() => go(AppRouter.linkPortal);
  void goToParticipantDashboard() => go(AppRouter.participantDashboard);
  void goToProviderDashboard() => go(AppRouter.providerDashboard);
  void goToBudgets() => go(AppRouter.budgets);
  void goToClaims() => go(AppRouter.claims);
  void goToServices() => go(AppRouter.services);
  void goToMessages() => go(AppRouter.messages);
  void goToSupport() => go(AppRouter.support);
  void goToCalendar() => go(AppRouter.calendar);
  void goToSettings() => go(AppRouter.settings);
  void goToDevPanel() => go(AppRouter.devPanel);

  void pushBudgets() => push(AppRouter.budgets);
  void pushClaims() => push(AppRouter.claims);
  void pushServices() => push(AppRouter.services);
  void pushMessages() => push(AppRouter.messages);
  void pushSupport() => push(AppRouter.support);
  void pushCalendar() => push(AppRouter.calendar);
  void pushSettings() => push(AppRouter.settings);
}
