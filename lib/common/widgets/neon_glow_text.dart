import 'package:flutter/material.dart';

/// Neon Glow text widget with subtle animated ambient pulsing glow.
class NeonGlowText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Color glowColor;

  const NeonGlowText({
    super.key,
    required this.text,
    this.style,
    this.glowColor = const Color(0xFF891C1E),
  });

  @override
  State<NeonGlowText> createState() => _NeonGlowTextState();
}

class _NeonGlowTextState extends State<NeonGlowText> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOutSine,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final double factor = _pulseAnimation.value;
        final Color glow = widget.glowColor;

        return Text(
          widget.text,
          style: (widget.style ?? const TextStyle()).copyWith(
            shadows: [
              // Core tight glow
              Shadow(
                color: glow.withValues(alpha: 0.70 + 0.25 * factor),
                offset: Offset.zero,
                blurRadius: 4 + 4 * factor,
              ),
              // Mid-range neon aura
              Shadow(
                color: glow.withValues(alpha: 0.45 + 0.20 * factor),
                offset: Offset.zero,
                blurRadius: 12 + 8 * factor,
              ),
              // Soft outer atmospheric neon dispersion
              Shadow(
                color: glow.withValues(alpha: 0.25 + 0.15 * factor),
                offset: Offset.zero,
                blurRadius: 22 + 12 * factor,
              ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
