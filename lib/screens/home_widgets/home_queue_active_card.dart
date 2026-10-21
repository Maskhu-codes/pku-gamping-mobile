import 'package:flutter/material.dart';
import 'package:pku_gamping_app/services/antrean_service.dart';
import 'home_constants.dart';

/// Kartu antrean ketika pasien SUDAH MEMILIKI antrean aktif.
/// Menampilkan nomor panggilan, nama poli, dokter, dan tombol pantau antrean.
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD5DBE5), width: 1.3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D17233B),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Baris Tag Poli, Lokasi, dan Status Antrean
          Row(
            children: [
              _buildTag(
                label: antrean.poli,
                foreground: kHomePrimaryBlue,
                background: const Color(0xFFF0F5FF),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  antrean.gedungLokasi,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kHomeMuted,
                    fontSize: 12,
                    fontFamily: kHomeFontFamily,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _buildTag(
                label: antrean.statusAntrean,
                foreground: const Color(0xFFE57B00),
                background: const Color(0xFFFFFAEE),
                showDot: true,
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Label Nomor Antrean Anda
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              'NOMOR ANTREAN ANDA',
              style: TextStyle(
                color: kHomeMuted,
                fontSize: 11,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
                fontFamily: kHomeFontFamily,
              ),
            ),
          ),
          const Divider(height: 6, color: Color(0xFFF0F2F6)),

          // Nomor Antrean Besar
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              antrean.nomorAntrean,
              style: const TextStyle(
                color: kHomePrimaryBlue,
                fontSize: 52,
                height: 1.05,
                fontWeight: FontWeight.w800,
                fontFamily: kHomeFontFamily,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Detail Dokter & Waktu
          Container(
            constraints: const BoxConstraints(minHeight: 36),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.medical_services_outlined,
                  color: kHomeMuted,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    antrean.dokter,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF35445D),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: kHomeFontFamily,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  antrean.jam,
                  style: const TextStyle(
                    color: kHomeMuted,
                    fontSize: 11,
                    fontFamily: kHomeFontFamily,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Tombol Pantau Antrean
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: onPantauPressed,
              style: FilledButton.styleFrom(
                backgroundColor: kHomePrimaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      'Pantau Antrean Langsung',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: kHomeFontFamily,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag({
    required String label,
    required Color foreground,
    required Color background,
    bool showDot = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: showDot ? 8 : 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: foreground,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
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
