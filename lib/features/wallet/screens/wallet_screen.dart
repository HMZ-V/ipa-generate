// ============================================================
// wallet_screen.dart — Port of Wallet.tsx
//
// Features:
//   - Neon STK balance card with count-up animation
//   - Earn stat grid (Missions, Streak, Refer)
//   - Gold-themed Staking module with APY & status
//   - Detailed transaction list with signed STK pills
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';
import '../../../models/models.dart';
import '../../../providers/app_state.dart';
import '../../../providers/mock_data.dart';
import '../../../shared/widgets/glass_container.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _countCtrl;
  late Animation<double> _countAnim;

  @override
  void initState() {
    super.initState();
    final stk = ref.read(gameStateProvider).stk.toDouble();
    
    _countCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _countAnim = Tween<double>(begin: 0, end: stk).animate(
      CurvedAnimation(parent: _countCtrl, curve: Curves.easeOutCubic),
    );
    _countCtrl.forward();
  }

  @override
  void dispose() {
    _countCtrl.dispose();
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
        Text('STK Wallet', style: AppTextStyles.orbitronBold(24)),
        const SizedBox(height: 4),
        Text("StackUp's native token",
            style: AppTextStyles.interRegular(13, color: AppColors.mutedForeground)),
        const SizedBox(height: 16),

        // ── Balance Card ──────────────────────────────────────────────────
        GlassContainer(
          padding: const EdgeInsets.all(20),
          borderRadius: AppRadius.xl,
          borderColor: AppColors.cyan.withOpacity(0.5),
          child: Stack(
            children: [
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
                  Text('BALANCE',
                      style: AppTextStyles.interSemiBold(10,
                          color: AppColors.mutedForeground)),
                  const SizedBox(height: 4),
                  AnimatedBuilder(
                    animation: _countAnim,
                    builder: (context, _) => RichText(
                      text: TextSpan(
                        style: AppTextStyles.orbitronBold(36, color: AppColors.cyan),
                        children: [
                          TextSpan(text: fmt.format(_countAnim.value.round())),
                          const TextSpan(text: ' '),
                          TextSpan(text: 'STK', style: AppTextStyles.interRegular(16, color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '≈ AED ${fmt.format(aedFromStk(state.stk))} · 1 STK = AED 3.67',
                    style: AppTextStyles.interRegular(13, color: AppColors.mutedForeground),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionBtn(
                          label: 'Buy STK',
                          icon: Icons.south_west_rounded,
                          gradient: AppGradients.cyan,
                          textColor: AppColors.primaryForeground,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ActionBtn(
                          label: 'Send',
                          icon: Icons.north_east_rounded,
                          color: AppColors.secondary,
                          borderColor: AppColors.border,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Earn Stats ────────────────────────────────────────────────────
        Row(
          children: [
            _EarnStat(label: 'Missions', value: '+24/d', icon: Icons.auto_awesome_rounded, color: AppColors.violet),
            const SizedBox(width: 8),
            _EarnStat(label: 'Streak', value: '${seedUser.streak}d', icon: Icons.local_fire_department_rounded, color: AppColors.magenta),
            const SizedBox(width: 8),
            _EarnStat(label: 'Refer', value: '+50', icon: Icons.monetization_on_rounded, color: AppColors.gold),
          ],
        ),
        const SizedBox(height: 16),

        // ── Staking Module ────────────────────────────────────────────────
        GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: AppRadius.xl,
          borderColor: AppColors.gold.withOpacity(0.3),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.lock_rounded, size: 18, color: AppColors.gold),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('STK Staking', style: AppTextStyles.interBold(15)),
                        Text('Earn passive yield on idle tokens',
                            style: AppTextStyles.interRegular(11, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                  _Chip(label: '8.4% APY', color: AppColors.gold, fontMono: true),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _StakeSubBox(label: 'Staked', value: '${seedUser.staked} STK')),
                  const SizedBox(width: 8),
                  Expanded(child: _StakeSubBox(label: 'Earned', value: '+34.6 STK', valueColor: AppColors.success)),
                ],
              ),
              const SizedBox(height: 12),
              _ActionBtn(
                label: 'Stake more STK',
                gradient: AppGradients.gold,
                textColor: AppColors.primaryForeground,
                width: double.infinity,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Transactions Header ───────────────────────────────────────────
        Text('Transactions', style: AppTextStyles.orbitronBold(18)),
        const SizedBox(height: 12),

        // ── Transaction List ──────────────────────────────────────────────
        GlassContainer(
          padding: EdgeInsets.zero,
          borderRadius: AppRadius.lg,
          child: Column(
            children: [
              for (int i = 0; i < mockTransactions.length; i++) ...[
                _TransactionRow(tx: mockTransactions[i]),
                if (i < mockTransactions.length - 1)
                  Divider(height: 1, color: AppColors.border.withOpacity(0.6)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final LinearGradient? gradient;
  final Color? color;
  final Color? borderColor;
  final Color? textColor;
  final double? width;

  const _ActionBtn({
    required this.label,
    this.icon,
    this.gradient,
    this.color,
    this.borderColor,
    this.textColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: gradient,
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(label,
              style: AppTextStyles.interBold(14, color: textColor ?? AppColors.foreground)),
        ],
      ),
    );
  }
}

class _EarnStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _EarnStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 12),
        borderRadius: AppRadius.lg,
        child: Column(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.jetBrainsBold(14)),
            Text(label.toUpperCase(),
                style: AppTextStyles.interSemiBold(8, color: AppColors.mutedForeground)),
          ],
        ),
      ),
    );
  }
}

class _StakeSubBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StakeSubBox({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppTextStyles.interSemiBold(9, color: AppColors.mutedForeground)),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.jetBrainsBold(14, color: valueColor ?? AppColors.foreground)),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final Transaction tx;
  const _TransactionRow({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isPos = tx.stk >= 0;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: (isPos ? AppColors.success : AppColors.magenta).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              isPos ? Icons.south_west_rounded : Icons.north_east_rounded,
              size: 16,
              color: isPos ? AppColors.success : AppColors.magenta,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.label,
                    style: AppTextStyles.interSemiBold(14),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(tx.time,
                    style: AppTextStyles.interRegular(11, color: AppColors.mutedForeground)),
              ],
            ),
          ),
          _StkPill(amount: tx.stk),
        ],
      ),
    );
  }
}

class _StkPill extends StatelessWidget {
  final double amount;
  const _StkPill({required this.amount});

  @override
  Widget build(BuildContext context) {
    final isPos = amount >= 0;
    final color = isPos ? AppColors.success : AppColors.foreground;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '${isPos ? '+' : ''}${amount.toStringAsFixed(1)} STK',
        style: AppTextStyles.jetBrainsBold(11, color: color),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final bool fontMono;
  const _Chip({required this.label, required this.color, this.fontMono = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
