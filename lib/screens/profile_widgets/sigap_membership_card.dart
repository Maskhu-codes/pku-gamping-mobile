import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';

/// Kartu Keanggotaan SIGAP — Kartu Identitas Digital Pasien RS PKU Gamping
class SigapMembershipCard extends StatelessWidget {
  const SigapMembershipCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A2558), Color(0xFF0D4FC1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.goldBorder.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140A2558),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Color(0xFFFDE68A),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PASIEN SIGAP TERVERIFIKASI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFFFBF0),
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Akses prioritas layanan RS PKU Gamping',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFD1D5DB),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.goldSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.goldBorder),
            ),
            child: const Text(
              'Aktif',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.goldText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
