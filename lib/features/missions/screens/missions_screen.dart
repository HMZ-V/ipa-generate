// ============================================================
// missions_screen.dart — Port of Missions.tsx
//
// Features:
//   - Level dashboard with XP progress & streak counter
//   - Daily/Weekly mission cards with progress bars
//   - "Claim" button logic for completed missions
//   - Achievement badge grid with gold neon borders
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../models/models.dart';
import '../../../providers/app_state.dart';
import '../../../providers/mock_data.dart';
import '../../../shared/widgets/glass_container.dart';

final List<Map<String, dynamic>> _achievements = [
  {"name": "First Block", "emoji": "🧱", "done": true},
  {"name": "District Lord", "emoji": "👑", "done": true},
  {"name": "Streak x30", "emoji": "🔥", "done": false},
  {"name": "Alliance MVP", "emoji": "🛡️", "done": true},
  {"name": "Token Whale", "emoji": "🐋", "done": false},
  {"name": "Skyline Master", "emoji": "🏙️", "done": false},
];

class MissionsScreen extends ConsumerWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameStateProvider);
    final daily = mockMissions.where((m) => m.kind == MissionKind.daily).toList();
    final weekly = mockMissions.where((m) => m.kind == MissionKind.weekly).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────────────────────
        Text('Missions & Rewards', style: AppTextStyles.orbitronBold(24)),
        const SizedBox(height: 4),
        Text('Earn STK, XP, and unlock districts',
            style: AppTextStyles.interRegular(13, color: AppColors.mutedForeground)),
        const SizedBox(height: 16),

        // ── Level & XP Card ───────────────────────────────────────────────
        GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: AppRadius.xl,
          borderColor: AppColors.cyan.withOpacity(0.5),
          child: Row(
            children: [
              // Level Badge
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  gradient: AppGradients.cyan,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppGlows.cyan,
                ),
                alignment: Alignment.center,
                child: Text('${seedUser.level}',
                    style: AppTextStyles.orbitronBold(24, color: AppColors.primaryForeground)),
              ),
              const SizedBox(width: 16),
              // XP Progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LEVEL ${seedUser.level}',
                        style: AppTextStyles.interSemiBold(11, color: AppColors.mutedForeground, letterSpacing: 1.0)),
                    const SizedBox(height: 2),
                    Text('${seedUser.xp} / ${seedUser.xpMax} XP',
                        style: AppTextStyles.jetBrainsBold(12)),
                    const SizedBox(height: 8),
                    // Progress Bar
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: seedUser.xp / seedUser.xpMax,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppGradients.cyan,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Streak
              Column(
                children: [
                  Text('${seedUser.streak}',
                      style: AppTextStyles.orbitronBold(24, color: AppColors.magenta)),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded, size: 12, color: AppColors.mutedForeground),
                      const SizedBox(width: 2),
                      Text('STREAK', style: AppTextStyles.interSemiBold(8, color: AppColors.mutedForeground)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Missions List ─────────────────────────────────────────────────
        _MissionSection(title: 'Daily missions', items: daily),
        const SizedBox(height: 24),
        _MissionSection(title: 'Weekly missions', items: weekly),
        const SizedBox(height: 24),

        // ── Achievements ──────────────────────────────────────────────────
        Row(
          children: [
            const Icon(Icons.workspace_premium_rounded, size: 20, color: AppColors.gold),
            const SizedBox(width: 8),
            Text('Achievements', style: AppTextStyles.orbitronBold(18)),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.85,
          ),
          itemCount: _achievements.length,
          itemBuilder: (context, i) {
            final a = _achievements[i];
            final done = a['done'] as bool;
            return GlassContainer(
              padding: const EdgeInsets.all(12),
              borderRadius: AppRadius.lg,
              borderColor: done ? AppColors.gold.withOpacity(0.5) : AppColors.border.withOpacity(0.3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(a['emoji'], style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: 4),
                  Text(a['name'],
                      textAlign: TextAlign.center,
                      style: AppTextStyles.interSemiBold(10,
                          color: done ? AppColors.foreground : AppColors.mutedForeground)),
                  if (done) ...[
                    const SizedBox(height: 8),
                    _MiniChip(label: 'Earned', color: AppColors.gold, icon: Icons.check_rounded),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

class _MissionSection extends StatelessWidget {
  final String title;
  final List<Mission> items;
  const _MissionSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.orbitronBold(18)),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final m = items[i];
            final done = m.isComplete;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: GlassContainer(
                padding: const EdgeInsets.all(12),
                borderRadius: AppRadius.lg,
                borderColor: done ? AppColors.cyan.withOpacity(0.4) : AppColors.border,
                child: Row(
                  children: [
                    // Icon
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: (done ? AppColors.success : AppColors.cyan).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(done ? Icons.check_rounded : Icons.emoji_events_rounded,
                          size: 20, color: done ? AppColors.success : AppColors.cyan),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(m.title, style: AppTextStyles.interSemiBold(14)),
                              Text('${m.progress}/${m.total}',
                                  style: AppTextStyles.jetBrainsMedium(11, color: AppColors.mutedForeground)),
                            ],
                          ),
                          const SizedBox(height: 6),
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
                              widthFactor: m.progressFraction,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: AppGradients.cyan,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text('+${m.xpReward} XP · +${m.stkReward} STK',
                              style: AppTextStyles.interSemiBold(11, color: AppColors.gold)),
                        ],
                      ),
                    ),
                    // Claim Button
                    if (done) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: AppGradients.cyan,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppGlows.cyan,
                        ),
                        child: Text('Claim',
                            style: AppTextStyles.interBold(12, color: AppColors.primaryForeground)),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _MiniChip({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(label, style: AppTextStyles.interBold(8, color: color)),
        ],
      ),
    );
  }
}
