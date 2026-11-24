import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'home_constants.dart';

/// Kartu Banner Jadwal Dokter khusus untuk Mode Tamu.
/// Memberikan arahan langsung untuk mengecek jadwal poliklinik tanpa perlu login.
class HomeGuestScheduleCard extends StatelessWidget {
  const HomeGuestScheduleCard({
    super.key,
    required this.onLihatJadwal,
    required this.onMasukAkun,
  });

  final VoidCallback onLihatJadwal;
  final VoidCallback onMasukAkun;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kHomeCardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0B17233B),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon Kalender dalam lingkaran biru lembut
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryTintBorder),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),

          // Judul
          const Text(
            'Jadwal Dokter & Poliklinik',
            style: TextStyle(
              color: kHomeInk,
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              fontFamily: kHomeFontFamily,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 5),

          // Subtitle
          const Text(
            'Cek jadwal praktik dokter spesialis dan ketersediaan poliklinik hari ini secara langsung.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kHomeMuted,
              fontSize: 12,
              height: 1.4,
              fontFamily: kHomeFontFamily,
            ),
          ),
          const SizedBox(height: 15),

          // Tombol CTA Lihat Jadwal
          ElevatedButton.icon(
            onPressed: onLihatJadwal,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size.fromHeight(42),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.calendar_today_outlined, size: 16),
            label: const Text(
              'Buka Jadwal Dokter',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: kHomeFontFamily,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Link Masuk Akun Pasien
          GestureDetector(
            onTap: onMasukAkun,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Sudah punya No. RM? Masuk Akun Pasien',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: kHomeFontFamily,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

