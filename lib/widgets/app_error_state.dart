import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';

/// Komponen Tampilan Error Terstandarisasi
/// Digunakan di seluruh modul saat terjadi kegagalan jaringan, timeout, atau error server.
class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.title = 'Terjadi Kesalahan',
    required this.message,
    this.onRetry,
    this.retryText = 'Coba Lagi',
    this.icon = Icons.wifi_off_rounded,
    this.iconColor = const Color(0xFFDC2626),
    this.circleBackgroundColor = const Color(0xFFFEE2E2),
    this.compact = false,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryText;
  final IconData icon;
  final Color iconColor;
  final Color circleBackgroundColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final circleSize = compact ? 64.0 : 80.0;
    final iconSize = compact ? 30.0 : 38.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 28,
          vertical: compact ? 16 : 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                color: circleBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: iconSize,
                  color: iconColor,
                ),
              ),
            ),
            SizedBox(height: compact ? 12 : 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 12 : 13,
                height: 1.45,
                color: AppColors.textSecondary,
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
            if (onRetry != null) ...[
              SizedBox(height: compact ? 16 : 24),
              FilledButton.icon(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 20 : 28,
                    vertical: compact ? 10 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  retryText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    fontFamily: 'Plus Jakarta Sans',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
