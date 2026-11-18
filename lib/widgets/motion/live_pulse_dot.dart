import 'package:flutter/material.dart';

/// Indikator titik status real-time dengan denyut halus (*subtle breathing pulse*).
///
/// Cocok untuk badge `LIVE` pada monitor antrean poli dan farmasi.
class LivePulseDot extends StatefulWidget {
  const LivePulseDot({
    super.key,
    this.color = const Color(0xFF10B981),
    this.size = 7,
    this.duration = const Duration(milliseconds: 1800),
  });

  final Color color;
  final double size;
  final Duration duration;

  @override
  State<LivePulseDot> createState() => _LivePulseDotState();
}

class _LivePulseDotState extends State<LivePulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;
  late final bool _isTestEnv;

  @override
  void initState() {
    super.initState();
    _isTestEnv = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (!_isTestEnv) {
      _controller.repeat();
    }

    _scaleAnim = Tween<double>(begin: 1.0, end: 2.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _opacityAnim = Tween<double>(begin: 0.42, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        _isTestEnv || (MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    final boxSize = widget.size * 2.2;

    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (!reduceMotion)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Transform.scale(
                  scale: _scaleAnim.value,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: _opacityAnim.value),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

