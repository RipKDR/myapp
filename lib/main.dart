
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Key features directories
import 'package:ndis_connect/src/app.dart';
import 'package:ndis_connect/src/core/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const NdisConnectApp(),
    ),
  );
}
