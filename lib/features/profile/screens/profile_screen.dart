// ============================================================
// profile_screen.dart — Port of Profile.tsx
//
// Features:
//   - Identity card with floating avatar and neon borders
//   - Portfolio summary stats grid
//   - Gold-themed "Real Mode" transition CTA
//   - Settings list with integrated logout/danger actions
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';
import '../../../models/models.dart';
import '../../../providers/mock_data.dart';
import '../../../shared/widgets/glass_container.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────────────────────
        Text('Profile', style: AppTextStyles.orbitronBold(24)),
        const SizedBox(height: 4),
        Text('Your StackUp identity',
            style: AppTextStyles.interRegular(13, color: AppColors.mutedForeground)),
        const SizedBox(height: 16),

        // ── Identity Card ─────────────────────────────────────────────────
        GlassContainer(
          padding: const EdgeInsets.all(24),
          borderRadius: AppRadius.xl,
          borderColor: AppColors.cyan.withOpacity(0.5),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: AppGradients.cyan,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppGlows.cyan,
                ),
                alignment: Alignment.center,
                child: Text(seedUser.name[0],
                    style: AppTextStyles.orbitronBold(32, color: AppColors.primaryForeground)),
              ),
              const SizedBox(height: 16),
              Text(seedUser.name, style: AppTextStyles.orbitronBold(20)),
              const SizedBox(height: 4),
              Text(
                '${seedUser.username} · Lvl ${seedUser.level} · Rank #${seedUser.rank}',
                style: AppTextStyles.interRegular(12, color: AppColors.mutedForeground),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Chip(label: mockAlliance.name, color: AppColors.violet),
                  const SizedBox(width: 8),
                  const _Chip(label: 'SIM MODE', color: AppColors.cyan),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Stats Grid ────────────────────────────────────────────────────
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.8,
          children: [
            _StatCard(label: 'Blocks', value: seedUser.ownedBlocksCount.toString()),
            _StatCard(label: 'Districts', value: seedUser.districtsControlled.toString()),
            _StatCard(label: 'STK Staked', value: seedUser.staked.toString()),
            const _StatCard(label: 'Lessons', value: '3'),
          ],
        ),
        const SizedBox(height: 16),

        // ── Real Mode CTA ─────────────────────────────────────────────────
        GestureDetector(
          onTap: () => context.push('/app/real'),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: AppRadius.xl,
            borderColor: AppColors.gold.withOpacity(0.3),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text('\$',
                      style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Switch to Real Mode', style: AppTextStyles.interBold(14)),
                      Text('Connect to REIT-equivalent exposure',
                          style: AppTextStyles.interRegular(11, color: AppColors.mutedForeground)),
                    ],
                  ),
                ),
                const _Chip(label: '18+', color: AppColors.gold),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Settings List ─────────────────────────────────────────────────
        GlassContainer(
          padding: EdgeInsets.zero,
          borderRadius: AppRadius.xl,
          child: Column(
            children: [
              _SettingRow(icon: Icons.shield_outlined, label: 'Security & PIN'),
              _SettingRow(icon: Icons.fingerprint_rounded, label: 'Biometric login'),
              _SettingRow(icon: Icons.lock_outline_rounded, label: 'Privacy controls'),
              _SettingRow(icon: Icons.dark_mode_outlined, label: 'Appearance · Dark'),
              _SettingRow(icon: Icons.settings_outlined, label: 'Settings'),
              _SettingRow(
                icon: Icons.logout_rounded,
                label: 'Sign out',
                isDanger: true,
                onTap: () {
                  // TODO: Logout logic
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: AppRadius.lg,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: AppTextStyles.orbitronBold(20, color: AppColors.cyan)),
          Text(label.toUpperCase(),
              style: AppTextStyles.interSemiBold(8, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDanger;
  final VoidCallback? onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    this.isDanger = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border.withOpacity(0.3), width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: isDanger ? AppColors.magenta.withOpacity(0.12) : AppColors.secondary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 18, color: isDanger ? AppColors.magenta : AppColors.cyan),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: AppTextStyles.interSemiBold(14, color: isDanger ? AppColors.magenta : AppColors.foreground)),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.mutedForeground),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: AppTextStyles.interBold(10, color: color)),
    );
  }
}
