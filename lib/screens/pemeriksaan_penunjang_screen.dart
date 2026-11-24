import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/routes/app_router.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/services/pemeriksaan_penunjang_service.dart';

/// Halaman Hub Pemeriksaan Penunjang (Laboratorium & Radiologi)
class PemeriksaanPenunjangScreen extends StatelessWidget {
  const PemeriksaanPenunjangScreen({super.key, this.onRadiologyTap});

  final VoidCallback? onRadiologyTap;

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);

    return Theme(
      data: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: AppBar(
          backgroundColor: AppColors.pageBackground,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Kembali',
            icon: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          title: const Text(
            'Pemeriksaan Penunjang',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          titleSpacing: 4,
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Pilih jenis hasil pemeriksaan yang ingin Anda lihat.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _PemeriksaanCard(
                icon: Icons.science_outlined,
                title: 'Laboratorium',
                description: 'Hasil pemeriksaan darah, urine, dan lainnya.',
                onTap: () async {
                  final results = await PemeriksaanPenunjangService.getHasilLab();
                  if (!context.mounted) return;
                  Navigator.pushNamed(
                    context,
                    AppRoutes.hasilLab,
                    arguments: results,
                  );
                },
              ),
              const SizedBox(height: 16),
              _PemeriksaanCard(
                icon: Icons.medical_services_outlined,
                title: 'Radiologi',
                description: 'Hasil rontgen, USG, dan citra medis.',
                onTap: () async {
                  final results =
                      await PemeriksaanPenunjangService.getHasilRadiologi();
                  if (!context.mounted) return;
                  Navigator.pushNamed(
                    context,
                    AppRoutes.hasilRadiologi,
                    arguments: results,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PemeriksaanCard extends StatelessWidget {
  const _PemeriksaanCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0617233B),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: AppColors.primaryTintBorder),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
