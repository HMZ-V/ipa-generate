// ============================================================
// main.dart — App entry point.
// Wires: ProviderScope (Riverpod) + GoRouter + AppTheme
// Also loads persisted game state from SharedPreferences on startup.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'providers/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation (mobile-first, max 440px design)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style — transparent with light icons for the neon dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Create the Riverpod container so we can preload state before runApp
  final container = ProviderContainer();

  // Load persisted game state (mirrors zustand/middleware persist)
  await container.read(gameStateProvider.notifier).loadFromPrefs();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const StackUpApp(),
    ),
  );
}

class StackUpApp extends StatelessWidget {
  const StackUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'StackUp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,

      // GoRouter handles all routing
      routerConfig: appRouter,

      // Builder adds a max-width constraint matching the web app's max-w-[440px]
      builder: (context, child) {
        return Container(
          color: AppColors.background,
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: child!,
          ),
        );
      },
    );
  }
}
