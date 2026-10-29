import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
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
                            color: const Color(0xFFB7B7B7),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
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
                                    Icons.person,
                                    color: Colors.white,
                                    size: 34,
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 11),

                    // Teks Salam & Nama
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selamat pagi,',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontFamily: kHomeFontFamily,
                            ),
                          ),
                          Text(
                            namaPasien,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              fontFamily: kHomeFontFamily,
                            ),
                          ),
                          Text(
                            'No. RM: $noRm  •',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontFamily: kHomeFontFamily,
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
