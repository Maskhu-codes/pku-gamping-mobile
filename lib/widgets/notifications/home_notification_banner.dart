import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/services/app_notification_service.dart';

/// Banner edukasi di halaman Beranda yang muncul HANYA saat notifikasi belum aktif.
/// Begitu pasien mengaktifkan notifikasi, banner ini otomatis menghilang.
class HomeNotificationBanner extends StatelessWidget {
  const HomeNotificationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppNotificationService.isEnabledNotifier,
      builder: (context, isEnabled, _) {
        if (isEnabled) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFFDE68A),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => AppNotificationService.showPermissionDialog(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                child: Row(
                  children: [
                    // Ikon Lonceng Status
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFFCD34D),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.notifications_active_outlined,
                          color: Color(0xFFD97706),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Teks Keterangan
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Text(
                                'Notifikasi Belum Aktif',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.circle,
                                size: 6,
                                color: Color(0xFFD97706),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Aktifkan agar panggilan antrean & hasil lab dapat diberitahukan tepat waktu.',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: const Color(0xFF92400E).withValues(alpha: 0.85),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Tombol Aksi
                    FilledButton(
                      onPressed: () =>
                          AppNotificationService.showPermissionDialog(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Aktifkan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
