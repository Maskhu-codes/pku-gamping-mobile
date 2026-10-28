import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';

/// Langkah 1: Pengecekan NIK KTP Terintegrasi SIMRS.
///
/// Menampilkan status tombol Cek NIK:
/// - Default (biru): belum dicek
/// - Valid (hijau): NIK belum terdaftar → bisa lanjut
/// - Tidak Valid (merah): NIK sudah terdaftar → tidak bisa lanjut
class RegisterStep1Nik extends StatelessWidget {
  const RegisterStep1Nik({
    super.key,
    required this.nikController,
    required this.isNikChecking,
    required this.isNikVerified,
    required this.isNikAlreadyRegistered,
    required this.nikHasBeenChecked,
    required this.onCekNik,
    required this.onLanjut,
    required this.onLoginTap,
    required this.onNikChanged,
  });

  final TextEditingController nikController;
  final bool isNikChecking;
  final bool isNikVerified;
  final bool isNikAlreadyRegistered;
  final bool nikHasBeenChecked;
  final VoidCallback onCekNik;
  final VoidCallback onLanjut;
  final VoidCallback onLoginTap;
  final VoidCallback onNikChanged;

  @override
  Widget build(BuildContext context) {
    // Warna tombol berdasarkan status
    Color buttonBgColor;
    Color buttonFgColor;
    if (nikHasBeenChecked && isNikAlreadyRegistered) {
      buttonBgColor = const Color(0xFFFEE2E2);
      buttonFgColor = const Color(0xFFDC2626);
    } else if (nikHasBeenChecked && isNikVerified) {
      buttonBgColor = const Color(0xFFE8F5E9);
      buttonFgColor = const Color(0xFF2E7D32);
    } else {
      buttonBgColor = AppColors.primary;
      buttonFgColor = Colors.white;
    }

    // Warna tombol bawah "Cek NIK & Lanjutkan"
    Color mainButtonBg;
    Color mainButtonFg;
    if (nikHasBeenChecked && isNikAlreadyRegistered) {
      mainButtonBg = const Color(0xFFDC2626);
      mainButtonFg = Colors.white;
    } else if (nikHasBeenChecked && isNikVerified) {
      mainButtonBg = const Color(0xFF2E7D32);
      mainButtonFg = Colors.white;
    } else {
      mainButtonBg = AppColors.primary;
      mainButtonFg = Colors.white;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card Identitas Pasien ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.badge_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Identitas Pasien',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'Pastikan nomor 16 digit NIK Anda valid dan sesuai KTP untuk pemeriksaan data.',
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
                const SizedBox(height: 16),

                const Text(
                  'Nomor Induk Kependudukan (NIK) *',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),

                // Field NIK + Tombol Cek NIK
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: nikHasBeenChecked
                          ? (isNikAlreadyRegistered
                              ? const Color(0xFFDC2626)
                              : (isNikVerified
                                  ? const Color(0xFF2E7D32)
                                  : AppColors.border))
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: nikController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => onNikChanged(),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                          ],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: AppColors.textPrimary,
                          ),
                          decoration: const InputDecoration(
                            hintText: '3404xxxxxxxxxxxx',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              letterSpacing: 0.5,
                              color: AppColors.textHint,
                            ),
                            prefixIcon: Icon(
                              Icons.credit_card_rounded,
                              color: AppColors.textHint,
                              size: 18,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ElevatedButton(
                          onPressed: isNikChecking ? null : onCekNik,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonBgColor,
                            foregroundColor: buttonFgColor,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: isNikChecking
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (nikHasBeenChecked && isNikVerified) ...[
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 14,
                                        color: Color(0xFF2E7D32),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    if (nikHasBeenChecked &&
                                        isNikAlreadyRegistered) ...[
                                      const Icon(
                                        Icons.cancel_rounded,
                                        size: 14,
                                        color: Color(0xFFDC2626),
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      nikHasBeenChecked
                                          ? (isNikAlreadyRegistered
                                              ? 'Tidak Valid'
                                              : 'Valid')
                                          : 'Cek NIK',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // Pesan status di bawah input NIK
                if (nikHasBeenChecked && isNikAlreadyRegistered)
                  Row(
                    children: const [
                      Icon(Icons.error_outline_rounded,
                          size: 13, color: Color(0xFFDC2626)),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'NIK sudah terdaftar! Gunakan NIK yang belum terdaftar.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFDC2626),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                else if (nikHasBeenChecked && isNikVerified)
                  Row(
                    children: const [
                      Icon(Icons.check_circle_outline_rounded,
                          size: 13, color: Color(0xFF2E7D32)),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'NIK valid dan belum terdaftar. Silakan lanjutkan.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  const Text(
                    'Pastikan nomor NIK sesuai dengan KTP Anda.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Info SIMRS Banner ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFD97706),
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Pendaftaran Pasien Baru',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF92400E),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Nomor Rekam Medis (No. RM) baru akan dibuatkan secara otomatis berdasarkan data identitas di atas.\n\nTerkoneksi dengan Sistem SIMRS RS PKU Muhammadiyah Gamping.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFB45309),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Tombol Lanjut ──
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onLanjut,
              style: ElevatedButton.styleFrom(
                backgroundColor: mainButtonBg,
                foregroundColor: mainButtonFg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                nikHasBeenChecked && isNikVerified
                    ? 'Lanjutkan →'
                    : 'Cek NIK & Lanjutkan →',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Footer "Sudah punya akun? Masuk" ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sudah punya akun? ',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              GestureDetector(
                onTap: onLoginTap,
                child: const Text(
                  'Masuk',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
