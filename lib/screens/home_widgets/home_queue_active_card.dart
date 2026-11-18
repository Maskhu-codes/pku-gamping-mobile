import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/services/antrean_service.dart';
import 'package:pku_gamping_app/widgets/motion/app_motion.dart';
import 'home_constants.dart';

/// Kartu antrean aktif beranda bergaya *medical boarding pass* yang bersih & berkelas.
///
/// Hierarki informasi terstruktur:
/// 1. Header: Poliklinik (biru tipis) & Status kontekstual (Terjadwal / Berjalan)
/// 2. Hero: Nomor Antrean (kiri, rata kiri sejajar label) + Tanggal & Jam (kanan)
/// 3. Dokter: Nama dokter lega tanpa terpotong oleh jam
/// 4. CTA tonal biru tipis agar tidak bersaing dengan fokus nomor antrean
class HomeQueueActiveCard extends StatelessWidget {
  const HomeQueueActiveCard({
    super.key,
    required this.antrean,
    required this.onPantauPressed,
  });

  final AntreanAktifModel antrean;
  final VoidCallback onPantauPressed;

  @override
  Widget build(BuildContext context) {
    final isUpcoming = antrean.isUpcomingSchedule;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryTintBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F17233B),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 1. Baris Meta: Poliklinik & Status Kontekstual ──
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryTintBorder),
                  ),
                  child: Text(
                    antrean.poli,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      fontFamily: kHomeFontFamily,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _buildStatusBadge(isUpcoming: isUpcoming),
            ],
          ),
          const SizedBox(height: 16),

          // ── 2. Hero Section: Nomor Antrean (kiri) + Jadwal Tanggal & Jam (kanan) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'NOMOR ANTREAN',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10.5,
                        letterSpacing: 0.9,
                        fontWeight: FontWeight.w600,
                        fontFamily: kHomeFontFamily,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        antrean.nomorAntrean,
                        style: const TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 44,
                          height: 1.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          fontFamily: kHomeFontFamily,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    antrean.tanggal,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: kHomeInk,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: kHomeFontFamily,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        antrean.jam,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: kHomeFontFamily,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFEEF2F7)),
          const SizedBox(height: 12),

          // ── 3. Info Dokter (lebar penuh, tidak terpotong oleh jam) ──
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryTintBorder),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dokter Pemeriksa',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        fontFamily: kHomeFontFamily,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      antrean.dokter,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: kHomeInk,
                        fontSize: 13,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        fontFamily: kHomeFontFamily,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── 4. Tombol CTA Tonal Biru Tipis (classy & tidak menabrak hero biru) ──
          PressableScale(
            onTap: onPantauPressed,
            pressedScale: 0.985,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryTintBorder),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Pantau Antrean',
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: kHomeFontFamily,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 17,
                    color: AppColors.primaryDark,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge({required bool isUpcoming}) {
    if (isUpcoming) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.goldSoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.goldBorder),
        ),
        child: const Text(
          'Terjadwal',
          style: TextStyle(
            color: AppColors.goldText,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            fontFamily: kHomeFontFamily,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.goldSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.goldBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LivePulseDot(
            color: AppColors.accent,
            size: 6,
          ),
          const SizedBox(width: 4),
          Text(
            antrean.statusAntrean,
            style: const TextStyle(
              color: AppColors.goldText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: kHomeFontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
