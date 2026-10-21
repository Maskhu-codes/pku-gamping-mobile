import 'package:flutter/material.dart';
import 'package:pku_gamping_app/screens/profile_widgets/profile_app_bar.dart';
import 'package:pku_gamping_app/screens/profile_widgets/profile_bottom_nav.dart';
import 'package:pku_gamping_app/screens/profile_widgets/profile_footer.dart';
import 'package:pku_gamping_app/screens/profile_widgets/profile_header_card.dart';
import 'package:pku_gamping_app/screens/profile_widgets/profile_logout_button.dart';
import 'package:pku_gamping_app/screens/profile_widgets/profile_menu_section.dart';
import 'package:pku_gamping_app/screens/profile_widgets/sigap_membership_card.dart';
import 'package:pku_gamping_app/screens/riwayat_pemeriksaan_screen.dart';
import 'package:pku_gamping_app/screens/riwayat_resep_screen.dart';

/// Halaman Profil Pasien RS PKU Muhammadiyah Gamping
/// Bersih, modular, dan terstruktur sesuai kaidah Clean Code.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: const ProfileAppBar(),
      bottomNavigationBar: const ProfileBottomNav(),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                overscroll: false,
                physics: const ClampingScrollPhysics(),
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 600,
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Kartu Profil Pengguna
                          const ProfileHeaderCard(),
                          const SizedBox(height: 14),

                          // 2. Kartu Status SIGAP
                          const SigapMembershipCard(),
                          const SizedBox(height: 24),

                          // 3. Bagian: Riwayat Saya
                          const SectionTitle(
                            title: 'Riwayat Saya',
                            subtitle:
                                'Akses catatan dan riwayat layanan kesehatan Anda',
                          ),
                          const SizedBox(height: 12),
                          MenuCardContainer(
                            children: [
                              MenuItemRow(
                                icon: Icons.medical_services_outlined,
                                iconBgColor: const Color(0xFFEEF2FF),
                                iconColor: const Color(0xFF4F46E5),
                                title: 'Riwayat Pemeriksaan',
                                subtitle:
                                    'Hasil laboratorium, radiologi & catatan medis',
                                badge: 'Baru',
                                badgeBgColor: const Color(0xFFFEE2E2),
                                badgeTextColor: const Color(0xFFDC2626),
                                showDivider: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const RiwayatPemeriksaanScreen(),
                                    ),
                                  );
                                },
                              ),
                              MenuItemRow(
                                icon: Icons.receipt_long_outlined,
                                iconBgColor: const Color(0xFFFEF3C7),
                                iconColor: const Color(0xFFD97706),
                                title: 'Riwayat Resep',
                                subtitle:
                                    'Daftar obat & status pengambilan farmasi',
                                showDivider: false,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const RiwayatResepScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 4. Bagian: Pengaturan & Bantuan
                          const SectionTitle(
                            title: 'Pengaturan & Bantuan',
                            subtitle: 'Kelola preferensi dan informasi akun Anda',
                          ),
                          const SizedBox(height: 12),
                          MenuCardContainer(
                            children: [
                              MenuItemRow(
                                icon: Icons.person_outline_rounded,
                                iconBgColor: const Color(0xFFEFF6FF),
                                iconColor: const Color(0xFF2563EB),
                                title: 'Edit Profil',
                                subtitle: 'Perbarui data pribadi dan pengaturan akun',
                                showDivider: true,
                                onTap: () {
                                  // TODO: Navigasi ke Edit Profil
                                },
                              ),
                              MenuItemRow(
                                icon: Icons.help_outline_rounded,
                                iconBgColor: const Color(0xFFF0FDF4),
                                iconColor: const Color(0xFF16A34A),
                                title: 'Bantuan & Dukungan',
                                subtitle: 'Hubungi tim layanan RS PKU Gamping',
                                showDivider: true,
                                onTap: () {},
                              ),
                              MenuItemRow(
                                icon: Icons.info_outline_rounded,
                                iconBgColor: const Color(0xFFFEF3C7),
                                iconColor: const Color(0xFFD97706),
                                title: 'Tentang Aplikasi',
                                subtitle: 'SIGAP Mobile v2.4.0',
                                showDivider: false,
                                onTap: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 5. Tombol Keluar
                          const ProfileLogoutButton(),
                          const SizedBox(height: 16),

                          // 6. Footer
                          const ProfileFooter(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
