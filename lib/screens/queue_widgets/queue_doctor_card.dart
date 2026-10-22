import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';

/// Kartu Ringkasan Dokter untuk Layar Antrean
class DoctorSummaryCard extends StatelessWidget {
  const DoctorSummaryCard({
    super.key,
    required this.dokter,
    required this.poli,
    required this.tanggal,
    required this.jam,
    required this.gedungLokasi,
  });

  final String dokter;
  final String poli;
  final String tanggal;
  final String jam;
  final String gedungLokasi;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 34, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D17233B),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Avatar Dokter ──
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 58,
                height: 66,
                decoration: BoxDecoration(
                  color: const Color(0xFFE7EDF6),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF7890AC),
                  size: 42,
                ),
              ),
              Positioned(
                right: -4,
                bottom: -3,
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: const BoxDecoration(
                    color: Color(0xFF82A5FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Color(0xFF063F99),
                    size: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // ── Info Dokter ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 5,
                  children: [
                    DoctorBadge(
                      label: poli,
                      backgroundColor: const Color(0xFFDCE4FF),
                      textColor: const Color(0xFF092C68),
                    ),
                    DoctorBadge(
                      label: gedungLokasi,
                      backgroundColor: const Color(0xFFE8E9EB),
                      textColor: const Color(0xFF454B59),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  dokter,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  poli,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF365FB6),
                      size: 16,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        tanggal,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  jam,
                  style: const TextStyle(
                    color: Color(0xFF063F99),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge Dokter (Poli, Gedung, Ruangan)
class DoctorBadge extends StatelessWidget {
  const DoctorBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
