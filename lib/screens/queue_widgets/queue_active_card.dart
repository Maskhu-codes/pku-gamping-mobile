import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';

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
  });

  final String nomorAntrean;
  final String nomorDilayani;
  final int sisaAntrean;
  final String poli;
  final bool soundReminderEnabled;
  final ValueChanged<bool> onSoundReminderChanged;
  final VoidCallback onDetailsPressed;

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
                      const Icon(
                        Icons.circle,
                        color: Color(0xFFFFC32A),
                        size: 10,
                      ),
                      const SizedBox(width: 5),
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
                          backgroundColor: const Color(0xFFF0F2F5),
                          numberColor: const Color(0xFF063F99),
                          labelColor: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: QueueNumberPanel(
                          label: 'SEDANG DILAYANI',
                          number: nomorDilayani,
                          caption: 'Dalam Pemeriksaan',
                          backgroundColor: const Color(0xFFFFF8EC),
                          numberColor: const Color(0xFF795500),
                          labelColor: const Color(0xFF795500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Status Sisa Antrean ──
                QueueWaitStatus(sisaAntrean: sisaAntrean),
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
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    onPressed: onDetailsPressed,
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF0F2F5),
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Detail Antrean',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 21),
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
  });

  final String label;
  final String number;
  final String caption;
  final Color backgroundColor;
  final Color numberColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 126),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              number,
              style: TextStyle(
                color: numberColor,
                fontSize: 34,
                height: 1,
                fontWeight: FontWeight.w700,
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
  const QueueWaitStatus({super.key, required this.sisaAntrean});

  final int sisaAntrean;

  @override
  Widget build(BuildContext context) {
    // Estimasi waktu tunggu: ~5 menit per pasien
    final estimasiMin = sisaAntrean * 5;
    final estimasiMax = estimasiMin + 5;

    return Container(
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
                  '$sisaAntrean Pasien Lagi di Depan Anda',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Estimasi tunggu: ± $estimasiMin - $estimasiMax Menit',
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
              sisaAntrean <= 2 ? 'Segera Bersiap' : 'Menunggu',
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
