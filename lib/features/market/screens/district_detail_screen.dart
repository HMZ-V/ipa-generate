// ============================================================
// district_detail_screen.dart — Port of District.tsx
//
// Features:
//   - District hero with live control % and status badges
//   - Segmented territory bar (balance of power)
//   - Unlockable district perks list
//   - List of all property blocks within the district
//   - Integrated with gameStateProvider for real-time control stats
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

class DistrictDetailScreen extends ConsumerWidget {
  final String id;
  const DistrictDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider);
    final district = mockDistricts.firstWhere((x) => x.id == id, orElse: () => mockDistricts[0]);
    final districtBlocks = mockBlocks.where((b) => b.districtId == district.id).toList();
    final yourControl = state.districtControl[district.id] ?? 0.0;
    
    // Logic for eviction risk (ported from React)
    final topRival = district.rivals.where((r) => r.name != 'Others' && !r.name.contains('Gulf') && !r.name.contains('You')).fold(0.0, (prev, r) => r.pct > prev ? r.pct.toDouble() : prev);
    final evictionRisk = topRival > yourControl && yourControl > 0 && (topRival - yourControl) < 10;

    final fmt = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // District Image
                SizedBox(
                  height: 240,
                  width: double.infinity,
                  child: Image.asset(
                    district.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
                // Gradient Overlay
                Container(
                  height: 240,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.background, Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                // Back Button & Name
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 20, right: 20,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.background.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _Chip(label: '${district.emoji} ${district.name}', color: AppColors.foreground, bgColor: AppColors.background.withOpacity(0.6)),
                      if (district.status == DistrictStatus.hot) ...[
                        const SizedBox(width: 8),
                        const _Chip(label: '🔥 Hot', color: AppColors.magenta),
                      ],
                    ],
                  ),
                ),
                // Control Stats
                Positioned(
                  bottom: 20, left: 20, right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('YOUR CONTROL', style: AppTextStyles.interSemiBold(10, color: AppColors.mutedForeground, letterSpacing: 1.0)),
                      const SizedBox(height: 4),
                      Text('${yourControl.toStringAsFixed(1)}%', style: AppTextStyles.orbitronBold(36, color: AppColors.cyan)),
                      if (evictionRisk) ...[
                        const SizedBox(height: 8),
                        const _Chip(label: '⚠ EVICTION RISK', color: AppColors.magenta, glow: true),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Territory Bar ───────────────────────────────────────────
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: AppRadius.xl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Territory control', style: AppTextStyles.interBold(14)),
                          Text('Top: ${district.topAlliance}', style: AppTextStyles.interRegular(11, color: AppColors.mutedForeground)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Segmented Progress Bar
                      _TerritoryBar(rivals: district.rivals),
                      const SizedBox(height: 12),
                      // Legend
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: district.rivals.map((r) => _LegendItem(rival: r)).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Perks ───────────────────────────────────────────────────
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: AppRadius.xl,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(Icons.verified_user_rounded, size: 16, color: AppColors.gold),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('District perks', style: AppTextStyles.interBold(14)),
                                Text('Unlock at 50% control', style: AppTextStyles.interRegular(10, color: AppColors.mutedForeground)),
                              ],
                            ),
                          ),
                          _Chip(label: '🔒 ${yourControl.toInt()}/50%', color: AppColors.mutedForeground, bgColor: AppColors.secondary),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...district.perks.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Text('★', style: TextStyle(color: AppColors.gold, fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(p, style: AppTextStyles.interRegular(13)),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Available Blocks ────────────────────────────────────────
                Text('Available blocks', style: AppTextStyles.orbitronBold(18)),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: districtBlocks.length,
                  itemBuilder: (context, i) {
                    final b = districtBlocks[i];
                    return GestureDetector(
                      onTap: () => context.push('/app/property/${b.id}'),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: GlassContainer(
                          padding: const EdgeInsets.all(12),
                          borderRadius: AppRadius.lg,
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(b.imagePath, width: 64, height: 64, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text(b.name, style: AppTextStyles.interBold(14), overflow: TextOverflow.ellipsis)),
                                        _RarityChip(rarity: b.rarity),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text('${b.available}/${b.total} units · ${b.occupancy.name} · ${b.risk.name}',
                                        style: AppTextStyles.interRegular(10, color: AppColors.mutedForeground)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text('${b.priceSTK} STK', style: AppTextStyles.jetBrainsBold(13, color: AppColors.cyan)),
                                        const SizedBox(width: 8),
                                        Text('≈ AED ${fmt.format(aedFromStk(b.priceSTK))}',
                                            style: AppTextStyles.interRegular(10, color: AppColors.mutedForeground)),
                                        const Spacer(),
                                        _Chip(label: '${b.yieldPct}%', color: AppColors.success, icon: Icons.trending_up_rounded),
                                      ],
                                    ),
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
                const SizedBox(height: 24),

                // ── About District ──────────────────────────────────────────
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: AppRadius.lg,
                  borderColor: AppColors.violet.withOpacity(0.3),
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.interRegular(11, color: AppColors.mutedForeground),
                      children: [
                        const TextSpan(text: '📚 In real terms: ', style: TextStyle(color: AppColors.violet, fontWeight: FontWeight.bold)),
                        TextSpan(text: district.about),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _TerritoryBar extends StatelessWidget {
  final List<Rival> rivals;
  const _TerritoryBar({required this.rivals});

  @override
  Widget build(BuildContext context) {
    // Generate colors for rivals since they aren't in the model yet
    final colors = [AppColors.cyan, AppColors.gold, AppColors.magenta, AppColors.violet, Colors.grey];
    
    return Container(
      height: 12,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Row(
          children: rivals.asMap().entries.map((entry) {
            final i = entry.key;
            final r = entry.value;
            return Expanded(
              flex: r.pct,
              child: Container(color: colors[i % colors.length]),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Rival rival;
  const _LegendItem({required this.rival});

  @override
  Widget build(BuildContext context) {
    // Match color logic from _TerritoryBar
    final colors = [AppColors.cyan, AppColors.gold, AppColors.magenta, AppColors.violet, Colors.grey];
    final i = mockDistricts.expand((d) => d.rivals).toList().indexOf(rival); // Simple hack for stable coloring
    final color = colors[i % colors.length];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(rival.name, style: AppTextStyles.interRegular(11, color: AppColors.mutedForeground)),
        const SizedBox(width: 4),
        Text('${rival.pct}%', style: AppTextStyles.jetBrainsMedium(11, color: AppColors.mutedForeground.withOpacity(0.5))),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? bgColor;
  final IconData? icon;
  final bool glow;

  const _Chip({required this.label, required this.color, this.bgColor, this.icon, this.glow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor ?? color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.4)),
        boxShadow: glow ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 4)],
          Text(label, style: AppTextStyles.interBold(10, color: color)),
        ],
      ),
    );
  }
}

class _RarityChip extends StatelessWidget {
  final Rarity rarity;
  const _RarityChip({required this.rarity});

  @override
  Widget build(BuildContext context) {
    Color c;
    switch (rarity) {
      case Rarity.common: c = AppColors.mutedForeground; break;
      case Rarity.rare: c = AppColors.cyan; break;
      case Rarity.epic: c = AppColors.magenta; break;
      case Rarity.legendary: c = AppColors.gold; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.5),
        border: Border.all(color: c.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(rarity.name.toUpperCase(), style: AppTextStyles.interBold(8, color: c)),
    );
  }
}
