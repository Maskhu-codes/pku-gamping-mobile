import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/routes/app_routes.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';

/// Dialog konfirmasi ajakan login ketika tamu mencoba mengakses fitur
/// pendaftaran atau booking jadwal dokter.
class GuestLoginPromptDialog extends StatelessWidget {
  const GuestLoginPromptDialog({
    super.key,
    this.dokterName,
    this.poliName,
  });

  final String? dokterName;
  final String? poliName;

  /// Tampilkan dialog ajakan login secara statis
  static Future<void> show(
    BuildContext context, {
    String? dokterName,
    String? poliName,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => GuestLoginPromptDialog(
        dokterName: dokterName,
        poliName: poliName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A0F172A),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon Lingkaran
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDBEAFE), width: 1.5),
              ),
              child: const Icon(
                Icons.lock_person_rounded,
                color: Color(0xFF0D4FC1),
                size: 32,
              ),
            ),
            const SizedBox(height: 18),

            // Judul
            const Text(
              'Akses Pendaftaran Terbatas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 10),

            // Deskripsi
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text:
                        'Anda sedang dalam Mode Tamu. Untuk mendaftar atau booking antrean',
                  ),
                  if (dokterName != null) ...[
                    const TextSpan(text: ' bersama '),
                    TextSpan(
                      text: dokterName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (poliName != null) ...[
                      TextSpan(
                        text: ' ($poliName)',
                        style: const TextStyle(
                          color: Color(0xFF0D4FC1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                  const TextSpan(
                    text:
                        ', silakan masuk atau daftar akun pasien terlebih dahulu.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Masuk
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login_rounded, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Masuk ke Akun Pasien',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Tombol Daftar Pasien Baru
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRoutes.register);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Daftar Pasien Baru',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Tombol Nanti Saja / Batal
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF94A3B8),
              ),
              child: const Text(
                'Lanjut Lihat Jadwal',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
