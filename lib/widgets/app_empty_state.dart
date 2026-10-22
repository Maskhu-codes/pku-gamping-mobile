import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';

/// Komponen Tampilan Kosong (Empty State) Terstandarisasi
/// Reusable di seluruh fitur (Riwayat, Hasil Lab, Radiologi, Antrean Kosong).
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor = AppColors.primary,
    this.circleBackgroundColor = const Color(0xFFEBF3FF),
    this.circleSize = 84,
    this.iconSize = 38,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color iconColor;
  final Color circleBackgroundColor;
  final double circleSize;
  final double iconSize;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Lingkaran Ikon
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
        const SizedBox(height: 20),

        // Judul Status Kosong
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Pesan Keterangan
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.45,
            ),
          ),
        ),

        // Tombol Aksi Opsional
        if (action != null) ...[
          const SizedBox(height: 24),
          action!,
        ],
      ],
    );
  }
}
