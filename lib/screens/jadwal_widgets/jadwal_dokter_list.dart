import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/routes/app_routes.dart';
import 'jadwal_constants.dart';
import 'jadwal_dokter_card.dart';

/// List dokter yang sudah terfilter — menampilkan kartu per-dokter
/// atau empty state jika tidak ada hasil.
class JadwalDokterList extends StatelessWidget {
  const JadwalDokterList({
    super.key,
    required this.dokterList,
  });

  final List<DokterJadwal> dokterList;

  @override
  Widget build(BuildContext context) {
    if (dokterList.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08172340),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: List.generate(dokterList.length, (index) {
            final isLast = index == dokterList.length - 1;
            return JadwalDokterCard(
              dokter: dokterList[index],
              showDivider: !isLast,
              onTap: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.pendaftaran,
                  arguments: {'initialDokter': dokterList[index]},
                );
              },
            );
          }),
        ),
      ),
    );
  }

  /// Tampilan kosong ketika tidak ada dokter yang cocok dengan filter.
  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              color: kPrimaryBlue,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak Ada Jadwal',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kInk,
              fontFamily: kFontFamily,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Belum ada jadwal dokter pada\nhari atau poli yang dipilih.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: kMuted,
              height: 1.4,
              fontFamily: kFontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
