import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/services/app_feedback_service.dart';

/// Header Brand Bar RS PKU Muhammadiyah Gamping
/// Reusable di seluruh halaman portal pasien (Beranda, Antrean, Jadwal, dll).
class HospitalBrandHeader extends StatelessWidget {
  const HospitalBrandHeader({
    super.key,
    this.backgroundColor = Colors.white,
    this.useGradient = false,
  });

  final Color backgroundColor;
  final bool useGradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: useGradient ? null : backgroundColor,
        gradient: useGradient
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFD)],
              )
            : null,
      ),
      child: Row(
        children: [
          // Logo RS PKU Gamping
          Image.asset(
            'assets/images/logo_pkugamping.png',
            width: 30,
            height: 30,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.local_hospital,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 9),

          // Teks Identitas Brand
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RS PKU Gamping',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Portal Pasien',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Lonceng Notifikasi dengan Unread Dot
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {
                  AppFeedback.showNotificationPermission(context);
                },
                tooltip: 'Notifikasi',
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF43516A),
                  size: 25,
                ),
              ),
              Positioned(
                right: 5,
                top: 7,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2866E8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
