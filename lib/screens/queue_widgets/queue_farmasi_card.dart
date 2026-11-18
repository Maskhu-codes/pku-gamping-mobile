import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/models/farmasi_antrean_model.dart';
import 'package:pku_gamping_app/widgets/motion/app_motion.dart';

/// Kartu Informasi Antrean Farmasi (Apotek) Real-time.
///
/// Menampilkan nomor-nomor antrean apotek yang sedang dipanggil / aktif
/// dipisahkan menjadi dua kategori sesuai alur SIMRS RS PKU Gamping:
/// 1. Obat Racik (Kode antrean B & D)
/// 2. Obat Non-Racik (Kode antrean A & C)
class QueueFarmasiCard extends StatelessWidget {
  const QueueFarmasiCard({
    super.key,
    required this.farmasi,
    this.onRefresh,
    this.lastUpdatedLabel,
  });

  final AntreanFarmasiModel? farmasi;
  final VoidCallback? onRefresh;
  final String? lastUpdatedLabel;

  @override
  Widget build(BuildContext context) {
    final racikList = farmasi?.racik ?? const [];
    final nonRacikList = farmasi?.nonRacik ?? const [];

    return Container(
      key: const Key('queue_farmasi_card'),
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0E17233B),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Farmasi & Live Badge ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.medication_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ANTREAN FARMASI / APOTEK',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Monitor panggilan loket farmasi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              // Live Pulse Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LivePulseDot(
                      color: Color(0xFF10B981),
                      size: 6,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ── Dua Kolom: Obat Racik (B, D) & Non-Racik (A, C) ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom Obat Racik
              Expanded(
                child: _buildCategoryColumn(
                  context: context,
                  title: 'Obat Racik',
                  subtitle: 'Antrean B & D',
                  items: racikList,
                  accentColor: const Color(0xFFD97706),
                  headerBgColor: const Color(0xFFFEF3C7),
                  badgeBorderColor: const Color(0xFFFDE68A),
                  chipBorderColor: const Color(0xFFF59E0B),
                  chipTextColor: const Color(0xFF92400E),
                  emptyKey: const Key('farmasi_racik_empty'),
                  listKey: const Key('farmasi_racik_list'),
                ),
              ),
              const SizedBox(width: 12),
              // Kolom Obat Non-Racik
              Expanded(
                child: _buildCategoryColumn(
                  context: context,
                  title: 'Non-Racik',
                  subtitle: 'Antrean A & C',
                  items: nonRacikList,
                  accentColor: const Color(0xFF059669),
                  headerBgColor: const Color(0xFFD1FAE5),
                  badgeBorderColor: const Color(0xFFA7F3D0),
                  chipBorderColor: const Color(0xFF10B981),
                  chipTextColor: const Color(0xFF065F46),
                  emptyKey: const Key('farmasi_non_racik_empty'),
                  listKey: const Key('farmasi_non_racik_list'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Keterangan Tambahan ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    (lastUpdatedLabel != null && lastUpdatedLabel!.trim().isNotEmpty)
                        ? '${lastUpdatedLabel!.trim()} • Pembaruan otomatis tiap 15 detik.'
                        : 'Pembaruan otomatis setiap 15 detik. Menuju loket farmasi saat nomor dipanggil.',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      height: 1.3,
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

  Widget _buildCategoryColumn({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<String> items,
    required Color accentColor,
    required Color headerBgColor,
    required Color badgeBorderColor,
    required Color chipBorderColor,
    required Color chipTextColor,
    required Key emptyKey,
    required Key listKey,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Kategori
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: headerBgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
              border: Border(
                bottom: BorderSide(color: badgeBorderColor),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: accentColor.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),

          // Daftar Nomor Antrean atau Status Kosong
          Padding(
            padding: const EdgeInsets.all(10),
            child: items.isEmpty
                ? Container(
                    key: emptyKey,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: const Text(
                      'Belum ada antrean',
                      style: TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Wrap(
                    key: listKey,
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      return Container(
                        key: Key('farmasi_chip_${index}_${item.replaceAll(' ', '_')}'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: chipBorderColor, width: 1.2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: chipTextColor,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      );
                    }),
                  ),
          ),
        ],
      ),
    );
  }
}
