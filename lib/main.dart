import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/settings_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/gamification_controller.dart';
import 'services/firebase_service.dart';
import 'services/purchase_service.dart';
import 'services/error_service.dart';
import 'services/performance_service.dart';
import 'ui/theme/app_theme.dart';
import 'app/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services in order
  await ErrorService.initialize();
  await PerformanceService().initialize();
  await FirebaseService.tryInitialize();
  await PurchaseService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsController()..load()),
        ChangeNotifierProvider(create: (_) => AuthController()..load()),
        ChangeNotifierProvider(create: (_) => GamificationController()..load()),
      ],
      child: const NDISConnectApp(),
    ),
  );
}

class NDISConnectApp extends StatelessWidget {
  const NDISConnectApp({super.key});

  @override
  Widget build(final BuildContext context) {
    final settings = context.watch<SettingsController>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'NDIS Connect',
      theme: NDISAppTheme.lightTheme(highContrast: settings.highContrast),
      darkTheme: NDISAppTheme.darkTheme(highContrast: settings.highContrast),
      themeMode: settings.themeMode,
      builder: (final context, final child) {
        // Apply user-selected text scale and reduced motion globally.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(settings.textScale),
            boldText: settings.highContrast,
            accessibleNavigation: settings.reduceMotion,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: AppRouter.router,
    );
  }
}
