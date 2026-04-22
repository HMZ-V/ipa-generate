// ============================================================
// glass_container.dart — Reusable glassmorphism card widget.
//
// Mirrors the .glass CSS class in index.css:
//   background: var(--grad-card)          → AppGradients.card
//   backdrop-filter: blur(18px)           → ImageFilter.blur(18, 18)
//   border: 1px solid hsl(220 40% 25%/55%)→ AppColors.glassBorder
//   box-shadow: var(--shadow-card)        → AppGlows.card
//
// Also implements .glass-hover behaviour via [hoverable] flag
// (uses InkWell + scale + glow on press/hover).
// ============================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class GlassContainer extends StatefulWidget {
  /// Content inside the glass card.
  final Widget child;

  /// Optional fixed width. Defaults to filling available space.
  final double? width;

  /// Optional fixed height.
  final double? height;

  /// Padding inside the glass card.
  final EdgeInsetsGeometry padding;

  /// Corner radius. Defaults to [AppRadius.lg] (20).
  final double borderRadius;

  /// When true, adds a press/hover scale effect + cyan glow (glass-hover).
  final bool hoverable;

  /// Custom border color override. Defaults to [AppColors.glassBorder].
  final Color? borderColor;

  /// Called when tapped (only relevant when [hoverable] is true).
  final VoidCallback? onTap;

  /// Override the gradient. Useful for gold/violet-tinted cards.
  final Gradient? gradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(0),
    this.borderRadius = AppRadius.lg,
    this.hoverable = false,
    this.borderColor,
    this.onTap,
    this.gradient,
  });

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<List<BoxShadow>?> _shadow;

  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.985).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (!widget.hoverable) return;
    setState(() => _pressed = true);
    _ctrl.forward();
  }

  void _onTapUp(_) {
    if (!widget.hoverable) return;
    setState(() => _pressed = false);
    _ctrl.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    if (!widget.hoverable) return;
    setState(() => _pressed = false);
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.borderColor ??
        (_pressed ? AppColors.cyan.withOpacity(0.55) : AppColors.glassBorder);

    final shadows = _pressed ? AppGlows.cyan : AppGlows.card;

    final inner = ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: widget.width,
          height: widget.height,
          padding: widget.padding,
          decoration: BoxDecoration(
            gradient: widget.gradient ?? AppGradients.card,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: shadows,
          ),
          child: widget.child,
        ),
      ),
    );

    if (!widget.hoverable) return inner;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: inner,
      ),
    );
  }
}

// ── Convenience wrappers ──────────────────────────────────────────────────────

/// A [GlassContainer] with standard card padding (20px).
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool hoverable;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = AppRadius.lg,
    this.hoverable = false,
    this.onTap,
    this.borderColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: borderRadius,
      hoverable: hoverable,
      onTap: onTap,
      borderColor: borderColor,
      width: width,
      height: height,
      child: child,
    );
  }
}
