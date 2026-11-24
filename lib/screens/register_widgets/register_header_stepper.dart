import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';

/// Header navigasi dan indikator langkah pendaftaran akun pasien baru SIMRS.
class RegisterHeaderStepper extends StatelessWidget {
  const RegisterHeaderStepper({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onBack,
    required this.onStepTapped,
    this.hasExistingMr = false,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback onBack;
  final ValueChanged<int> onStepTapped;
  final bool hasExistingMr;

  @override
  Widget build(BuildContext context) {
    final stepTitles = [
      'Cek Identitas',
      hasExistingMr ? 'Data Pasien (SIMRS)' : 'Data Pasien',
      'Keamanan',
    ];

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── App Bar Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: onBack,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daftar Pasien Baru',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        'Lengkapi data diri Anda untuk mendaftar akun baru',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Stepper Section ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Progress indicator bar ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Langkah ${currentPage + 1} dari $totalPages',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        stepTitles[currentPage],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: List.generate(totalPages, (i) {
                    final isPassedOrCurrent = i <= currentPage ||
                        (hasExistingMr && i == 1 && currentPage == 2);
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(
                          left: i == 0 ? 0 : 3,
                          right: i == totalPages - 1 ? 0 : 3,
                        ),
                        decoration: BoxDecoration(
                          color: isPassedOrCurrent
                              ? AppColors.primary
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(child: _buildStepTab(0, '1. Cek NIK')),
                    Expanded(
                      child: _buildStepTab(
                        1,
                        hasExistingMr ? '2. Biodata SIMRS' : '2. Data Pasien',
                      ),
                    ),
                    Expanded(child: _buildStepTab(2, '3. Keamanan')),
                  ],
                ),
                const Divider(height: 16, color: Color(0xFFF1F5F9)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTab(int index, String label) {
    final active = currentPage == index;
    final done = currentPage > index ||
        (hasExistingMr && index == 1 && currentPage == 2);

    return GestureDetector(
      onTap: () {
        if (index <= currentPage || (hasExistingMr && index <= 2)) {
          onStepTapped(index);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontWeight: active || done ? FontWeight.w600 : FontWeight.w400,
            color: active
                ? AppColors.primary
                : (done ? AppColors.textPrimary : AppColors.textHint),
          ),
        ),
      ),
    );
  }
}
