// ============================================================
// real_mode_screen.dart — Port of RealMode.tsx
//
// Features:
//   - 2-step KYC/Verification onboarding flow (Gold themed)
//   - Real portfolio dashboard with Net Asset Value (NAV)
//   - Segmented asset allocation bar
//   - Projected returns & income grid
//   - Educational prototype disclaimers
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';
import '../../../shared/widgets/glass_container.dart';

final List<Map<String, dynamic>> _allocation = [
  {"name": "Commercial Office", "pct": 38, "color": AppColors.cyan},
  {"name": "Hospitality", "pct": 24, "color": AppColors.magenta},
  {"name": "Residential", "pct": 22, "color": AppColors.gold},
  {"name": "Land Bank", "pct": 16, "color": AppColors.violet},
];

class RealModeScreen extends ConsumerStatefulWidget {
  const RealModeScreen({super.key});

  @override
  ConsumerState<RealModeScreen> createState() => _RealModeScreenState();
}

class _RealModeScreenState extends ConsumerState<RealModeScreen> {
  int _step = 0; // 0: Risk, 1: KYC, 2: Portfolio

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_step < 2 ? 'Real Investing' : 'Real Portfolio', style: AppTextStyles.orbitronBold(24)),
                const SizedBox(height: 4),
                Text(_step < 2 ? '18+ educational prototype' : 'REIT-equivalent exposure',
                    style: AppTextStyles.interRegular(13, color: AppColors.mutedForeground)),
              ],
            ),
            _Chip(label: _step < 2 ? 'REAL' : 'REAL · LIVE', color: AppColors.gold),
          ],
        ),
        const SizedBox(height: 16),

        // ── Conditional View ──────────────────────────────────────────────
        if (_step < 2) _buildOnboarding() else _buildPortfolio(),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildOnboarding() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: AppRadius.xl,
      borderColor: AppColors.gold.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.verified_user_rounded, size: 24, color: AppColors.gold),
          ),
          const SizedBox(height: 16),
          Text('Step ${_step + 1} / 2 · ${_step == 0 ? "Eligibility & risk" : "KYC verification"}',
              style: AppTextStyles.orbitronBold(18)),
          const SizedBox(height: 8),
          Text(
            _step == 0
                ? "Real Investing connects your STK exposure to REIT-equivalent units. Returns are not guaranteed and your capital is at risk."
                : "Provide ID and proof-of-address. This is a prototype — no data is collected. Tap continue to simulate.",
            style: AppTextStyles.interRegular(14, color: AppColors.mutedForeground),
          ),
          if (_step == 0) ...[
            const SizedBox(height: 20),
            _Bullet(label: '18+ residency required'),
            _Bullet(label: 'Past performance ≠ future returns'),
            _Bullet(label: 'Minimum holding 90 days'),
          ],
          if (_step == 1) ...[
            const SizedBox(height: 20),
            _MockInput(hint: 'Emirates ID number'),
            const SizedBox(height: 8),
            _MockInput(hint: 'Full legal name'),
            const SizedBox(height: 8),
            _MockInput(hint: 'Address'),
          ],
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => setState(() => _step++),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppGradients.gold,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                _step == 0 ? 'I understand · Continue' : 'Submit & unlock',
                style: AppTextStyles.orbitronBold(15, color: AppColors.primaryForeground),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text('This is an educational prototype. Not live brokerage.',
                style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolio() {
    return Column(
      children: [
        // NAV Card
        GlassContainer(
          padding: const EdgeInsets.all(24),
          borderRadius: AppRadius.xl,
          borderColor: AppColors.gold.withOpacity(0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NET ASSET VALUE',
                  style: AppTextStyles.interSemiBold(10, color: AppColors.mutedForeground, letterSpacing: 1.0)),
              const SizedBox(height: 8),
              Text('AED 12,840.00', style: AppTextStyles.orbitronBold(32, color: Colors.white)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.trending_up_rounded, size: 16, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text('+AED 312.50 pending payout · 6 May',
                      style: AppTextStyles.interSemiBold(12, color: AppColors.success)),
                ],
              ),
              const SizedBox(height: 24),
              Text('ALLOCATION',
                  style: AppTextStyles.interSemiBold(10, color: AppColors.mutedForeground, letterSpacing: 1.0)),
              const SizedBox(height: 8),
              // Allocation Bar
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: _allocation.map((a) {
                      return Expanded(
                        flex: a['pct'],
                        child: Container(color: a['color']),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 6,
                children: _allocation.map((a) {
                  return Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: a['color'], shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(a['name'], style: AppTextStyles.interRegular(10)),
                      const Spacer(),
                      Text('${a['pct']}%', style: AppTextStyles.jetBrainsMedium(10, color: AppColors.mutedForeground)),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Stats Box
        GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: AppRadius.lg,
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.assignment_turned_in_outlined, size: 16, color: AppColors.cyan),
                  const SizedBox(width: 8),
                  Text('Projected returns · 12mo', style: AppTextStyles.interBold(13)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _RealStat(label: 'Yield', value: '+6.4%', color: AppColors.success),
                  _RealStat(label: 'Income', value: 'AED 821'),
                  _RealStat(label: 'Payouts', value: 'Q', color: AppColors.cyan),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Prototype Disclaimer
        GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: AppRadius.lg,
          borderColor: AppColors.gold.withOpacity(0.3),
          child: Row(
            children: [
              const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.gold),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Educational prototype. Not live brokerage. Sample data only.',
                    style: AppTextStyles.interRegular(11, color: AppColors.mutedForeground)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _Bullet extends StatelessWidget {
  final String label;
  const _Bullet({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.gold),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.interRegular(13, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}

class _MockInput extends StatelessWidget {
  final String hint;
  const _MockInput({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(hint, style: AppTextStyles.interRegular(13, color: AppColors.mutedForeground)),
    );
  }
}

class _RealStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _RealStat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.orbitronBold(18, color: color ?? AppColors.foreground)),
        const SizedBox(height: 2),
        Text(label.toUpperCase(), style: AppTextStyles.interSemiBold(8, color: AppColors.mutedForeground)),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: AppTextStyles.interBold(10, color: color)),
    );
  }
}
