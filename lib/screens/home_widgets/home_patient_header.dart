import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'home_constants.dart';

/// Bagian salam pasien, avatar, nomor rekam medis, dan lengkungan biru beranda.
/// Menampung kartu antrean di dalamnya ([queueCard]).
class HomePatientHeader extends StatelessWidget {
  const HomePatientHeader({
    super.key,
    required this.queueCard,
    this.namaPasien = 'Dahlan Muda',
    this.noRm = '01-88-24-90',
  });

  final Widget queueCard;
  final String namaPasien;
  final String noRm;

  String _dynamicGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat pagi,';
    if (hour >= 11 && hour < 15) return 'Selamat siang,';
    if (hour >= 15 && hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Lengkungan Latar Belakang Biru
        Container(
          height: 180,
          decoration: const BoxDecoration(
            color: kHomePrimaryBlue,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(60),
            ),
          ),
        ),

        // Konten Profil & Kartu Antrean
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 19),

              // Baris Profil Pasien
              Padding(
                padding: const EdgeInsets.only(left: 9, right: 3),
                child: Row(
                  children: [
                    // Avatar Lingkaran (menyesuaikan foto profil yang aktif)
                    ValueListenableBuilder<String?>(
                      valueListenable: SessionManager.profilePhotoNotifier,
                      builder: (context, photoPath, _) {
                        final hasPhoto = photoPath != null &&
                            photoPath.isNotEmpty &&
                            File(photoPath).existsSync();

                        return Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.goldBorder.withValues(alpha: 0.75),
                              width: 1.8,
                            ),
                          ),
                          child: ClipOval(
                            child: hasPhoto
                                ? Image.file(
                                    File(photoPath),
                                    width: 46,
                                    height: 46,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),

                    // Teks Salam, Nama & No. RM (hierarki jelas tanpa simbol menggantung)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _dynamicGreeting(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.84),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: kHomeFontFamily,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            namaPasien,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                              fontFamily: kHomeFontFamily,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            noRm.isEmpty ? 'Mode Tamu • Akses Publik' : 'No. RM $noRm',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: kHomeFontFamily,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Kartu Antrean (Bisa Kosong atau Aktif)
              queueCard,
            ],
          ),
        ),
      ],
    );
  }
}
