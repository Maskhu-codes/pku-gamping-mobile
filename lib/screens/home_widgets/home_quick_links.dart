import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/routes/app_router.dart';
import 'package:pku_gamping_app/services/pemeriksaan_penunjang_service.dart';
import 'home_constants.dart';

/// Baris menu cepat beranda: Hasil Lab dan Riwayat.
class HomeQuickLinks extends StatelessWidget {
  const HomeQuickLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Hasil Lab (Pemeriksaan Penunjang)
          _QuickLinkItem(
            icon: Icons.biotech_outlined,
            label: 'Hasil Lab',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.pemeriksaanPenunjang);
            },
          ),
          const SizedBox(width: 42),

          // 2. Riwayat
          _QuickLinkItem(
            icon: Icons.description_outlined,
            label: 'Riwayat',
            onTap: () async {
              final riwayatList =
                  await PemeriksaanPenunjangService.getRiwayatPemeriksaan();
              if (!context.mounted) return;
              Navigator.pushNamed(
                context,
                AppRoutes.riwayatPemeriksaan,
                arguments: riwayatList,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickLinkItem extends StatelessWidget {
  const _QuickLinkItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0617233B),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: kHomePrimaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFamily: kHomeFontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
