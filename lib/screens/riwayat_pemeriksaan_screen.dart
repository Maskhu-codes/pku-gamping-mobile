import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/models/riwayat_pemeriksaan_model.dart';
import 'package:pku_gamping_app/screens/riwayat_pemeriksaan_widgets/riwayat_empty_state.dart';

/// Halaman Riwayat Pemeriksaan Pasien RS PKU Muhammadiyah Gamping
/// Terpadu: Mendukung status kosong (empty state) maupun daftar rekam medis.
class RiwayatPemeriksaanScreen extends StatelessWidget {
  const RiwayatPemeriksaanScreen({
    super.key,
    this.riwayat = const [],
    this.onRiwayatTap,
  });

  final List<RiwayatPemeriksaan> riwayat;
  final ValueChanged<RiwayatPemeriksaan>? onRiwayatTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: AppBar(
          backgroundColor: AppColors.pageBackground,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            'Riwayat Pemeriksaan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: Color(0xFFEFF1F4)),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat Pemeriksaan',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pantau rekam jejak medis Anda.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: riwayat.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: RiwayatEmptyState(),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                      itemCount: riwayat.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final item = riwayat[index];
                        return _RiwayatHistoryCard(
                          item: item,
                          onTap: onRiwayatTap == null
                              ? null
                              : () => onRiwayatTap!(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiwayatHistoryCard extends StatelessWidget {
  const _RiwayatHistoryCard({required this.item, this.onTap});

  final RiwayatPemeriksaan item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      shadowColor: const Color(0x16000000),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 14, 18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.primary,
                          size: 17,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.tanggal,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.namaPemeriksaan,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _RiwayatHistoryDetail(
                      icon: Icons.local_hospital_outlined,
                      label: item.poli,
                    ),
                    const SizedBox(height: 5),
                    _RiwayatHistoryDetail(
                      icon: Icons.person_outline,
                      label: item.dokter,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F3F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RiwayatHistoryDetail extends StatelessWidget {
  const _RiwayatHistoryDetail({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 17),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
