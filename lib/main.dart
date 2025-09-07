import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'controllers/settings_controller.dart';
import 'controllers/auth_controller.dart';
import 'controllers/gamification_controller.dart';
import 'services/firebase_service.dart';
import 'services/purchase_service.dart';
import 'services/error_service.dart';
import 'services/advanced_analytics_service.dart';
import 'services/advanced_cache_service.dart';
import 'services/ai_chat_service.dart';
import 'services/performance_optimization_service.dart';
import 'services/advanced_security_service.dart';
import 'services/advanced_voice_service.dart';
import 'services/integration_service.dart';
import 'theme/app_theme.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for advanced caching
  await Hive.initFlutter();

  // Initialize services in order
  await ErrorService.initialize();
  await FirebaseService.tryInitialize();
  await PurchaseService.initialize();

  // Initialize Phase 2 advanced services
  await AdvancedAnalyticsService().initialize();
  await AdvancedCacheService().initialize();
  await AIChatService().initialize();
  await PerformanceOptimizationService().initialize();
  await AdvancedSecurityService().initialize();
  await AdvancedVoiceService().initialize();
  await IntegrationService().initialize();

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
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NDIS Connect',
      theme: AppTheme.lightTheme(highContrast: settings.highContrast),
      darkTheme: AppTheme.darkTheme(highContrast: settings.highContrast),
      themeMode: settings.themeMode,
      builder: (context, child) {
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
      initialRoute: Routes.bootstrap,
      routes: Routes.routes,
    );
  }
}
