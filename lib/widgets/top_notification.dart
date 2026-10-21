import 'dart:async';
import 'package:flutter/material.dart';

// Jenis notifikasi yang tersedia
enum TopNotificationType {
  loginSuccess,
  queueCreated,
  queueCancelled,
}

class TopNotification {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required TopNotificationType type,
    Duration duration = const Duration(seconds: 5),
  }) {
    // Hapus notifikasi sebelumnya jika masih muncul
    _currentEntry?.remove();
    _currentEntry = null;

    late final OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _TopNotificationBanner(
        type: type,
        duration: duration,
        onDismiss: () {
          if (entry.mounted) {
            entry.remove();
          }

          if (identical(_currentEntry, entry)) {
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    Overlay.of(context).insert(entry);
  }
}

class _TopNotificationBanner extends StatefulWidget {
  final TopNotificationType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _TopNotificationBanner({
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_TopNotificationBanner> createState() =>
      _TopNotificationBannerState();
}

class _TopNotificationBannerState
    extends State<_TopNotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  Timer? _timer;
  bool _isClosing = false;

  bool get _isSuccess =>
      widget.type != TopNotificationType.queueCancelled;

  String get _title {
    switch (widget.type) {
      case TopNotificationType.loginSuccess:
        return 'Login Berhasil';

      case TopNotificationType.queueCreated:
        return 'Pendaftaran Berhasil';

      case TopNotificationType.queueCancelled:
        return 'Antrean Dibatalkan';
    }
  }

  String get _message {
    switch (widget.type) {
      case TopNotificationType.loginSuccess:
        return 'Selamat datang di aplikasi RS PKU Muhammadiyah Gamping.';

      case TopNotificationType.queueCreated:
        return 'Pendaftaran berhasil dan antrean kamu telah dibuat.';

      case TopNotificationType.queueCancelled:
        return 'Antrean kamu berhasil dibatalkan.';
    }
  }

  IconData get _notificationIcon {
    switch (widget.type) {
      case TopNotificationType.loginSuccess:
        return Icons.check_circle_rounded;

      case TopNotificationType.queueCreated:
        return Icons.assignment_turned_in_rounded;

      case TopNotificationType.queueCancelled:
        return Icons.event_busy_rounded;
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 250),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    // Animasi masuk dari atas
    _controller.forward();

    // Notifikasi menghilang otomatis
    _timer = Timer(widget.duration, _closeNotification);
  }

  void _closeNotification() {
    if (_isClosing || !mounted) return;

    _isClosing = true;
    _timer?.cancel();

    // Animasi keluar ke atas
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = _isSuccess
        ? const Color(0xFF15803D)
        : const Color(0xFFB91C1C);

    final Color backgroundColor = _isSuccess
        ? const Color(0xFFF0FDF4)
        : const Color(0xFFFEF2F2);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Ikon notifikasi
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _notificationIcon,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Judul dan pesan
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _title,
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            _message,
                            style: const TextStyle(
                              color: Color(0xFF374151),
                              fontSize: 12,
                              height: 1.4,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 4),

                    // Tombol tutup
                    IconButton(
                      onPressed: _closeNotification,
                      tooltip: 'Tutup notifikasi',
                      icon: Icon(
                        Icons.close_rounded,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
