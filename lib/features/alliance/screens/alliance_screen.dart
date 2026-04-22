// ============================================================
// alliance_screen.dart — Port of Alliance.tsx
//
// Features:
//   - Alliance overview with rank and treasury stats
//   - Tab-based navigation (Leaderboard, Events, Chat)
//   - Dynamic alliance leaderboard & contributor list
//   - Time-limited alliance events with rewards
//   - Mocked chat interface for social coordination
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme.dart';
import '../../../models/models.dart';
import '../../../providers/mock_data.dart';
import '../../../shared/widgets/glass_container.dart';

final List<Map<String, dynamic>> _events = [
  {
    "id": 1,
    "name": "Capture the Block",
    "desc": "Take 5 contested parcels",
    "reward": "+500 STK",
    "time": "Ends 2d",
    "color": AppColors.magenta
  },
  {
    "id": 2,
    "name": "Yield Rush",
    "desc": "Pool 10K STK in dividends",
    "reward": "+1,200 STK",
    "time": "Ends 5d",
    "color": AppColors.gold
  },
  {
    "id": 3,
    "name": "District Wars",
    "desc": "Hold Marina vs Harbor Lords",
    "reward": "Trophy + 2K STK",
    "time": "Live",
    "color": AppColors.cyan
  },
];

final List<Map<String, dynamic>> _chat = [
  {"who": "Layla A.", "msg": "Pushing into Downtown now. Need 4 more blocks.", "time": "2m"},
  {"who": "Omar K.", "msg": "I'll cover Marina defense.", "time": "5m"},
  {"who": "You", "msg": "On it. Got 8 STK ready.", "time": "6m", "you": true},
  {"who": "Hessa S.", "msg": "Atlas just bought Burj 7C 😬", "time": "12m"},
];

class AllianceScreen extends ConsumerStatefulWidget {
  const AllianceScreen({super.key});

  @override
  ConsumerState<AllianceScreen> createState() => _AllianceScreenState();
}

class _AllianceScreenState extends ConsumerState<AllianceScreen> {
  int _tabIndex = 0; // 0: Board, 1: Events, 2: Chat

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────────────────────
        Text('Alliance', style: AppTextStyles.orbitronBold(24)),
        const SizedBox(height: 16),

        // ── Alliance Profile ──────────────────────────────────────────────
        GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: AppRadius.xl,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      gradient: AppGradients.violet,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(mockAlliance.tag,
                        style: AppTextStyles.orbitronBold(20, color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mockAlliance.name, style: AppTextStyles.orbitronBold(18)),
                        Text('"${mockAlliance.motto}"',
                            style: AppTextStyles.interRegular(11,
                                color: AppColors.mutedForeground, fontStyle: FontStyle.italic)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _MiniChip(
                                label: 'Rank #${mockAlliance.rank}',
                                color: AppColors.magenta),
                            const SizedBox(width: 8),
                            Text('+${mockAlliance.rankDelta} this week',
                                style: AppTextStyles.interSemiBold(11, color: AppColors.success)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _StatBox(label: 'Season Pts', value: mockAlliance.seasonPts),
                  const SizedBox(width: 8),
                  _StatBox(label: 'Members', value: '${mockAlliance.members}/${mockAlliance.maxMembers}'),
                  const SizedBox(width: 8),
                  _StatBox(label: 'Treasury', value: '${mockAlliance.treasury} STK'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Tab Switcher ──────────────────────────────────────────────────
        Row(
          children: [
            _TabBtn(label: 'Leaderboard', isSel: _tabIndex == 0, onTap: () => setState(() => _tabIndex = 0)),
            const SizedBox(width: 8),
            _TabBtn(label: 'Events', isSel: _tabIndex == 1, onTap: () => setState(() => _tabIndex = 1)),
            const SizedBox(width: 8),
            _TabBtn(label: 'Chat', isSel: _tabIndex == 2, onTap: () => setState(() => _tabIndex = 2)),
          ],
        ),
        const SizedBox(height: 16),

        // ── Tab Content ───────────────────────────────────────────────────
        if (_tabIndex == 0) ..._buildBoard(),
        if (_tabIndex == 1) ..._buildEvents(),
        if (_tabIndex == 2) ..._buildChat(),

        const SizedBox(height: 100),
      ],
    );
  }

  List<Widget> _buildBoard() {
    return [
      Text('SEASON 4 — TOP ALLIANCES',
          style: AppTextStyles.interSemiBold(11, color: AppColors.mutedForeground, letterSpacing: 1.0)),
      const SizedBox(height: 12),
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: mockLeaderboard.length,
        itemBuilder: (context, i) {
          final a = mockLeaderboard[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: GlassContainer(
              padding: const EdgeInsets.all(12),
              borderRadius: AppRadius.lg,
              borderColor: a.isYou ? AppColors.cyan.withOpacity(0.5) : AppColors.border,
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: a.rank == 1 ? AppColors.gold : AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: a.rank == 1
                        ? const Icon(Icons.workspace_premium_rounded, size: 18, color: AppColors.primaryForeground)
                        : Text('#${a.rank}', style: AppTextStyles.orbitronBold(12, color: AppColors.mutedForeground)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.name, style: AppTextStyles.interBold(14)),
                        Text('${a.pts} pts', style: AppTextStyles.jetBrainsMedium(11, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                  Text(a.delta > 0 ? '+${a.delta}' : '${a.delta}',
                      style: AppTextStyles.jetBrainsBold(12, color: a.delta > 0 ? AppColors.success : a.delta < 0 ? AppColors.magenta : AppColors.mutedForeground)),
                ],
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 16),
      Text('TOP CONTRIBUTORS',
          style: AppTextStyles.interSemiBold(11, color: AppColors.mutedForeground, letterSpacing: 1.0)),
      const SizedBox(height: 12),
      GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: AppRadius.lg,
        child: Column(
          children: [
            for (int i = 0; i < mockAlliance.topMembers.length; i++) ...[
              _MemberRow(member: mockAlliance.topMembers[i]),
              if (i < mockAlliance.topMembers.length - 1)
                Divider(height: 1, color: AppColors.border.withOpacity(0.6)),
            ],
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildEvents() {
    return [
      for (final e in _events)
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: AppRadius.xl,
            borderColor: (e['color'] as Color).withOpacity(0.3),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: (e['color'] as Color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.sports_kabaddi_rounded, size: 18, color: e['color']),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e['name'], style: AppTextStyles.interBold(15)),
                          Text(e['desc'], style: AppTextStyles.interRegular(11, color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                    _MiniChip(label: e['time'], color: e['color']),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MiniChip(label: '🏆 ${e['reward']}', color: AppColors.gold),
                    Text('Join →', style: AppTextStyles.interBold(13, color: AppColors.cyan)),
                  ],
                ),
              ],
            ),
          ),
        ),
    ];
  }

  List<Widget> _buildChat() {
    return [
      GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: AppRadius.xl,
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.cyan),
                const SizedBox(width: 8),
                Text('Alliance feed', style: AppTextStyles.interBold(14)),
              ],
            ),
            const Divider(height: 24),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: _chat.length,
                itemBuilder: (context, i) {
                  final c = _chat[i];
                  final isYou = c['you'] == true;
                  return Align(
                    alignment: isYou ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isYou ? AppColors.cyan.withOpacity(0.15) : AppColors.secondary.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: isYou ? Border.all(color: AppColors.cyan.withOpacity(0.3)) : null,
                      ),
                      child: Column(
                        crossAxisAlignment: isYou ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (!isYou)
                            Text(c['who'], style: AppTextStyles.interBold(10, color: AppColors.cyan)),
                          Text(c['msg'], style: AppTextStyles.interRegular(14)),
                          const SizedBox(height: 4),
                          Text(c['time'], style: AppTextStyles.interRegular(9, color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Rally the alliance...',
                        style: AppTextStyles.interRegular(13, color: AppColors.mutedForeground)),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: AppGradients.cyan,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.send_rounded, size: 18, color: AppColors.primaryForeground),
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _TabBtn extends StatelessWidget {
  final String label;
  final bool isSel;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.isSel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSel ? AppColors.cyan.withOpacity(0.15) : AppColors.secondary.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: isSel ? Border.all(color: AppColors.cyan.withOpacity(0.5)) : null,
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: AppTextStyles.interBold(13, color: isSel ? AppColors.cyan : AppColors.mutedForeground)),
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final AllianceMember member;
  const _MemberRow({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: member.isYou ? AppColors.cyan.withOpacity(0.05) : null,
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: member.rank == 1 ? AppColors.gold : AppColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text('${member.rank}',
                style: AppTextStyles.interBold(12, color: member.rank == 1 ? AppColors.primaryForeground : AppColors.mutedForeground)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: AppTextStyles.interSemiBold(14)),
                Text('Rank #${member.rank}',
                    style: AppTextStyles.interRegular(10, color: AppColors.mutedForeground)),
              ],
            ),
          ),
          Text(member.pts.toString(),
              style: AppTextStyles.jetBrainsBold(14, color: AppColors.cyan)),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final dynamic value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.secondary.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('$value', style: AppTextStyles.jetBrainsBold(13)),
            Text(label.toUpperCase(),
                style: AppTextStyles.interSemiBold(8, color: AppColors.mutedForeground)),
          ],
        ),
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
