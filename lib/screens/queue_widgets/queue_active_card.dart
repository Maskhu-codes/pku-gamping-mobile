import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/widgets/motion/app_motion.dart';

/// Kartu Antrean Aktif dengan nomor antrean live, switch suara, dan tombol detail
class ActiveQueueCard extends StatelessWidget {
  const ActiveQueueCard({
    super.key,
    required this.nomorAntrean,
    required this.nomorDilayani,
    required this.sisaAntrean,
    required this.poli,
    required this.soundReminderEnabled,
    required this.onSoundReminderChanged,
    required this.onDetailsPressed,
    this.isUpcomingSchedule = false,
    this.tanggalJadwal,
    this.lastUpdatedLabel,
  });

  final String nomorAntrean;
  final String nomorDilayani;
  final int sisaAntrean;
  final String poli;
  final bool soundReminderEnabled;
  final ValueChanged<bool> onSoundReminderChanged;
  final VoidCallback onDetailsPressed;
  final bool isUpcomingSchedule;
  final String? tanggalJadwal;
  final String? lastUpdatedLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header Biru: Status Live ──
          Container(
            constraints: const BoxConstraints(minHeight: 58),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            color: AppColors.primary,
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: Color(0xFFFFD36A),
                  size: 23,
                ),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Panggilan Antrean Aktif',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LivePulseDot(
                        color: Color(0xFFEAB308),
                        size: 7,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Live $poli',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Konten Panel Nomor Antrean ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
            child: Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: QueueNumberPanel(
                          label: 'NOMOR ANDA',
                          number: nomorAntrean,
                          caption: 'Pasien Terjadwal',
                          backgroundColor: AppColors.primarySoft,
                          borderColor: AppColors.primaryTintBorder,
                          numberColor: AppColors.primaryDark,
                          labelColor: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: QueueNumberPanel(
                          label: 'SEDANG DILAYANI',
                          number: nomorDilayani,
                          caption: 'Dalam Pemeriksaan',
                          backgroundColor: AppColors.goldSoft,
                          borderColor: AppColors.goldBorder,
                          numberColor: AppColors.goldText,
                          labelColor: AppColors.goldText,
                        ),
                      ),
                    ],
                  ),
                ),
                if (lastUpdatedLabel != null &&
                    lastUpdatedLabel!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.sync_rounded,
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        lastUpdatedLabel!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // ── Status Sisa Antrean ──
                QueueWaitStatus(
                  sisaAntrean: sisaAntrean,
                  isUpcomingSchedule: isUpcomingSchedule,
                  tanggalJadwal: tanggalJadwal,
                ),
                const SizedBox(height: 14),

                // ── Toggle Pengingat Suara ──
                Row(
                  children: [
                    const Icon(
                      Icons.volume_up_outlined,
                      color: Color(0xFF365FB6),
                      size: 23,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aktifkan Pengingat Suara',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Peringatan saat tersisa 2 antrean',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: soundReminderEnabled,
                      onChanged: onSoundReminderChanged,
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Tombol Detail Antrean ──
                PressableScale(
                  onTap: onDetailsPressed,
                  pressedScale: 0.985,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: AppColors.primaryTintBorder),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Detail Antrean',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 21,
                          color: AppColors.primary,
                        ),
                      ],
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

/// Panel Nomor Antrean (Nomor Pasien / Nomor Sedang Dilayani)
class QueueNumberPanel extends StatelessWidget {
  const QueueNumberPanel({
    super.key,
    required this.label,
    required this.number,
    required this.caption,
    required this.backgroundColor,
    required this.numberColor,
    required this.labelColor,
    this.borderColor,
  });

  final String label;
  final String number;
  final String caption;
  final Color backgroundColor;
  final Color numberColor;
  final Color labelColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 126),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: labelColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final slide = Tween<Offset>(
                begin: const Offset(0, 0.22),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slide, child: child),
              );
            },
            child: FittedBox(
              key: ValueKey<String>(number),
              fit: BoxFit.scaleDown,
              child: Text(
                number,
                style: TextStyle(
                  color: numberColor,
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: numberColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Indikator Waktu Tunggu dan Sisa Pasien
class QueueWaitStatus extends StatelessWidget {
  const QueueWaitStatus({
    super.key,
    required this.sisaAntrean,
    this.isUpcomingSchedule = false,
    this.tanggalJadwal,
  });

  final int sisaAntrean;
  final bool isUpcomingSchedule;
  final String? tanggalJadwal;

  @override
  Widget build(BuildContext context) {
    if (isUpcomingSchedule) {
      final tglLabel = (tanggalJadwal != null && tanggalJadwal!.trim().isNotEmpty)
          ? tanggalJadwal!.trim()
          : 'hari kunjungan Anda';
      return Container(
        key: const Key('queue_wait_status_upcoming'),
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF063F99),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.event_available_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jadwal Kunjungan Mendatang',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Antrean live dimulai pada $tglLabel',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFDCE4FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Terjadwal',
                style: TextStyle(
                  color: Color(0xFF092C68),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Estimasi waktu tunggu: ~5 menit per pasien
    final safeSisa = sisaAntrean < 0 ? 0 : sisaAntrean;
    final estimasiMin = safeSisa * 5;
    final estimasiMax = estimasiMin + 5;

    return Container(
      key: const Key('queue_wait_status_live'),
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E7E9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF063F99),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.groups_outlined,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$safeSisa Pasien Lagi di Depan Anda',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  safeSisa == 0
                      ? 'Giliran Anda / segera dipanggil'
                      : 'Estimasi tunggu: ± $estimasiMin - $estimasiMax Menit',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFDCE4FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              safeSisa <= 2 ? 'Segera Bersiap' : 'Menunggu',
              style: const TextStyle(
                color: Color(0xFF092C68),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
