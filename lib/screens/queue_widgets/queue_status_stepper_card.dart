import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';

/// Kartu Stepper Visual Status Antrean Poli (Status 0 - 3)
///
/// Menampilkan tahapan alur pelayanan pasien di RS PKU Muhammadiyah Gamping:
/// - Status 0: Booking Terjadwal (Menunggu Kedatangan / Check-in)
/// - Status 1: Terdaftar (Menuju Triage / Asesmen Keperawatan)
/// - Status 2: Triage Selesai (Menunggu Panggilan Dokter Poli)
/// - Status 3: Poli Selesai (Menuju Farmasi / Selesai Pemeriksaan)
class QueueStatusStepperCard extends StatelessWidget {
  const QueueStatusStepperCard({
    super.key,
    required this.currentStatus,
  });

  /// Status alur dari backend SIMRS (0 - 3)
  final int currentStatus;

  static const List<_StepData> _steps = [
    _StepData(
      index: 0,
      title: 'Booking',
      subtitle: 'Terjadwal',
      icon: Icons.calendar_today_rounded,
    ),
    _StepData(
      index: 1,
      title: 'Triage',
      subtitle: 'Asesmen',
      icon: Icons.how_to_reg_rounded,
    ),
    _StepData(
      index: 2,
      title: 'Poli',
      subtitle: 'Pemeriksaan',
      icon: Icons.medical_services_rounded,
    ),
    _StepData(
      index: 3,
      title: 'Selesai',
      subtitle: 'Farmasi',
      icon: Icons.check_circle_rounded,
    ),
  ];

  String get _statusTitle {
    switch (currentStatus) {
      case 1:
        return 'Pasien Terdaftar (Menuju Triage)';
      case 2:
        return 'Triage Selesai (Menunggu Poli)';
      case 3:
        return 'Pemeriksaan Selesai (Menuju Farmasi)';
      case 0:
      default:
        return 'Booking Dikonfirmasi (Menunggu Check-in)';
    }
  }

  String get _statusDescription {
    switch (currentStatus) {
      case 1:
        return 'Silakan menuju ruang triage untuk asesmen awal oleh perawat.';
      case 2:
        return 'Asesmen perawat selesai. Silakan menunggu panggilan dokter di ruang tunggu poli.';
      case 3:
        return 'Pemeriksaan dokter telah selesai. Silakan menuju loket farmasi untuk pengambilan obat.';
      case 0:
      default:
        return 'Pendaftaran berhasil. Silakan konfirmasi kedatangan di admisi/kiosk saat tiba di RS.';
    }
  }

  Color get _statusBadgeColor {
    switch (currentStatus) {
      case 1:
        return const Color(0xFF2563EB); // Biru triage
      case 2:
        return const Color(0xFFD97706); // Amber menunggu poli
      case 3:
        return const Color(0xFF16A34A); // Hijau selesai
      case 0:
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('queue_status_stepper_step_$currentStatus'),
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0617233B),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Stepper: Judul & Badge Status Saat Ini ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STATUS ALUR PELAYANAN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusTitle,
                      key: const Key('stepper_status_title'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusBadgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Tahap ${currentStatus + 1}/4',
                  key: const Key('stepper_tahap_badge'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _statusBadgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // ── Visual Stepper Baris 0 - 3 ──
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(_steps.length * 2 - 1, (index) {
                  if (index.isOdd) {
                    // Garis penghubung antar step
                    final stepBefore = index ~/ 2;
                    final isPassed = currentStatus > stepBefore;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 16),
                        height: 3,
                        decoration: BoxDecoration(
                          color: isPassed
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }

                  // Lingkaran Node Step
                  final stepIndex = index ~/ 2;
                  final stepData = _steps[stepIndex];
                  final isCompleted = currentStatus > stepIndex;
                  final isActive = currentStatus == stepIndex;

                  return _buildStepNode(
                    data: stepData,
                    isCompleted: isCompleted,
                    isActive: isActive,
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 18),

          // ── Keterangan / Petunjuk Pasien ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 17,
                  color: _statusBadgeColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusDescription,
                    key: const Key('stepper_status_desc'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF475569),
                      height: 1.35,
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

  Widget _buildStepNode({
    required _StepData data,
    required bool isCompleted,
    required bool isActive,
  }) {
    Color circleBg;
    Widget centerWidget;

    if (isCompleted) {
      circleBg = const Color(0xFF16A34A);
      centerWidget = const Icon(Icons.check_rounded, color: Colors.white, size: 18);
    } else if (isActive) {
      circleBg = AppColors.primary;
      centerWidget = Icon(data.icon, color: Colors.white, size: 17);
    } else {
      circleBg = const Color(0xFFF1F5F9);
      centerWidget = Text(
        '${data.index + 1}',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
        ),
      );
    }

    return SizedBox(
      width: 58,
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: circleBg,
              shape: BoxShape.circle,
              border: isActive
                  ? Border.all(color: const Color(0xFFBFDBFE), width: 3)
                  : null,
              boxShadow: isActive
                  ? const [
                      BoxShadow(
                        color: Color(0x280D4FC1),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(child: centerWidget),
          ),
          const SizedBox(height: 6),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : (isCompleted ? FontWeight.w600 : FontWeight.w500),
              color: isActive
                  ? AppColors.textPrimary
                  : (isCompleted ? const Color(0xFF16A34A) : AppColors.textMuted),
            ),
          ),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              color: isActive ? AppColors.primary : const Color(0xFF94A3B8),
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepData {
  final int index;
  final String title;
  final String subtitle;
  final IconData icon;

  const _StepData({
    required this.index,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}
