import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/routes/app_router.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/widgets/guest/guest_guard.dart';
import 'package:pku_gamping_app/widgets/motion/app_motion.dart';
import 'home_constants.dart';

/// Baris menu akses cepat beranda: Hasil Lab dan Riwayat Medis terintegrasi.
class HomeQuickLinks extends StatelessWidget {
  const HomeQuickLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kHomeCardBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0617233B),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // 1. Hasil Lab (Pemeriksaan Penunjang)
              Expanded(
                child: _QuickLinkTile(
                  icon: Icons.biotech_outlined,
                  title: 'Hasil Lab',
                  subtitle: 'Laboratorium & Rad',
                  onTap: () {
                    if (!GuestGuard.check(context, featureName: 'Hasil Laboratorium')) return;
                    Navigator.pushNamed(context, AppRoutes.pemeriksaanPenunjang);
                  },
                ),
              ),

              // Divider vertikal mikro
              const VerticalDivider(
                width: 1,
                thickness: 1,
                indent: 10,
                endIndent: 10,
                color: Color(0xFFF1F5F9),
              ),

              // 2. Riwayat Medis
              Expanded(
                child: _QuickLinkTile(
                  icon: Icons.description_outlined,
                  title: 'Riwayat Medis',
                  subtitle: 'Catatan & Resep',
                  onTap: () {
                    if (!GuestGuard.check(context, featureName: 'Riwayat Medis')) return;
                    Navigator.pushNamed(context, AppRoutes.riwayatPemeriksaan);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickLinkTile extends StatelessWidget {
  const _QuickLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      pressedScale: 0.98,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryTintBorder),
              ),
              child: Icon(
                icon,
                color: kHomePrimaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: kHomeInk,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      fontFamily: kHomeFontFamily,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: kHomeMuted,
                      fontSize: 10,
                      fontFamily: kHomeFontFamily,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
