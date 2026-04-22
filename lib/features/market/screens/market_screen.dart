// ============================================================
// market_screen.dart — Port of Market.tsx
//
// Features:
//   - Search bar & Risk/Yield filters
//   - Compact LandGrabBanner
//   - 2-column block grid
//   - Rarity/Hot badges & Sold Out overlay
//   - Compare toggle (integrated with compareProvider)
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

const _filters = ["All risk", "Low risk", "Medium risk", "High risk", "Top yield"];

class MarketScreen extends ConsumerStatefulWidget {
  const MarketScreen({super.key});

  @override
  ConsumerState<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends ConsumerState<MarketScreen> {
  String _query = '';
  String _filter = 'All risk';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter and sort the mockBlocks based on state
    var list = mockBlocks.where((b) {
      if (_query.isNotEmpty) {
        final q = _query.toLowerCase();
        if (!b.name.toLowerCase().contains(q) &&
            !b.district.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_filter == 'Low risk') return b.risk == 'Low';
      if (_filter == 'Medium risk') return b.risk == 'Medium';
      if (_filter == 'High risk') return b.risk == 'High';
      return true;
    }).toList();

    if (_filter == 'Top yield') {
      list.sort((a, b) => b.yieldPct.compareTo(a.yieldPct));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        // ── Header ────────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Marketplace', style: AppTextStyles.orbitronBold(24)),
                  const SizedBox(height: 4),
                  Text('Buy fractional units of Dubai-style property blocks.',
                      style: AppTextStyles.interRegular(13,
                          color: AppColors.mutedForeground)),
                ],
              ),
            ),
            const _Chip(label: 'SIM MODE', color: AppColors.cyan),
          ],
        ),
        const SizedBox(height: 16),

        // ── Compact Event Banner ──────────────────────────────────────────
        const _CompactLandGrabBanner(),
        const SizedBox(height: 16),

        // ── Search & Filter Row ───────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                borderRadius: AppRadius.lg,
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded,
                        size: 18, color: AppColors.mutedForeground),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        style: AppTextStyles.interRegular(14),
                        decoration: InputDecoration(
                          hintText: 'Search blocks or districts',
                          hintStyle: AppTextStyles.interRegular(14,
                              color: AppColors.mutedForeground),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GlassContainer(
              padding: const EdgeInsets.all(14),
              borderRadius: AppRadius.lg,
              child: const Icon(Icons.tune_rounded, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // ── Filter Chips (Scrollable) ─────────────────────────────────────
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            itemCount: _filters.length,
            itemBuilder: (context, i) {
              final t = _filters[i];
              final isSel = _filter == t;
              final isTopYield = t == 'Top yield';

              Color textColor = AppColors.mutedForeground;
              Color bgColor = AppColors.secondary.withOpacity(0.6);
              Color borderColor = AppColors.border;

              if (isSel) {
                if (isTopYield) {
                  textColor = AppColors.gold;
                  bgColor = AppColors.gold.withOpacity(0.15);
                  borderColor = AppColors.gold.withOpacity(0.5);
                } else {
                  textColor = AppColors.cyan;
                  bgColor = AppColors.cyan.withOpacity(0.15);
                  borderColor = AppColors.cyan.withOpacity(0.5);
                }
              }

              return GestureDetector(
                onTap: () => setState(() => _filter = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: borderColor),
                    boxShadow: isSel && !isTopYield
                        ? [BoxShadow(color: AppColors.cyan.withOpacity(0.2), blurRadius: 8)]
                        : null,
                  ),
                  child: Text(
                    isTopYield ? '🏆 $t' : t,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // ── Grid ──────────────────────────────────────────────────────────
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.68, // Match approximate React aspect ratio
          ),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final b = list[i];
            return _PropertyCard(block: b);
          },
        ),
        const SizedBox(height: 100), // Bottom nav padding
      ],
    ),
   );
  }
}

// ── Property Grid Card ───────────────────────────────────────────────────────

class _PropertyCard extends ConsumerWidget {
  final Block block;
  const _PropertyCard({required this.block});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = NumberFormat('#,###');
    final compareIds = ref.watch(compareProvider);
    final isCompared = compareIds.contains(block.id);

    return GlassCard(
      hoverable: true,
      onTap: () => context.push('/app/property/${block.id}'),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image Section ───────────────────────────────────────────
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      block.imagePath,
                      fit: BoxFit.cover,
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.background.withOpacity(0.9),
                            AppColors.background.withOpacity(0.2),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    // Rarity Chip (Top Left)
                    Positioned(
                      top: 8, left: 8,
                      child: _RarityChip(rarity: block.rarity),
                    ),
                    // Yield Badge (Top Right)
                    Positioned(
                      top: 8, right: 8,
                      child: _Chip(
                        label: '${block.yieldPct}%',
                        color: AppColors.success,
                        fontMono: true,
                      ),
                    ),
                    // Hot Badge (Bottom Left)
                    if (block.isHot)
                      Positioned(
                        bottom: 8, left: 8,
                        child: _Chip(
                          label: '🔥 Hot',
                          color: AppColors.magenta,
                          iconMode: true,
                        ),
                      ),
                    // Sold Out Overlay
                    if (block.available == 0)
                      Container(
                        color: AppColors.background.withOpacity(0.7),
                        alignment: Alignment.center,
                        child: const _Chip(
                          label: 'SOLD OUT',
                          color: AppColors.magenta,
                        ),
                      ),
                  ],
                ),
              ),

              // ── Details Section ─────────────────────────────────────────
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(block.name,
                          style: AppTextStyles.interBold(13),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(block.district,
                          style: AppTextStyles.interRegular(11,
                              color: AppColors.mutedForeground),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      
                      const Spacer(),

                      Text('PER UNIT',
                          style: AppTextStyles.interSemiBold(10,
                              color: AppColors.mutedForeground, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${block.priceSTK} STK',
                              style: AppTextStyles.jetBrainsBold(13, color: AppColors.cyan)),
                          Text('≈ AED ${fmt.format(aedFromStk(block.priceSTK))}',
                              style: AppTextStyles.interRegular(10,
                                  color: AppColors.mutedForeground)),
                        ],
                      ),
                      const SizedBox(height: 20), // Space for compare button
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Compare Button (Absolute Bottom Right) ──────────────────────
          Positioned(
            bottom: 8, right: 8,
            child: GestureDetector(
              onTap: () {
                // Prevent navigation when tapping compare
                ref.read(compareProvider.notifier).toggle(block.id);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompared ? AppColors.cyan : AppColors.background.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: isCompared ? AppColors.cyan : AppColors.cyan.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isCompared ? Icons.check_rounded : Icons.compare_arrows_rounded,
                      size: 12,
                      color: isCompared ? AppColors.primaryForeground : AppColors.cyan,
                    ),
                    const SizedBox(width: 4),
                    Text('Compare',
                        style: AppTextStyles.interSemiBold(10,
                            color: isCompared ? AppColors.primaryForeground : AppColors.cyan)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Components ───────────────────────────────────────────────────────────────

class _CompactLandGrabBanner extends ConsumerWidget {
  const _CompactLandGrabBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdown = ref.watch(countdownProvider).value;
    if (countdown == null) return const SizedBox();

    final hours = countdown.inHours.toString().padLeft(2, '0');
    final mins = (countdown.inMinutes % 60).toString().padLeft(2, '0');
    final secs = (countdown.inSeconds % 60).toString().padLeft(2, '0');
    final label = '$hours:$mins:$secs';

    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: AppRadius.lg,
      borderColor: AppColors.magenta.withOpacity(0.4),
      child: Stack(
        children: [
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
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.magenta.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.local_fire_department_rounded,
                    color: AppColors.magenta, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('LAND GRAB',
                            style: AppTextStyles.orbitronBold(12,
                                color: AppColors.magenta)),
                        const SizedBox(width: 8),
                        const _Chip(label: '−15% Marina', color: AppColors.magenta),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('Ends in $label',
                        style: AppTextStyles.jetBrainsMedium(11,
                            color: AppColors.mutedForeground)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded,
                  size: 16, color: AppColors.magenta),
            ],
          ),
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
      case Rarity.common:
        c = AppColors.mutedForeground;
        break;
      case Rarity.rare:
        c = AppColors.cyan;
        break;
      case Rarity.epic:
        c = AppColors.magenta;
        break;
      case Rarity.legendary:
        c = AppColors.gold;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.6),
        border: Border.all(color: c.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(rarity.name.toUpperCase(),
          style: AppTextStyles.interBold(9, color: c)),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool fontMono;
  final bool iconMode;
  const _Chip({
    required this.label,
    required this.color,
    this.fontMono = false,
    this.iconMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: iconMode ? 6 : 8, vertical: iconMode ? 2 : 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: fontMono
            ? AppTextStyles.jetBrainsBold(10, color: color)
            : AppTextStyles.interBold(9, color: color),
      ),
    );
  }
}
