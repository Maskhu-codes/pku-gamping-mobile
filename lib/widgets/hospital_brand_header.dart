import 'package:flutter/material.dart';
import 'package:pku_gamping_app/services/app_feedback_service.dart';

/// Header Brand Bar RS PKU Muhammadiyah Gamping
/// Reusable di seluruh halaman portal pasien (Beranda, Antrean, Jadwal, Pendaftaran, Profil, dll).
class HospitalBrandHeader extends StatelessWidget {
  const HospitalBrandHeader({
    super.key,
    this.backgroundColor = Colors.white,
    this.useGradient = false,
    this.showBorder = true,
  });

  final Color backgroundColor;
  final bool useGradient;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: useGradient ? null : backgroundColor,
        border: showBorder
            ? const Border(
                bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1),
              )
            : null,
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
          // Logo RS PKU Gamping (Ukuran 38x38 seragam)
          Image.asset(
            'assets/images/logo_pkugamping.png',
            width: 38,
            height: 38,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_hospital,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Teks Identitas Brand
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RS PKU Gamping',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 1),
                Text(
                  'Portal Pasien',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Lonceng Notifikasi dengan Unread Dot yang menempel pas di kanan atas lonceng
          IconButton(
            onPressed: () {
              AppFeedback.showNotificationPermission(context);
            },
            tooltip: 'Notifikasi',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: SizedBox(
              width: 24,
              height: 24,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_none_rounded,
                    color: Color(0xFF1E293B),
                    size: 24,
                  ),
                  Positioned(
                    top: 1,
                    right: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
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
}
