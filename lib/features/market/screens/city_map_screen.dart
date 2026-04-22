// ============================================================
// city_map_screen.dart — Port of CityMap.tsx
//
// Features:
//   - Interactive map overview using city-map.jpg
//   - Filter chips (All, Owned, Hot)
//   - Detailed district list with control progress bars
//   - Locked district logic with level requirements
//   - Dynamic market status indicators (Hot, Rising, Contested)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';
import '../../../models/models.dart';
import '../../../providers/app_state.dart';
import '../../../providers/mock_data.dart';
import '../../../shared/widgets/glass_container.dart';

class CityMapScreen extends ConsumerStatefulWidget {
  const CityMapScreen({super.key});

  @override
  ConsumerState<CityMapScreen> createState() => _CityMapScreenState();
}

class _CityMapScreenState extends ConsumerState<CityMapScreen> {
  String _filter = 'all'; // 'all', 'owned', 'hot'

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameStateProvider);
    final control = state.districtControl;

    final filtered = mockDistricts.where((d) {
      final c = control[d.id] ?? 0.0;
      if (_filter == 'all') return true;
      if (_filter == 'owned') return c > 0;
      if (_filter == 'hot') {
        return d.status == DistrictStatus.hot || d.status == DistrictStatus.contested;
      }
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // ── Header ────────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('City Control', style: AppTextStyles.orbitronBold(24)),
                const SizedBox(height: 4),
                Text('Tap a district to explore',
                    style: AppTextStyles.interRegular(13, color: AppColors.mutedForeground)),
              ],
            ),
            _SeasonChip(),
          ],
        ),
        const SizedBox(height: 16),

        // ── Filters ───────────────────────────────────────────────────────
        Row(
          children: [
            _FilterBtn(label: 'All', isSel: _filter == 'all', onTap: () => setState(() => _filter = 'all')),
            const SizedBox(width: 8),
            _FilterBtn(label: 'Owned', isSel: _filter == 'owned', onTap: () => setState(() => _filter = 'owned')),
            const SizedBox(width: 8),
            _FilterBtn(label: '🔥 Hot', isSel: _filter == 'hot', onTap: () => setState(() => _filter = 'hot')),
          ],
        ),
        const SizedBox(height: 16),

        // ── Visual Map ────────────────────────────────────────────────────
        GlassContainer(
          padding: const EdgeInsets.all(12),
          borderRadius: AppRadius.xl,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1.5,
                  child: Image.asset(
                    'assets/city-map.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _LegendItem(label: 'Your control', color: AppColors.cyan),
                  _LegendItem(label: 'Premium', color: AppColors.gold),
                  _LegendItem(label: 'Contested', color: AppColors.magenta),
                  _LegendItem(label: 'Locked', icon: Icons.lock_outline_rounded),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Districts List ────────────────────────────────────────────────
        Text('Districts', style: AppTextStyles.orbitronBold(18)),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          itemBuilder: (context, i) {
            final d = filtered[i];
            final c = control[d.id] ?? 0.0;
            final isLocked = d.unlockLevel != null && d.unlockLevel! > seedUser.level;

            return GestureDetector(
              onTap: isLocked ? null : () => context.push('/app/district/${d.id}'),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Opacity(
                  opacity: isLocked ? 0.6 : 1.0,
                  child: GlassContainer(
                    padding: const EdgeInsets.all(12),
                    borderRadius: AppRadius.lg,
                    child: Row(
                      children: [
                        // Emoji / Lock Icon
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: isLocked
                              ? const Icon(Icons.lock_rounded, size: 20, color: AppColors.mutedForeground)
                              : Text(d.emoji, style: const TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 12),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(d.name, style: AppTextStyles.interBold(15)),
                                  if (isLocked) ...[
                                    const SizedBox(width: 8),
                                    _MiniChip(label: 'Lvl ${d.unlockLevel}', color: AppColors.gold),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              _StatusRow(district: d),
                              const SizedBox(height: 8),
                              // Progress Bar
                              Container(
                                height: 6,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (c > 0 ? c / 100 : 0.04), // 4% min visual fill
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: isLocked ? null : AppGradients.cyan,
                                      color: isLocked ? AppColors.mutedForeground : null,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Percentage
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${c.toStringAsFixed(0)}%',
                                style: AppTextStyles.orbitronBold(16, color: isLocked ? AppColors.mutedForeground : AppColors.foreground)),
                            Text('CONTROL',
                                style: AppTextStyles.interSemiBold(8, color: AppColors.mutedForeground)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        ),
        const SizedBox(height: 20),
      ],
    ),
   );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _SeasonChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.success.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('Season 4 · 12d left', style: AppTextStyles.interBold(10, color: AppColors.success)),
        ],
      ),
    );
  }
}

class _FilterBtn extends StatelessWidget {
  final String label;
  final bool isSel;
  final VoidCallback onTap;
  const _FilterBtn({required this.label, required this.isSel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSel ? AppColors.cyan.withOpacity(0.15) : AppColors.secondary.withOpacity(0.6),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: isSel ? AppColors.cyan.withOpacity(0.5) : AppColors.border),
          boxShadow: isSel ? [BoxShadow(color: AppColors.cyan.withOpacity(0.2), blurRadius: 8)] : null,
        ),
        child: Text(label,
            style: AppTextStyles.interSemiBold(13, color: isSel ? AppColors.cyan : AppColors.mutedForeground)),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;
  const _LegendItem({required this.label, this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (color != null)
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle))
        else if (icon != null)
          Icon(icon, size: 12, color: AppColors.mutedForeground),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.interRegular(11, color: AppColors.mutedForeground)),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  final District district;
  const _StatusRow({required this.district});

  @override
  Widget build(BuildContext context) {
    Widget statusWidget;
    switch (district.status) {
      case DistrictStatus.hot:
        statusWidget = const Text('🔥 Hot', style: TextStyle(color: AppColors.magenta));
        break;
      case DistrictStatus.rising:
        statusWidget = const Text('📈 Rising', style: TextStyle(color: AppColors.success));
        break;
      case DistrictStatus.stable:
        statusWidget = const Text('📊 Stable', style: TextStyle(color: AppColors.mutedForeground));
        break;
      case DistrictStatus.contested:
        statusWidget = const Text('⚔️ Contested', style: TextStyle(color: AppColors.magenta));
        break;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          statusWidget,
          const Text(' · ', style: TextStyle(color: AppColors.mutedForeground)),
          Text('${district.demand.name} demand', style: const TextStyle(color: AppColors.mutedForeground)),
          const Text(' · ', style: TextStyle(color: AppColors.mutedForeground)),
          const Icon(Icons.group_outlined, size: 11, color: AppColors.mutedForeground),
          const SizedBox(width: 2),
          Text(district.topAlliance, style: const TextStyle(color: AppColors.mutedForeground), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: AppTextStyles.interBold(9, color: color)),
    );
  }
}
