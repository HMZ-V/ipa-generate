// ============================================================
// app_layout.dart — Persistent shell wrapping all /app/* routes.
//
// Ports AppLayout.tsx:
//   - Sticky glass header: avatar/level badge, title, STK pill, Bell, Learn
//   - Animated STK counter (useCountUp → _CountUpText)
//   - Flash animation on STK change (useFlash → _flashController)
//   - Bottom glass nav bar with 5 tabs
// ============================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../providers/app_state.dart';
import '../widgets/glass_container.dart';

// ── Tab definitions (mirrors AppLayout.tsx tabs array) ───────────────────────

class _TabItem {
  final String route;
  final String label;
  final IconData icon;
  const _TabItem(this.route, this.label, this.icon);
}

const _tabs = [
  _TabItem('/app', 'Home', Icons.home_rounded),
  _TabItem('/app/market', 'Market', Icons.storefront_rounded),
  _TabItem('/app/city', 'Map', Icons.explore_rounded),
  _TabItem('/app/wallet', 'Wallet', Icons.account_balance_wallet_rounded),
  _TabItem('/app/missions', 'Missions', Icons.emoji_events_rounded),
];

// ── Shell layout ──────────────────────────────────────────────────────────────

class AppLayout extends ConsumerStatefulWidget {
  final Widget child;
  const AppLayout({super.key, required this.child});

  @override
  ConsumerState<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends ConsumerState<AppLayout>
    with TickerProviderStateMixin {
  // ── Flash animation (mirrors useFlash hook) ─────────────────────────────
  late AnimationController _flashCtrl;
  late Animation<double> _flashScale;
  late Animation<Color?> _flashColor;
  int _prevFlash = 0;

  // ── Count-up animation (mirrors useCountUp hook) ────────────────────────
  late AnimationController _countCtrl;
  late Animation<int> _countAnim;
  int _fromStk = 0;
  int _toStk = 0;

  @override
  void initState() {
    super.initState();

    _flashCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _flashScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 70),
    ]).animate(CurvedAnimation(parent: _flashCtrl, curve: Curves.easeOut));

    _flashColor = ColorTween(
      begin: AppColors.cyan.withOpacity(0.1),
      end: AppColors.cyan.withOpacity(0.3),
    ).animate(_flashCtrl);

    _countCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    final state = ref.read(gameStateProvider);
    _fromStk = state.stk;
    _toStk = state.stk;
    _countAnim = IntTween(begin: _toStk, end: _toStk).animate(_countCtrl);
  }

  @override
  void dispose() {
    _flashCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  void _triggerFlash(int newStk) {
    _fromStk = _toStk;
    _toStk = newStk;
    _countAnim = IntTween(begin: _fromStk, end: _toStk).animate(
      CurvedAnimation(parent: _countCtrl, curve: Curves.easeOut),
    );
    _countCtrl.forward(from: 0);
    _flashCtrl.forward(from: 0);
  }

  // ── Active tab helper ─────────────────────────────────────────────────────

  int _activeIndex(String location) {
    // Match longest prefix so /app/city beats /app
    int best = 0;
    int bestLen = 0;
    for (int i = 0; i < _tabs.length; i++) {
      final route = _tabs[i].route;
      if (location.startsWith(route) && route.length > bestLen) {
        best = i;
        bestLen = route.length;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);

    // Trigger animations when flashCount changes
    if (gameState.flashCount != _prevFlash) {
      _prevFlash = gameState.flashCount;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerFlash(gameState.stk);
      });
    }

    final location = GoRouterState.of(context).uri.toString();
    final activeIdx = _activeIndex(location);
    final fmt = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Sticky Glass Header ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                borderRadius: AppRadius.lg,
                child: Row(
                  children: [
                    // Avatar + level badge
                    GestureDetector(
                      onTap: () => context.go('/app/profile'),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: AppGradients.cyan,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'H',
                              style: AppTextStyles.orbitronBold(16,
                                  color: AppColors.primaryForeground),
                            ),
                          ),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.background, width: 1.5),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${gameState.level}',
                                style: AppTextStyles.interBold(9,
                                    color: AppColors.primaryForeground),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Title + rank
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('StackUp',
                              style: AppTextStyles.orbitronBold(13)),
                          Text('Lvl ${gameState.level} · Rank #412',
                              style: AppTextStyles.interRegular(10,
                                  color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),

                    // STK pill with flash animation
                    AnimatedBuilder(
                      animation: _flashCtrl,
                      builder: (context, _) {
                        return Transform.scale(
                          scale: _flashScale.value,
                          child: GestureDetector(
                            onTap: () => context.go('/app/wallet'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _flashColor.value ??
                                    AppColors.cyan.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: AppColors.cyan.withOpacity(
                                      _flashCtrl.isAnimating ? 0.8 : 0.4),
                                ),
                                boxShadow: _flashCtrl.isAnimating
                                    ? AppGlows.cyan
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.monetization_on_rounded,
                                      size: 13, color: AppColors.cyan),
                                  const SizedBox(width: 4),
                                  AnimatedBuilder(
                                    animation: _countAnim,
                                    builder: (_, __) => Text(
                                      fmt.format(_countAnim.value),
                                      style: AppTextStyles.jetBrainsBold(12,
                                          color: AppColors.cyan),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),

                    // Notifications bell
                    GestureDetector(
                      onTap: () => context.go('/app/notifications'),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.notifications_rounded,
                                size: 18, color: AppColors.foreground),
                          ),
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: AppColors.magenta,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text('3',
                                  style: AppTextStyles.interBold(9,
                                      color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Learn button
                    GestureDetector(
                      onTap: () => context.go('/app/learn'),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.school_rounded,
                            size: 18, color: AppColors.foreground),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Page content ───────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: widget.child,
              ),
            ),
          ],
        ),
      ),

      // ── Floating Glass Bottom Nav ──────────────────────────────────────────
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          borderRadius: AppRadius.lg,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (i) {
              final tab = _tabs[i];
              final isActive = i == activeIdx;
              return Expanded(
                child: GestureDetector(
                  onTap: () => context.go(tab.route),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.cyan.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: isActive
                          ? Border.all(
                              color: AppColors.cyan.withOpacity(0.6), width: 1)
                          : null,
                      boxShadow: isActive ? AppGlows.cyan : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          size: 20,
                          color: isActive
                              ? AppColors.cyan
                              : AppColors.mutedForeground,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tab.label,
                          style: AppTextStyles.interSemiBold(10,
                              color: isActive
                                  ? AppColors.cyan
                                  : AppColors.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
