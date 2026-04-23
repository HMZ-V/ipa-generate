// ============================================================
// router.dart — GoRouter config with ShellRoute for bottom nav.
// Mirrors the React Router structure in src/App.tsx.
//
// Route tree:
//   /onboarding
//   /app  (ShellRoute — AppLayout shell)
//     /app             → HomeScreen        (index)
//     /app/city        → CityMapScreen
//     /app/district/:id → DistrictDetailScreen
//     /app/market      → MarketScreen
//     /app/property/:id → PropertyDetailScreen
//     /app/territories → TerritoriesScreen
//     /app/wallet      → WalletScreen
//     /app/alliance    → AllianceScreen
//     /app/learn       → LearnScreen
//     /app/profile     → ProfileScreen
//     /app/notifications → NotificationsScreen
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shared/layouts/app_layout.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/market/screens/city_map_screen.dart';
import '../features/market/screens/district_detail_screen.dart';
import '../features/market/screens/market_screen.dart';
import '../features/market/screens/property_detail_screen.dart';
import '../features/wallet/screens/wallet_screen.dart';
import '../features/alliance/screens/alliance_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/real_mode_screen.dart';
import '../features/learn/screens/learn_screen.dart';

// Navigator keys — root key is needed to push full-screen routes
// (e.g. PropertyDetail) above the ShellRoute without showing the bottom nav.
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/onboarding',
  debugLogDiagnostics: true,
  routes: [
    // ── Onboarding (full-screen, no shell) ─────────────────────────────────
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => _fadeTransition(
        state,
        const OnboardingScreen(),
      ),
    ),

    // ── App Shell (persistent header + bottom nav) ─────────────────────────
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppLayout(child: child),
      routes: [
        // Home (index of /app)
        GoRoute(
          path: '/app',
          pageBuilder: (context, state) => _slideUp(state, const HomeScreen()),
        ),

        // City Map
        GoRoute(
          path: '/app/city',
          pageBuilder: (context, state) => _slideUp(state, const CityMapScreen()),
        ),

        // District Detail — uses :id path param
        GoRoute(
          path: '/app/district/:id',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return _slideUp(state, DistrictDetailScreen(id: id));
          },
        ),

        // Marketplace
        GoRoute(
          path: '/app/market',
          pageBuilder: (context, state) => _slideUp(state, const MarketScreen()),
        ),

        // Wallet
        GoRoute(
          path: '/app/wallet',
          pageBuilder: (context, state) =>
              _slideUp(state, const WalletScreen()),
        ),

        // Alliance
        GoRoute(
          path: '/app/alliance',
          pageBuilder: (context, state) =>
              _slideUp(state, const AllianceScreen()),
        ),

        // Profile
        GoRoute(
          path: '/app/profile',
          pageBuilder: (context, state) =>
              _slideUp(state, const ProfileScreen()),
        ),

        // Real Mode (inside shell for now)
        GoRoute(
          path: '/app/real',
          pageBuilder: (context, state) =>
              _slideUp(state, const RealModeScreen()),
        ),
        // Learn
        GoRoute(
          path: '/app/learn',
          pageBuilder: (context, state) =>
              _slideUp(state, const LearnScreen()),
        ),
      ],
    ),

    // ── Full Screen Routes (Outside Shell) ──────────────────────────────────
    // Property Detail — uses :id path param
    GoRoute(
      path: '/app/property/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _slideUp(state, PropertyDetailScreen(id: id));
      },
    ),
  ],

  // Fallback for unknown routes
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.uri}')),
  ),
);

// ── Page transition helpers ────────────────────────────────────────────────────

/// Mirrors the `animate-fade-up` CSS keyframe: slight Y slide + fade.
CustomTransitionPage<void> _slideUp(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 0.03); // 3% Y slide (matches 8px at 440px)
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end).chain(
        CurveTween(curve: Curves.easeOut),
      );
      final fadeTween = CurveTween(curve: Curves.easeOut);

      return FadeTransition(
        opacity: animation.drive(fadeTween),
        child: SlideTransition(
          position: animation.drive(tween),
          child: child,
        ),
      );
    },
  );
}

/// Plain fade — used for onboarding to avoid a navigation "feel".
CustomTransitionPage<void> _fadeTransition(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
        child: child,
      );
    },
  );
}
