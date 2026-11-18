import 'package:flutter/material.dart';

/// Efek shimmer lembut bergaya medis (tenang, tanpa kontras berlebihan).
///
/// Otomatis menghormati pengaturan aksesibilitas `disableAnimations` dari sistem.
class AppShimmer extends StatefulWidget {
  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFEEF2F7),
    this.highlightColor = const Color(0xFFF8FAFC),
    this.duration = const Duration(milliseconds: 1350),
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final slide = -1.2 + (_controller.value * 2.4);
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(slide - 0.8, -0.15),
              end: Alignment(slide + 0.8, 0.15),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.15, 0.5, 0.85],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

/// Blok placeholder sederhana untuk menyusun skeleton yang meniru bentuk kartu asli.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
    this.isCircle = false,
    this.color = const Color(0xFFE6ECF4),
  });

  final double? width;
  final double height;
  final double borderRadius;
  final bool isCircle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isCircle ? height : width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
      ),
    );
  }
}

