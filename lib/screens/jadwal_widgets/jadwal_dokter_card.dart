import 'package:flutter/material.dart';
import 'jadwal_constants.dart';

/// Kartu tunggal berisi informasi seorang dokter beserta jadwalnya.
///
/// Menampilkan avatar, nama, poli, jam praktik, dan status ketersediaan.
class JadwalDokterCard extends StatelessWidget {
  const JadwalDokterCard({
    super.key,
    required this.dokter,
    this.onTap,
    this.showDivider = true,
  });

  final DokterJadwal dokter;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              children: [
                // ── Avatar Dokter ──
                _buildAvatar(),
                const SizedBox(width: 14),

                // ── Info Dokter ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama + Status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              dokter.nama,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: kInk,
                                fontFamily: kFontFamily,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Poli
                      Text(
                        dokter.poli,
                        style: const TextStyle(
                          fontSize: 13,
                          color: kMuted,
                          fontFamily: kFontFamily,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Jam Praktik
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: kMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${dokter.jamMulai}–${dokter.jamSelesai} WIB',
                            style: const TextStyle(
                              fontSize: 12,
                              color: kMuted,
                              fontFamily: kFontFamily,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Chevron ──
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: kMuted,
                  size: 22,
                ),
              ],
            ),
          ),

          // ── Divider ──
          if (showDivider)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(height: 1, color: kDivider),
            ),
        ],
      ),
    );
  }

  /// Avatar lingkaran dokter. Menampilkan foto jika ada, atau ikon fallback.
  Widget _buildAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        shape: BoxShape.circle,
        border: Border.all(color: kCardBorder, width: 1),
      ),
      child: dokter.fotoUrl != null
          ? ClipOval(
              child: Image.network(
                dokter.fotoUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _fallbackIcon(),
              ),
            )
          : _fallbackIcon(),
    );
  }

  Widget _fallbackIcon() {
    return const Icon(
      Icons.person_rounded,
      color: kPrimaryBlue,
      size: 26,
    );
  }

  /// Badge status ketersediaan dokter (Tersedia / Selesai / Cuti).
  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: dokter.status.bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dokter.status == StatusDokter.tersedia) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dokter.status.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            dokter.status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: dokter.status.color,
              fontFamily: kFontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
