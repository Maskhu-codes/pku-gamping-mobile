import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/routes/app_routes.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';

/// Guard sentral untuk membatasi fitur khusus pasien terdaftar saat dalam Mode Tamu.
/// Menampilkan pop-up dialog di tengah layar (Center Dialog) sesuai desain RS PKU Gamping.
class GuestGuard {
  GuestGuard._();

  /// Memeriksa apakah pengguna berada di Mode Tamu.
  /// Jika ya, tampilkan dialog pop-up ajakan masuk akun pasien dan kembalikan `false`.
  /// Jika pengguna sudah login, kembalikan `true`.
  static bool check(
    BuildContext context, {
    String? featureName,
    String? title,
    String? message,
    String? confirmText,
    String? cancelText,
  }) {
    if (!SessionManager.isGuestMode) {
      return true;
    }

    final dialogTitle = title ?? 'Akun Pasien Diperlukan';
    final dialogMessage = message ??
        (featureName != null
            ? 'Untuk mengakses fitur $featureName, Anda harus masuk ke akun pasien terlebih dahulu.'
            : 'Untuk melakukan booking jadwal dokter, Anda harus masuk ke akun pasien terlebih dahulu.');

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => _GuestAuthDialog(
        title: dialogTitle,
        message: dialogMessage,
        confirmText: confirmText ?? 'Masuk ke Akun Pasien',
        cancelText: cancelText ?? 'Batal',
      ),
    );

    return false;
  }
}

class _GuestAuthDialog extends StatelessWidget {
  const _GuestAuthDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      elevation: 6,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Icon Container (Lingkaran Biru Institusional)
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: Color(0xFFEBF3FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_pin_rounded,
                  size: 34,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 18),

              // 2. Judul
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),

              // 3. Deskripsi / Subteks
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  height: 1.45,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 24),

              // 4. Tombol Utama: Masuk ke Akun Pasien
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                    SessionManager.setGuestMode(false);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.login,
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    confirmText,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 5. Tombol Sekunder: Batal
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () =>
                      Navigator.of(context, rootNavigator: true).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    cancelText,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
