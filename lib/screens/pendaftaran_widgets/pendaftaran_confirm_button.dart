import 'package:flutter/material.dart';
import 'package:pku_gamping_app/widgets/motion/app_motion.dart';
import 'pendaftaran_constants.dart';

/// Tombol Aksi Konfirmasi Pendaftaran di bagian bawah form.
/// Dilengkapi indikator validasi, tactile press + haptic (aksi penting),
/// dan catatan kehadiran 15 menit sebelum waktu periksa.
class PendaftaranConfirmButton extends StatelessWidget {
  const PendaftaranConfirmButton({
    super.key,
    required this.isEnabled,
    required this.onPressed,
    this.isLoading = false,
  });

  final bool isEnabled;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final active = isEnabled && !isLoading;
    return Column(
      children: [
        // ── Tombol Konfirmasi (Tactile Press + Haptic untuk Aksi Penting) ──
        PressableScale(
          onTap: isLoading ? null : onPressed,
          enabled: !isLoading,
          pressedScale: 0.98,
          enableHaptic: active,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFF0A3A8A)
                  : const Color(0xFF94A3B8),
              borderRadius: BorderRadius.circular(14),
              boxShadow: active
                  ? const [
                      BoxShadow(
                        color: Color(0x220A3A8A),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : const [],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: isLoading
                    ? const Row(
                        key: ValueKey('confirm_loading'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Memproses Booking...',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontFamily: kPendaftaranFontFamily,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        key: ValueKey('confirm_idle'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
