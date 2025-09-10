import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'controllers/settings_controller.dart';
import 'controllers/auth_controller_simple.dart';
import 'controllers/gamification_controller.dart';
import 'services/local_database_service.dart';
import 'services/error_service.dart';
import 'theme/app_theme.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for caching
  await Hive.initFlutter();

  // Initialize local database
  await LocalDatabaseService().database;

  // Initialize error handling
  await ErrorService.initialize();

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

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NDIS Connect',
      theme: AppTheme.lightTheme(highContrast: settings.highContrast),
      darkTheme: AppTheme.darkTheme(highContrast: settings.highContrast),
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
      initialRoute: Routes.bootstrap,
      routes: Routes.routes,
    );
  }
}
