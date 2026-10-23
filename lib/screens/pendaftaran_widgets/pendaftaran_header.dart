import 'package:flutter/material.dart';
import 'package:pku_gamping_app/widgets/hospital_brand_header.dart';
import 'pendaftaran_constants.dart';

/// Header atas untuk layar Pendaftaran.
/// Terdiri dari Brand Bar (Logo RS + Notifikasi)
/// dan Bar Navigasi (Tombol Kembali, Judul "Pendaftaran", Subtitle, dan Aksi Berkas).
class PendaftaranHeader extends StatelessWidget {
  const PendaftaranHeader({
    super.key,
    required this.onBack,
    this.onActionTap,
  });

  final VoidCallback onBack;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // ── Brand Header (Konsisten dengan seluruh aplikasi) ──
          const HospitalBrandHeader(),

          // ── Sub-Header: Back Button + Title + Icon Berkas ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Row(
              children: [
                // Tombol Back Lingkaran
                InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(color: kPendaftaranCardBorder),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: kPendaftaranInk,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Judul & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Pendaftaran',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: kPendaftaranInk,
                          fontFamily: kPendaftaranFontFamily,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Daftar kunjungan rawat jalan',
                        style: TextStyle(
                          fontSize: 12,
                          color: kPendaftaranMuted,
                          fontFamily: kPendaftaranFontFamily,
                        ),
                      ),
                    ],
                  ),
                ),

                // Tombol Aksi Berkas/Riwayat
                InkWell(
                  onTap: onActionTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Icon(
                      Icons.medical_information_outlined,
                      color: kPendaftaranPrimary,
                      size: 20,
                    ),
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
