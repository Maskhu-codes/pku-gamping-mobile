import 'package:flutter/material.dart';
import 'pendaftaran_constants.dart';

/// Tombol Aksi Konfirmasi Pendaftaran di bagian bawah form.
/// Dilengkapi indikator validasi dan catatan kehadiran 15 menit sebelum waktu periksa.
class PendaftaranConfirmButton extends StatelessWidget {
  const PendaftaranConfirmButton({
    super.key,
    required this.isEnabled,
    required this.onPressed,
  });

  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Tombol Konfirmasi ──
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled
                  ? const Color(0xFF0A3A8A) // Dark navy sesuai desain
                  : const Color(0xFF94A3B8),
              elevation: isEnabled ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.how_to_reg_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Konfirmasi Pendaftaran',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: kPendaftaranFontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // ── Helper Subtext ──
        const Text(
          'Harap hadir 15 menit sebelum waktu jadwal periksa',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: kPendaftaranMuted,
            fontFamily: kPendaftaranFontFamily,
          ),
        ),
      ],
    );
  }
}
