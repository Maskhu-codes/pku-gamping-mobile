import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Pembungkus interaksi tekan (*tactile press*) bergaya tenang & medis.
///
/// - Mobile: efek tekan halus (`scale 0.98`, 100ms, `Curves.easeOutCubic`)
///   tanpa pantulan berlebihan.
/// - Haptic: opsional (`enableHaptic: true`), direkomendasikan hanya untuk
///   aksi penting (Konfirmasi Pendaftaran, tombol utama `+ Daftar`, dsb.).
/// - Web/Desktop: dukungan hover sangat lembut via `MouseRegion`.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
    this.pressedScale = 0.98,
    this.duration = const Duration(milliseconds: 100),
    this.enableHaptic = false,
    this.enableHover = true,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;
  final double pressedScale;
  final Duration duration;
  final bool enableHaptic;
  final bool enableHover;
  final BorderRadius? borderRadius;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _isPressed = false;
  bool _isHovered = false;

  bool get _canInteract => widget.enabled && widget.onTap != null;

  void _setPressed(bool value) {
    if (!_canInteract || _isPressed == value) return;
    setState(() => _isPressed = value);
  }

  void _handleTap() {
    if (!_canInteract) return;
    if (widget.enableHaptic) {
      HapticFeedback.lightImpact();
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final targetScale =
        (!reduceMotion && _isPressed) ? widget.pressedScale : 1.0;

    Widget content = AnimatedScale(
      scale: targetScale,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: (!reduceMotion && _isHovered && !_isPressed) ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        onTap: _canInteract ? _handleTap : null,
        child: content,
      );
    }

    if (!widget.enableHover) {
      return content;
    }

    return MouseRegion(
      cursor: _canInteract ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (_canInteract && !_isHovered) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (_isHovered) setState(() => _isHovered = false);
      },
      child: content,
    );
  }
}

