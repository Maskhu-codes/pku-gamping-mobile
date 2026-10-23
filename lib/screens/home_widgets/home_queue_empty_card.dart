import 'package:flutter/material.dart';
import 'home_constants.dart';

/// Kartu antrean ketika pasien BELUM MEMILIKI antrean aktif.
/// Dilengkapi tombol CTA "+ Buat Janji / Daftar" untuk memudahkan pasien.
class HomeQueueEmptyCard extends StatelessWidget {
  const HomeQueueEmptyCard({
    super.key,
    required this.onDaftarPressed,
  });

  final VoidCallback onDaftarPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
          // Icon Tiket dalam Lingkaran Abu-abu
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEEF2F7)),
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              color: kHomeMuted,
              size: 25,
            ),
          ),
          const SizedBox(height: 11),

          // Judul
          const Text(
            'Belum Ada Antrean',
            style: TextStyle(
              color: kHomeInk,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              fontFamily: kHomeFontFamily,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          const Text(
            'Anda belum memiliki antrean kunjungan aktif.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kHomeMuted,
              fontSize: 12,
              fontFamily: kHomeFontFamily,
            ),
          ),
          const SizedBox(height: 14),

          // Tombol CTA Daftar Sekarang

        ],
      ),
    );
  }
}
