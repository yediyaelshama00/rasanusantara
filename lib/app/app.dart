import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/splash_screen.dart';
import 'routes.dart';

class RasaNusantaraApp extends StatelessWidget {
  const RasaNusantaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RasaNusantara',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
      routes: AppRoutes.values,
    );
  }
}
