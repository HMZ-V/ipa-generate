// ============================================================
// onboarding_screen.dart — Full port of Onboarding.tsx
//
// Step 0 — Hero splash: headline + "Get started" CTA
// Step 1 — Age gate: Under 18 (sim) / 18+ (full)
// Step 2 — Goal picker: Learn / Play / Invest
// Step 3 — Wallet ready: burst animation + "Enter the city"
//
// All transitions: fade + slide-up (matches animate-fade-up CSS).
// ============================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme.dart';
import '../../../shared/widgets/glass_container.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _AgeOption {
  final String key;
  final String label;
  final String description;
  final String emoji;
  final Color accentColor;
  const _AgeOption(this.key, this.label, this.description, this.emoji, this.accentColor);
}

class _GoalOption {
  final String key;
  final String label;
  final String description;
  final IconData icon;
  final Color accentColor;
  const _GoalOption(this.key, this.label, this.description, this.icon, this.accentColor);
}

const _ageOptions = [
  _AgeOption('under18', 'Under 18', 'Simulation Mode · play & learn', '🧒', AppColors.cyan),
  _AgeOption('adult', '18 or older', 'Full access · sim + real investing', '🧑', AppColors.gold),
];

const _goalOptions = [
  _GoalOption('learn', 'Learn', 'Investing basics, REITs, crypto', Icons.school_rounded, AppColors.violet),
  _GoalOption('play', 'Play', 'Compete for territory & status', Icons.sports_esports_rounded, AppColors.magenta),
  _GoalOption('invest', 'Invest', 'Build long-term real returns', Icons.trending_up_rounded, AppColors.gold),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int _step = 0;
  String? _age;
  String? _goal;

  // Transition animation controller — re-runs on each step change
  late AnimationController _transCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Burst / glow pulse on step 3
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    _transCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _transCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _transCtrl, curve: Curves.easeOut));

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _transCtrl.forward();
  }

  @override
  void dispose() {
    _transCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _goStep(int step) {
    _transCtrl.reverse().then((_) {
      setState(() => _step = step);
      _transCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Hero image backdrop ─────────────────────────────────────────
          Image.asset(
            'assets/hero-skyline.jpg',
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation(0.4),
          ),

          // Gradient overlay to ensure text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background.withOpacity(0.3),
                  AppColors.background.withOpacity(0.7),
                  AppColors.background,
                ],
              ),
            ),
          ),

          // Cyan city grid shimmer overlay
          Opacity(
            opacity: 0.06,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.5),
                  radius: 1.2,
                  colors: [AppColors.cyan, Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Content ────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Logo row
                  Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          gradient: AppGradients.cyan,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text('\$',
                          style: AppTextStyles.orbitronBold(18,
                              color: AppColors.primaryForeground)),
                      ),
                      const SizedBox(width: 10),
                      Text('StackUp',
                        style: AppTextStyles.orbitronBold(18)),
                    ],
                  ),

                  // Animated step content
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: _buildStep(),
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

  // ── Step router ───────────────────────────────────────────────────────────

  Widget _buildStep() {
    switch (_step) {
      case 0:  return _buildStep0();
      case 1:  return _buildStep1();
      case 2:  return _buildStep2();
      case 3:  return _buildStep3();
      default: return const SizedBox();
    }
  }

  // ── Step 0: Hero splash ───────────────────────────────────────────────────

  Widget _buildStep0() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headline with coloured spans
        RichText(
          text: TextSpan(
            style: GoogleFonts.orbitron(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              height: 1.15,
              color: AppColors.foreground,
            ),
            children: [
              const TextSpan(text: 'Buy '),
              TextSpan(text: '\$STK', style: const TextStyle(color: AppColors.cyan)),
              const TextSpan(text: '.\nClaim your '),
              ShaderMask(
                shaderCallback: (b) => AppGradients.violet.createShader(b),
                child: const Text('blocks',
                  style: TextStyle(color: Colors.white, fontSize: 36,
                    fontWeight: FontWeight.w900)),
              ).asSpan(),
              const TextSpan(text: '.\nDominate the '),
              ShaderMask(
                shaderCallback: (b) => AppGradients.gold.createShader(b),
                child: const Text('city',
                  style: TextStyle(color: Colors.white, fontSize: 36,
                    fontWeight: FontWeight.w900)),
              ).asSpan(),
              const TextSpan(text: '.'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Gamified real-estate investing on a Dubai-inspired neon grid. Crypto-powered. Strategy-driven.',
          style: AppTextStyles.interRegular(14, color: AppColors.mutedForeground),
        ),
        const SizedBox(height: 24),

        // Primary CTA
        _CyanButton(
          label: 'Get started',
          trailingIcon: Icons.arrow_forward_rounded,
          onTap: () => _goStep(1),
        ),
        const SizedBox(height: 8),

        // Skip
        GestureDetector(
          onTap: () => context.go('/app'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            alignment: Alignment.center,
            child: Text('Skip · explore demo',
              style: AppTextStyles.interRegular(13,
                  color: AppColors.mutedForeground)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Step 1: Age gate ──────────────────────────────────────────────────────

  Widget _buildStep1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How old are you?', style: AppTextStyles.orbitronBold(24)),
        const SizedBox(height: 8),
        Text(
          'Adults unlock real REIT-equivalent exposure. Under 18 plays in fully simulated mode.',
          style: AppTextStyles.interRegular(13, color: AppColors.mutedForeground),
        ),
        const SizedBox(height: 24),

        // Age option cards
        for (final o in _ageOptions) ...[
          _SelectCard(
            emoji: o.emoji,
            label: o.label,
            description: o.description,
            accentColor: o.accentColor,
            isSelected: _age == o.key,
            onTap: () => setState(() => _age = o.key),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),

        _CyanButton(
          label: 'Continue',
          enabled: _age != null,
          onTap: () => _goStep(2),
        ),
      ],
    );
  }

  // ── Step 2: Goal picker ───────────────────────────────────────────────────

  Widget _buildStep2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("What's your goal?", style: AppTextStyles.orbitronBold(24)),
        const SizedBox(height: 24),

        for (final o in _goalOptions) ...[
          _SelectCard(
            icon: o.icon,
            label: o.label,
            description: o.description,
            accentColor: o.accentColor,
            isSelected: _goal == o.key,
            onTap: () => setState(() => _goal = o.key),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),

        _CyanButton(
          label: 'Continue',
          enabled: _goal != null,
          onTap: () => _goStep(3),
        ),
      ],
    );
  }

  // ── Step 3: Wallet ready ──────────────────────────────────────────────────

  Widget _buildStep3() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Pulsing burst icon
        AnimatedBuilder(
          animation: _pulseAnim,
          builder: (_, child) => Transform.scale(
            scale: _pulseAnim.value,
            child: child,
          ),
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              gradient: AppGradients.cyan,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppGlows.cyan,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.auto_awesome_rounded,
                size: 36, color: AppColors.primaryForeground),
          ),
        ),
        const SizedBox(height: 24),

        Text('Wallet ready',
          style: AppTextStyles.orbitronBold(26),
          textAlign: TextAlign.center),
        const SizedBox(height: 12),

        // Seed STK amount with mono styling
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTextStyles.interRegular(14,
                color: AppColors.mutedForeground),
            children: [
              const TextSpan(
                  text: "Your STK wallet is set up. We'll seed your sim with "),
              TextSpan(
                text: '12,450 STK',
                style: AppTextStyles.jetBrainsBold(14,
                    color: AppColors.cyan),
              ),
              const TextSpan(text: ' to start.'),
            ],
          ),
        ),
        const SizedBox(height: 32),

        _CyanButton(
          label: 'Enter the city →',
          onTap: () => context.go('/app'),
        ),
      ],
    );
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

/// Glass option card used in Steps 1 & 2.
class _SelectCard extends StatelessWidget {
  final String? emoji;
  final IconData? icon;
  final String label;
  final String description;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectCard({
    this.emoji,
    this.icon,
    required this.label,
    required this.description,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  }) : assert(emoji != null || icon != null);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected
                ? accentColor.withOpacity(0.8)
                : AppColors.glassBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: accentColor.withOpacity(0.25), blurRadius: 18)]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppGradients.card,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  // Icon badge
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: emoji != null
                        ? Text(emoji!, style: const TextStyle(fontSize: 22))
                        : Icon(icon, size: 22, color: accentColor),
                  ),
                  const SizedBox(width: 14),

                  // Labels
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                          style: AppTextStyles.interSemiBold(15)),
                        const SizedBox(height: 2),
                        Text(description,
                          style: AppTextStyles.interRegular(11,
                              color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),

                  // Selection indicator
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? accentColor : AppColors.mutedForeground,
                        width: isSelected ? 0 : 1.5,
                      ),
                      color: isSelected ? accentColor : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            size: 13, color: Colors.black)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width cyan gradient CTA button.
class _CyanButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;
  final IconData? trailingIcon;

  const _CyanButton({
    required this.label,
    this.enabled = true,
    this.onTap,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.45,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: enabled ? AppGradients.cyan : null,
            color: enabled ? null : AppColors.secondary,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: enabled ? AppGlows.cyan : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                style: AppTextStyles.orbitronBold(15,
                    color: AppColors.primaryForeground)),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                Icon(trailingIcon, size: 16,
                    color: AppColors.primaryForeground),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Inline Widget → InlineSpan helper ────────────────────────────────────────

extension _WidgetSpanX on Widget {
  InlineSpan asSpan() => WidgetSpan(
    alignment: PlaceholderAlignment.baseline,
    baseline: TextBaseline.alphabetic,
    child: this,
  );
}
