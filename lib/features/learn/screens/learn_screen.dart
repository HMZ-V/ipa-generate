import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../providers/app_state.dart';
import '../../../providers/mock_data.dart';
import '../../../shared/widgets/glass_container.dart';

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameStateProvider);
    final fmt = NumberFormat('#,###');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────────────────────
        Text('Learning Simulator', style: AppTextStyles.orbitronBold(22)),
        const SizedBox(height: 4),
        Text(
          'For youth 14-17. Invest virtual funds, mirror real markets, zero risk.',
          style: AppTextStyles.interRegular(12, color: AppColors.mutedForeground),
        ),
        const SizedBox(height: 20),

        // ── Sim Mode Active Banner ────────────────────────────────────────
        GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: AppRadius.xl,
          borderColor: AppColors.cyan.withOpacity(0.3),
          gradient: LinearGradient(
            colors: [AppColors.cyan.withOpacity(0.1), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (context, _) => Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.cyan,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.cyan.withOpacity(0.5),
                                  blurRadius: 4 + (_pulseCtrl.value * 6),
                                  spreadRadius: _pulseCtrl.value * 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'SIM MODE ACTIVE',
                          style: AppTextStyles.interBold(12, color: AppColors.cyan),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real market data. Virtual money.',
                      style: AppTextStyles.interRegular(11, color: AppColors.cyan.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cyan.withOpacity(0.4)),
                ),
                child: const Icon(Icons.trending_up_rounded, color: AppColors.cyan, size: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── Virtual Portfolio Card ────────────────────────────────────────
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_rounded, size: 14, color: AppColors.mutedForeground),
                  const SizedBox(width: 8),
                  Text(
                    'YOUR VIRTUAL PORTFOLIO',
                    style: AppTextStyles.interBold(10, color: AppColors.mutedForeground),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL VALUE',
                        style: AppTextStyles.interBold(9, color: AppColors.mutedForeground),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('AED ', style: AppTextStyles.orbitronBold(14)),
                          Text(fmt.format(state.portfolioValueAED), style: AppTextStyles.jetBrainsBold(28)),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.success.withOpacity(0.3)),
                        ),
                        child: Text(
                          '+${state.stk > 10000 ? "4,240" : "1,240"} (1.2%)',
                          style: AppTextStyles.interBold(11, color: AppColors.success),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Today's PnL",
                        style: AppTextStyles.interRegular(10, color: AppColors.mutedForeground),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SimButton(
                      label: 'Trade Now',
                      icon: Icons.swap_vert_rounded,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SimButton(
                      label: 'View Assets',
                      icon: Icons.arrow_forward_rounded,
                      isPrimary: true,
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── AI Market Assistant ───────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.magenta.withOpacity(0.2)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: GlassContainer(
              padding: const EdgeInsets.all(4),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.magenta.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.magenta.withOpacity(0.3)),
                          ),
                          child: const Icon(Icons.smart_toy_rounded, color: AppColors.magenta, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('AI Market Assistant', style: AppTextStyles.orbitronBold(14)),
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome_rounded, size: 10, color: AppColors.magenta),
                                const SizedBox(width: 4),
                                Text(
                                  'Live Analysis Active',
                                  style: AppTextStyles.interBold(10, color: AppColors.magenta.withOpacity(0.8)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.interMedium(13, color: AppColors.foreground.withOpacity(0.9)),
                          children: [
                            const TextSpan(text: '"Marina Bay units are currently undervalued by '),
                            TextSpan(
                              text: '12%',
                              style: AppTextStyles.interBold(13, color: AppColors.success),
                            ),
                            const TextSpan(text: ' based on recent rental yield data. I suggest allocating 15% of your virtual portfolio here."'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Ask AI Assistant',
                          style: AppTextStyles.interBold(12, color: AppColors.magenta),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ── Learning Missions ─────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Learn & Earn STK', style: AppTextStyles.orbitronBold(18)),
            Text(
              '${mockLessons.where((l) => l.isDone).length}/${mockLessons.length} Done',
              style: AppTextStyles.interSemiBold(12, color: AppColors.mutedForeground),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Dynamic Lesson List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mockLessons.length,
          itemBuilder: (context, index) {
            final lesson = mockLessons[index];
            final prevDone = index == 0 || mockLessons[index - 1].isDone;
            final isLocked = !lesson.isDone && !prevDone;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LessonItem(
                title: lesson.title,
                reward: lesson.unlocks,
                emoji: lesson.emoji,
                isDone: lesson.isDone,
                isLocked: isLocked,
              ),
            );
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _SimButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onPressed;

  const _SimButton({
    required this.label,
    required this.icon,
    this.isPrimary = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          gradient: isPrimary ? AppGradients.cyan : null,
          color: isPrimary ? null : AppColors.secondary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary ? AppColors.cyan.withOpacity(0.4) : Colors.white.withOpacity(0.05),
          ),
          boxShadow: isPrimary ? [
            BoxShadow(
              color: AppColors.cyan.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 4),
            )
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isPrimary) Icon(icon, size: 16, color: AppColors.foreground),
            if (!isPrimary) const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.interBold(12, 
                color: isPrimary ? AppColors.background : AppColors.foreground),
            ),
            if (isPrimary) const SizedBox(width: 8),
            if (isPrimary) Icon(icon, size: 16, color: AppColors.background),
          ],
        ),
      ),
    );
  }
}

class _LessonItem extends StatelessWidget {
  final String title;
  final String reward;
  final String emoji;
  final bool isDone;
  final bool isLocked;

  const _LessonItem({
    required this.title,
    required this.reward,
    required this.emoji,
    this.isDone = false,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isLocked ? 0.5 : 1.0,
      child: GlassContainer(
        padding: const EdgeInsets.all(14),
        borderRadius: AppRadius.lg,
        hoverable: !isLocked,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDone 
                  ? AppColors.success.withOpacity(0.1) 
                  : AppColors.violet.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDone 
                    ? AppColors.success.withOpacity(0.3) 
                    : AppColors.violet.withOpacity(0.3),
                ),
              ),
              alignment: Alignment.center,
              child: isDone 
                ? const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 24)
                : Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.interBold(14)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 12, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Text(
                        'Reward: ',
                        style: AppTextStyles.interRegular(11, color: AppColors.mutedForeground),
                      ),
                      Text(
                        reward == '—' ? 'XP Boost' : reward,
                        style: AppTextStyles.interBold(11, color: AppColors.gold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isLocked)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_rounded, size: 14, color: AppColors.mutedForeground),
              )
            else
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDone 
                    ? AppColors.secondary 
                    : AppColors.violet.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded, 
                  size: 20, 
                  color: isDone ? AppColors.mutedForeground : AppColors.violet
                ),
              ),
          ],
        ),
      ),
    );
  }
}
