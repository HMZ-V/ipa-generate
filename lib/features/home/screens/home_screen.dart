// ============================================================
// home_screen.dart — Core dashboard port of Home.tsx
//
// Features:
//   - LandGrabBanner (Countdown event)
//   - Portfolio Hero (Live stats + XP bar)
//   - Quick Actions Grid
//   - Owned Property Scroller (horizontal)
//   - Daily Missions List
//   - Alliance Standing card
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../../../models/models.dart';
import '../../../providers/app_state.dart';
import '../../../providers/mock_data.dart';
import '../../../shared/widgets/glass_container.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider);
    final fmt = NumberFormat('#,###');

    // Calculate portfolio value (mirrors Home.tsx calculation)
    final ownedBlocks = state.holdings.map((h) {
      final b = mockBlocks.firstWhere((x) => x.id == h.blockId);
      return (block: b, units: h.units, value: (b.priceSTK * h.units * 3.4).round());
    }).toList();

    final portfolioAED = state.portfolioValueAED;

    return Column(
      children: [
        // ── Event Banner ───────────────────────────────────────────────────
        const _LandGrabBanner(),
        const SizedBox(height: 16),

        // ── Portfolio Hero ──────────────────────────────────────────────────
        _PortfolioHero(
          portfolioAED: portfolioAED,
          stk: state.stk,
          xp: state.xp,
          level: state.level,
          streak: state.streak,
        ),
        const SizedBox(height: 16),

        // ── Buy $STK CTA ──────────────────────────────────────────────────
        _ActionCard(
          label: 'Buy \$STK to invest',
          sublabel: 'AED 3.67 / token · Spend on units',
          chip: '+6.8%',
          chipColor: AppColors.success,
          gradient: AppGradients.cyan,
          iconText: '\$',
          onTap: () => context.go('/app/wallet'),
        ),
        const SizedBox(height: 12),

        // ── Quick Actions Grid ──────────────────────────────────────────────
        const _QuickActions(),
        const SizedBox(height: 16),

        // ── Try Real Investing (Gold CTA) ───────────────────────────────────
        _ActionCard(
          label: 'Try real investing',
          sublabel: 'REIT-style exposure with checkpoints',
          chip: '18+',
          chipColor: AppColors.gold,
          gradient: AppGradients.gold,
          icon: Icons.auto_awesome_rounded,
          borderColor: AppColors.gold.withOpacity(0.3),
          onTap: () {}, // TODO: Navigation to real mode
        ),
        const SizedBox(height: 24),

        // ── Your Portfolio Scroller ─────────────────────────────────────────
        _SectionHeader(
          title: 'Your portfolio',
          actionLabel: 'Marketplace',
          onAction: () => context.go('/app/market'),
        ),
        const SizedBox(height: 10),
        _PortfolioScroller(ownedBlocks: ownedBlocks),
        const SizedBox(height: 24),

        // ── Today's Missions ────────────────────────────────────────────────
        _SectionHeader(
          title: "Today's missions",
          actionLabel: 'View all',
          onAction: () => context.go('/app/learn'), // Placeholder for missions list
        ),
        const SizedBox(height: 10),
        const _MissionsList(),
        const SizedBox(height: 24),

        // ── Alliance Card ──────────────────────────────────────────────────
        const _AllianceCard(),
        const SizedBox(height: 100), // padding for bottom nav
      ],
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _PortfolioHero extends StatelessWidget {
  final int portfolioAED;
  final int stk;
  final int xp;
  final int level;
  final int streak;

  const _PortfolioHero({
    required this.portfolioAED,
    required this.stk,
    required this.xp,
    required this.level,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###');
    final xpMax = seedUser.xpMax;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: AppRadius.xl,
      child: Stack(
        children: [
          // Background blur decoration
          Positioned(
            top: -40, right: -40,
            child: Container(
              width: 150, height: 150,
              decoration: BoxDecoration(
                color: AppColors.cyan.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL PORTFOLIO',
                          style: AppTextStyles.interSemiBold(10,
                              color: AppColors.mutedForeground)),
                      const SizedBox(height: 4),
                      Text('AED ${fmt.format(portfolioAED)}',
                          style: AppTextStyles.orbitronBold(28)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.north_east_rounded,
                              size: 14, color: AppColors.success),
                          const SizedBox(width: 4),
                          Text(
                            '+${seedUser.portfolioDelta}% · +AED ${fmt.format(seedUser.portfolioWeekAED)} this week',
                            style: AppTextStyles.interSemiBold(11,
                                color: AppColors.success),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const _Chip(label: 'SIM MODE', color: AppColors.cyan),
                ],
              ),
              const SizedBox(height: 20),

              // Mini Stat Cards
              Row(
                children: [
                  Expanded(child: _MiniStat(
                    label: 'STK',
                    value: fmt.format(stk),
                    sub: '≈ AED ${fmt.format(aedFromStk(stk))}',
                    color: AppColors.cyan,
                    icon: Icons.monetization_on_rounded,
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _MiniStat(
                    label: 'Pending',
                    value: seedUser.pendingAED.toString(),
                    sub: 'AED · next payout',
                    color: AppColors.gold,
                    icon: Icons.auto_awesome_rounded,
                  )),
                  const SizedBox(width: 8),
                  Expanded(child: _MiniStat(
                    label: 'Streak',
                    value: '${streak}d',
                    sub: '🔥 keep it alive',
                    color: AppColors.magenta,
                    icon: Icons.local_fire_department_rounded,
                  )),
                ],
              ),
              const SizedBox(height: 20),

              // XP Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Level $level', style: AppTextStyles.interSemiBold(12)),
                  Text('$xp / $xpMax XP',
                      style: AppTextStyles.jetBrainsMedium(11,
                          color: AppColors.mutedForeground)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Container(
                  height: 8,
                  width: double.infinity,
                  color: AppColors.secondary,
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: xp / xpMax,
                    child: Container(
                      decoration: const BoxDecoration(gradient: AppGradients.cyan),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;
  final IconData icon;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 10, color: AppColors.mutedForeground),
              const SizedBox(width: 4),
              Text(label,
                  style: AppTextStyles.interSemiBold(9,
                      color: AppColors.mutedForeground)),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: AppTextStyles.jetBrainsBold(15, color: color)),
          const SizedBox(height: 2),
          Text(sub,
              style: AppTextStyles.interRegular(9,
                  color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}

class _LandGrabBanner extends ConsumerWidget {
  const _LandGrabBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdown = ref.watch(countdownProvider).value;
    if (countdown == null) return const SizedBox();

    String pad(int n) => n.toString().padLeft(2, '0');

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: AppRadius.xl,
      borderColor: AppColors.magenta.withOpacity(0.4),
      child: Stack(
        children: [
          // Background glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.magenta.withOpacity(0.15),
                    Colors.transparent,
                    AppColors.gold.withOpacity(0.1),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: AppGradients.violet,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Text('🔥', style: TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('LAND GRAB EVENT',
                                style: AppTextStyles.orbitronBold(13,
                                    color: AppColors.magenta)),
                            const SizedBox(width: 8),
                            const _Chip(label: 'LIVE', color: AppColors.magenta),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('Marina Bay blocks −15% · first come, first served',
                            style: AppTextStyles.interRegular(11,
                                color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _TimeBox(value: pad(countdown.inHours), label: 'HRS'),
                  const SizedBox(width: 8),
                  _TimeBox(value: pad(countdown.inMinutes % 60), label: 'MIN'),
                  const SizedBox(width: 8),
                  _TimeBox(value: pad(countdown.inSeconds % 60), label: 'SEC'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String value;
  final String label;
  const _TimeBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.magenta.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value,
                style: AppTextStyles.jetBrainsBold(22, color: AppColors.magenta)),
            Text(label,
                style: AppTextStyles.interSemiBold(8,
                    color: AppColors.mutedForeground)),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String label;
  final String sublabel;
  final String chip;
  final Color chipColor;
  final LinearGradient gradient;
  final IconData? icon;
  final String? iconText;
  final Color? borderColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.label,
    required this.sublabel,
    required this.chip,
    required this.chipColor,
    required this.gradient,
    this.icon,
    this.iconText,
    this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      hoverable: true,
      onTap: onTap,
      borderColor: borderColor,
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: iconText != null
                ? Text(iconText!,
                    style: AppTextStyles.orbitronBold(18,
                        color: AppColors.primaryForeground))
                : Icon(icon, size: 22, color: AppColors.primaryForeground),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(label, style: AppTextStyles.interBold(15)),
                    const SizedBox(width: 8),
                    _Chip(label: chip, color: chipColor),
                  ],
                ),
                Text(sublabel,
                    style: AppTextStyles.interRegular(12,
                        color: AppColors.mutedForeground)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 20, color: AppColors.mutedForeground),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (to: '/app/wallet', l: '\$STK', i: Icons.monetization_on_rounded, c: AppGradients.cyan),
      (to: '/app/market', l: 'Market', i: Icons.storefront_rounded, c: AppGradients.gold),
      (to: '/app/alliance', l: 'Alliance', i: Icons.shield_rounded, c: AppGradients.violet),
      (to: '/app/learn', l: 'Learn', i: Icons.school_rounded, c: AppGradients.violet),
    ];

    return Row(
      children: actions.map((a) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GlassCard(
            hoverable: true,
            onTap: () => context.go(a.to),
            borderRadius: 16,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      gradient: a.c,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(a.i, size: 20, color: AppColors.primaryForeground),
                  ),
                  const SizedBox(height: 6),
                  Text(a.l, style: AppTextStyles.interSemiBold(11)),
                ],
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }
}

class _PortfolioScroller extends StatelessWidget {
  final List<({Block block, int units, int value})> ownedBlocks;
  const _PortfolioScroller({required this.ownedBlocks});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###');

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: ownedBlocks.length,
        itemBuilder: (context, i) {
          final b = ownedBlocks[i];
          return Container(
            width: 220,
            margin: const EdgeInsets.only(right: 12),
            child: GlassCard(
              hoverable: true,
              onTap: () => context.push('/app/property/${b.block.id}'),
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property Image with Gradient Overlay
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(AppRadius.lg)),
                      child: Stack(
                        children: [
                          // Placeholder for image
                          Container(
                            height: 100,
                            width: double.infinity,
                            color: AppColors.secondary,
                            child: const Icon(Icons.business_rounded,
                                color: AppColors.mutedForeground, size: 30),
                          ),
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.background.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8, right: 8,
                            child: _Chip(
                              label: '${b.block.yieldPct}% yield',
                              color: AppColors.success,
                            ),
                          ),
                          Positioned(
                            bottom: 8, left: 12,
                            child: Text(b.block.name,
                                style: AppTextStyles.interBold(13)),
                          ),
                        ],
                      ),
                    ),
                    // Stats
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${b.units} UNITS',
                              style: AppTextStyles.interSemiBold(10,
                                  color: AppColors.mutedForeground)),
                          const SizedBox(height: 2),
                          Text('AED ${fmt.format(b.value)}',
                              style: AppTextStyles.jetBrainsBold(14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MissionsList extends StatelessWidget {
  const _MissionsList();

  @override
  Widget build(BuildContext context) {
    final dailyMissions = mockMissions.where((m) => m.kind == MissionKind.daily);

    return Column(
      children: dailyMissions.map((m) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GlassCard(
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.cyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.emoji_events_rounded,
                    size: 22, color: AppColors.cyan),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(m.title, style: AppTextStyles.interSemiBold(14)),
                        Text('${m.progress}/${m.total}',
                            style: AppTextStyles.jetBrainsMedium(11,
                                color: AppColors.mutedForeground)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      child: Container(
                        height: 6,
                        width: double.infinity,
                        color: AppColors.secondary,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: m.progressFraction,
                          child: Container(
                            decoration: const BoxDecoration(gradient: AppGradients.cyan),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('+${m.xpReward} XP · +${m.stkReward} STK',
                          style: AppTextStyles.interSemiBold(11,
                              color: AppColors.gold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )).toList(),
    );
  }
}

class _AllianceCard extends StatelessWidget {
  const _AllianceCard();

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###');
    final a = mockAlliance;

    return GlassCard(
      hoverable: true,
      onTap: () => context.go('/app/alliance'),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: AppGradients.violet,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(a.tag,
                    style: AppTextStyles.orbitronBold(16, color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.name, style: AppTextStyles.interBold(15)),
                    Row(
                      children: [
                        Text('Rank #${a.rank} · ',
                            style: AppTextStyles.interRegular(12,
                                color: AppColors.mutedForeground)),
                        Text('+${a.rankDelta} ranks',
                            style: AppTextStyles.interSemiBold(12,
                                color: AppColors.success)),
                      ],
                    ),
                  ],
                ),
              ),
              const Text('Open →',
                  style: TextStyle(
                      color: AppColors.cyan,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AllianceStat(value: fmt.format(a.seasonPts), label: 'Season pts'),
              _AllianceStat(value: a.members.toString(), label: 'Members'),
              _AllianceStat(value: a.districtsControlled.toString(), label: 'Zones'),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.cyan.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events_rounded, size: 14, color: AppColors.cyan),
                const SizedBox(width: 6),
                Text('You contribute ${fmt.format(a.yourContribution)} pts',
                    style: AppTextStyles.interSemiBold(11, color: AppColors.cyan)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllianceStat extends StatelessWidget {
  final String value;
  final String label;
  const _AllianceStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.orbitronBold(16)),
        Text(label.toUpperCase(),
            style: AppTextStyles.interSemiBold(9,
                color: AppColors.mutedForeground, letterSpacing: 1.0)),
      ],
    );
  }
}

// ── Generic components ────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: AppTextStyles.interBold(9, color: color)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.orbitronBold(18)),
        GestureDetector(
          onTap: onAction,
          child: Row(
            children: [
              Text(actionLabel,
                  style: AppTextStyles.interSemiBold(13, color: AppColors.cyan)),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.cyan),
            ],
          ),
        ),
      ],
    );
  }
}
