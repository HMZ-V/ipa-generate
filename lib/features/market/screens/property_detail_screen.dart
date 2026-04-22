// ============================================================
// property_detail_screen.dart — Port of Property.tsx
//
// Features:
//   - High-res property hero with yield badge
//   - Performance chart (CustomPaint)
//   - Territory impact calculation
//   - Interactive "Acquire Block" sticky panel
//   - Riverpod integration for buyBlock logic
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

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final String id;
  const PropertyDetailScreen({super.key, required this.id});

  @override
  ConsumerState<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  int _units = 1;
  bool _isSuccess = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameStateProvider);
    final block = mockBlocks.firstWhere((x) => x.id == widget.id, orElse: () => mockBlocks[0]);
    final district = mockDistricts.firstWhere((x) => x.id == block.districtId);
    
    final fmt = NumberFormat('#,###');
    final totalCost = block.priceSTK * _units;
    final territoryAdd = ((_units / block.total) * 6).toStringAsFixed(1);
    final yourControl = state.districtControl[block.districtId] ?? 0.0;
    final insufficient = state.stk < totalCost;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Scrollable Content ──────────────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 240), // Large bottom padding for sticky bar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero Section ──────────────────────────────────────────
                GlassContainer(
                  padding: EdgeInsets.zero,
                  borderRadius: AppRadius.xl,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          // Property Image Placeholder
                          Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
                            ),
                            child: const Icon(Icons.business_rounded, color: AppColors.mutedForeground, size: 60),
                          ),
                          // Gradient Overlay
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.background, Colors.transparent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ),
                          // Yield Badge
                          Positioned(
                            top: 12, right: 12,
                            child: _Chip(
                              label: '${block.yieldPct}% yield',
                              color: AppColors.success,
                              icon: Icons.trending_up_rounded,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('PER UNIT', style: AppTextStyles.interSemiBold(10, color: AppColors.mutedForeground)),
                                    const SizedBox(height: 4),
                                    Text('${block.priceSTK} STK', style: AppTextStyles.orbitronBold(28, color: AppColors.cyan)),
                                    Text('≈ AED ${fmt.format(aedFromStk(block.priceSTK))}',
                                        style: AppTextStyles.interRegular(12, color: AppColors.mutedForeground)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('QUARTERLY EST.', style: AppTextStyles.interSemiBold(10, color: AppColors.mutedForeground)),
                                    const SizedBox(height: 4),
                                    Text('+${block.quarterlyEstSTK.toStringAsFixed(2)} STK',
                                        style: AppTextStyles.jetBrainsBold(16, color: AppColors.success)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Quick Stats Grid
                            Row(
                              children: [
                                Expanded(child: _StatBox(label: 'Occupancy', value: block.occupancy.name.toUpperCase())),
                                const SizedBox(width: 8),
                                Expanded(child: _StatBox(
                                  label: 'Risk', 
                                  value: block.risk.name.toUpperCase(),
                                  color: block.risk == Risk.low ? AppColors.success : block.risk == Risk.medium ? AppColors.gold : AppColors.magenta,
                                )),
                                const SizedBox(width: 8),
                                Expanded(child: _StatBox(label: 'Available', value: '${block.available}/${block.total}')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Performance Chart ─────────────────────────────────────
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: AppRadius.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Performance · 6m', style: AppTextStyles.interBold(14)),
                          Text('+12.4%', style: AppTextStyles.jetBrainsBold(12, color: AppColors.success)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 60,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: _ChartPainter(color: AppColors.cyan),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Territory Impact ──────────────────────────────────────
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: AppRadius.lg,
                  borderColor: AppColors.cyan.withOpacity(0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.business_rounded, size: 16, color: AppColors.cyan),
                          const SizedBox(width: 8),
                          Text('Territory impact', style: AppTextStyles.interBold(14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.interRegular(13, color: AppColors.mutedForeground),
                          children: [
                            TextSpan(text: 'Buying $_units unit${_units > 1 ? "s" : ""} adds '),
                            TextSpan(text: '+$territoryAdd%', style: AppTextStyles.jetBrainsBold(13, color: AppColors.cyan)),
                            TextSpan(text: ' to your '),
                            TextSpan(text: district.name, style: AppTextStyles.interBold(13, color: AppColors.foreground)),
                            const TextSpan(text: ' control. Current: '),
                            TextSpan(text: '${yourControl.toStringAsFixed(1)}%', style: AppTextStyles.jetBrainsMedium(13, color: AppColors.cyan)),
                            const TextSpan(text: ' → '),
                            TextSpan(text: '${(yourControl + double.parse(territoryAdd)).toStringAsFixed(1)}%', style: AppTextStyles.jetBrainsBold(13, color: AppColors.success)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Educational Card ──────────────────────────────────────
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: AppRadius.lg,
                  borderColor: AppColors.violet.withOpacity(0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.book_outlined, size: 16, color: AppColors.violet),
                          const SizedBox(width: 8),
                          Text("What's a REIT?", style: AppTextStyles.interBold(14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A Real Estate Investment Trust pools capital to own income-producing properties. You earn a slice of the rent — yield is the annualized return on your invested STK.',
                        style: AppTextStyles.interRegular(12, color: AppColors.mutedForeground),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Header (Overlay) ────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 20, right: 20, bottom: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.background, AppColors.background.withOpacity(0)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(block.name, style: AppTextStyles.orbitronBold(18)),
                        Text(block.district, style: AppTextStyles.interRegular(12, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                  _RarityChip(rarity: block.rarity),
                ],
              ),
            ),
          ),

          // ── Sticky Buy Bar ──────────────────────────────────────────────
          Positioned(
            bottom: 24, left: 20, right: 20,
            child: GlassContainer(
              padding: const EdgeInsets.all(20),
              borderRadius: AppRadius.xl,
              borderColor: AppColors.cyan.withOpacity(0.4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Acquire units', style: AppTextStyles.interBold(14)),
                      Row(
                        children: [
                          _UnitBtn(icon: Icons.remove, onTap: () => setState(() => _units = (_units > 1 ? _units - 1 : 1))),
                          const SizedBox(width: 12),
                          Text('$_units', style: AppTextStyles.jetBrainsBold(16)),
                          const SizedBox(width: 12),
                          _UnitBtn(icon: Icons.add, onTap: () => setState(() => _units = (_units < block.available ? _units + 1 : block.available))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: AppTextStyles.interRegular(13, color: AppColors.mutedForeground)),
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.jetBrainsBold(14, color: AppColors.cyan),
                          children: [
                            TextSpan(text: '$totalCost STK '),
                            TextSpan(text: '≈ AED ${fmt.format(aedFromStk(totalCost))}',
                                style: AppTextStyles.interRegular(11, color: AppColors.mutedForeground)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Wallet', style: AppTextStyles.interRegular(11, color: AppColors.mutedForeground)),
                      Text('${fmt.format(state.stk)} STK',
                          style: AppTextStyles.jetBrainsMedium(11, color: insufficient ? AppColors.magenta : AppColors.mutedForeground)),
                    ],
                  ),
                  if (insufficient && !_isSuccess) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.magenta),
                        const SizedBox(width: 6),
                        Text('Insufficient STK', style: AppTextStyles.interSemiBold(11, color: AppColors.magenta)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: (_isSuccess || insufficient || block.available == 0) ? null : _handleBuy,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: (_isSuccess || insufficient || block.available == 0) ? null : AppGradients.cyan,
                        color: (_isSuccess || insufficient || block.available == 0) ? AppColors.secondary : null,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: (_isSuccess || insufficient || block.available == 0) ? null : AppGlows.cyan,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isSuccess) const Icon(Icons.check_circle_outline_rounded, size: 20, color: Colors.white),
                          if (!_isSuccess) Icon(block.available == 0 ? Icons.lock_outline : Icons.auto_awesome_rounded, size: 18, color: AppColors.primaryForeground),
                          const SizedBox(width: 8),
                          Text(
                            _isSuccess ? 'Acquired!' : block.available == 0 ? 'Sold out' : 'Acquire Block',
                            style: AppTextStyles.orbitronBold(15, color: _isSuccess ? Colors.white : AppColors.primaryForeground),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBuy() {
    final result = ref.read(gameStateProvider.notifier).buyBlock(widget.id, _units);
    if (result.ok) {
      setState(() => _isSuccess = true);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) context.pop();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase failed: ${result.error}')),
      );
    }
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _StatBox({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.interSemiBold(9, color: AppColors.mutedForeground)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.orbitronBold(13, color: color ?? AppColors.foreground)),
        ],
      ),
    );
  }
}

class _UnitBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _UnitBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final Color color;
  _ChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.1, size.height * 0.75);
    path.lineTo(size.width * 0.2, size.height * 0.6);
    path.lineTo(size.width * 0.3, size.height * 0.65);
    path.lineTo(size.width * 0.4, size.height * 0.45);
    path.lineTo(size.width * 0.5, size.height * 0.5);
    path.lineTo(size.width * 0.6, size.height * 0.35);
    path.lineTo(size.width * 0.7, size.height * 0.4);
    path.lineTo(size.width * 0.8, size.height * 0.2);
    path.lineTo(size.width * 0.9, size.height * 0.25);
    path.lineTo(size.width, size.height * 0.1);

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.3), color.withOpacity(0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const _Chip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(label, style: AppTextStyles.jetBrainsBold(11, color: color)),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.5),
        border: Border.all(color: c.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(rarity.name.toUpperCase(), style: AppTextStyles.interBold(10, color: c)),
    );
  }
}
