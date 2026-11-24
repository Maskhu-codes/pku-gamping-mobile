import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/routes/app_routes.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/screens/profile_widgets/profile_app_bar.dart';
import 'package:pku_gamping_app/screens/profile_widgets/profile_footer.dart';
import 'package:pku_gamping_app/screens/profile_widgets/profile_header_card.dart';
import 'package:pku_gamping_app/screens/profile_widgets/profile_logout_button.dart';
import 'package:pku_gamping_app/screens/profile_widgets/profile_menu_section.dart';
import 'package:pku_gamping_app/screens/profile_widgets/profile_support_sheets.dart';
import 'package:pku_gamping_app/screens/profile_widgets/sigap_membership_card.dart';
import 'package:pku_gamping_app/services/app_notification_service.dart';
import 'package:pku_gamping_app/services/pemeriksaan_penunjang_service.dart';
import 'package:pku_gamping_app/services/simrs_service.dart';
import 'package:pku_gamping_app/widgets/app_bottom_nav.dart';
import 'package:pku_gamping_app/widgets/guest/guest_guard.dart';

/// Halaman Profil Pasien RS PKU Muhammadiyah Gamping
///
/// Mengambil data profil pasien langsung dari backend SIMRS (`GET /auth/me`)
/// saat screen dibuka, lalu menyajikan identitas nama, NIK, No. Rekam Medis (MR),
/// email akun, nomor HP, dan tanggal lahir secara reaktif dan persisten.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.embedded = false,
  });

  final bool embedded;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _muatProfil();
  }

  /// Mengambil data profil terbaru dari endpoint `GET /auth/me`
  Future<void> _muatProfil() async {
    if (SessionManager.isGuestMode) {
      return;
    }
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      await SimrsService.getMeProfile();
    } catch (e) {
      debugPrint('[ProfileScreen] Gagal memuat profil: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e
              .toString()
              .replaceFirst(RegExp(r'^Exception:\s*'), '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: const ProfileAppBar(),
      bottomNavigationBar: widget.embedded
          ? null
          : AppBottomNav(
              selectedIndex: 4,
              onItemSelected: (index) {
                if (index == 4) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                  arguments: {'initialIndex': index},
                );
              },
              onDaftarPressed: () {
                if (!GuestGuard.check(
                  context,
                  featureName: 'pendaftaran layanan',
                )) {
                  return;
                }
                Navigator.pushNamed(context, AppRoutes.pendaftaran);
              },
            ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return RefreshIndicator(
              onRefresh: _muatProfil,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
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
                          if (_isLoading && SessionManager.namaPasien.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: LinearProgressIndicator(),
                            ),

                          if (_errorMessage != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFECACA)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline,
                                    color: Color(0xFFDC2626),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF991B1B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // 1. Kartu Profil Pengguna (nama, NIK, MR, email, HP, tgl lahir)
                          ProfileHeaderCard(
                            nama: SessionManager.namaPasien,
                            noRm: SessionManager.noRm,
                            nik: SessionManager.nik,
                            email: SessionManager.email,
                            noHp: SessionManager.noHp,
                            tglLahir: SessionManager.fdTglLahir,
                          ),
                          const SizedBox(height: 14),

                          // 2. Kartu Status SIGAP / Kartu Tamu
                          if (SessionManager.isGuestMode)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySoft,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.account_circle_outlined,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hubungkan Akun Pasien',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Masuk untuk akses rekam medis & antrean',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      SessionManager.setGuestMode(false);
                                      Navigator.of(context, rootNavigator: true)
                                          .pushNamedAndRemoveUntil(
                                        AppRoutes.login,
                                        (route) => false,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Masuk',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
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
                                onTap: () async {
                                  if (!GuestGuard.check(
                                    context,
                                    featureName: 'Riwayat Pemeriksaan',
                                  )) {
                                    return;
                                  }
                                  final riwayatList =
                                      await PemeriksaanPenunjangService
                                          .getRiwayatPemeriksaan();
                                  if (!context.mounted) return;
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.riwayatPemeriksaan,
                                    arguments: riwayatList,
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
                                  if (!GuestGuard.check(
                                    context,
                                    featureName: 'Riwayat Resep',
                                  )) {
                                    return;
                                  }
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.riwayatResep,
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 4. Bagian: Pengaturan & Bantuan
                          const SectionTitle(
                            title: 'Pengaturan & Bantuan',
                            subtitle:
                                'Kelola preferensi dan informasi akun Anda',
                          ),
                          const SizedBox(height: 12),
                          MenuCardContainer(
                            children: [
                              MenuItemRow(
                                icon: Icons.person_outline_rounded,
                                iconBgColor: const Color(0xFFEFF6FF),
                                iconColor: const Color(0xFF2563EB),
                                title: 'Data & Profil Pasien',
                                subtitle:
                                    'Perbarui biodata dan kontak domisili',
                                showDivider: true,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.editProfile,
                                  );
                                },
                              ),
                              ValueListenableBuilder<bool>(
                                valueListenable:
                                    AppNotificationService.isEnabledNotifier,
                                builder: (context, isEnabled, _) {
                                  return ValueListenableBuilder<int>(
                                    valueListenable: AppNotificationService
                                        .unreadCountNotifier,
                                    builder: (context, unreadCount, _) {
                                      return MenuItemRow(
                                        icon: isEnabled
                                            ? Icons.notifications_active_rounded
                                            : Icons.notifications_off_outlined,
                                        iconBgColor: isEnabled
                                            ? const Color(0xFFEFF6FF)
                                            : const Color(0xFFF1F5F9),
                                        iconColor: isEnabled
                                            ? const Color(0xFF2563EB)
                                            : const Color(0xFF94A3B8),
                                        title: 'Notifikasi Layanan',
                                        subtitle: isEnabled
                                            ? (unreadCount > 0
                                                ? '$unreadCount notifikasi baru belum dibaca'
                                                : 'Aktif • Info antrean & hasil medis')
                                            : 'Nonaktif • Ketuk untuk aktifkan',
                                        badge: isEnabled
                                            ? (unreadCount > 0
                                                ? '$unreadCount Baru'
                                                : 'Aktif')
                                            : 'Nonaktif',
                                        badgeBgColor: isEnabled
                                            ? (unreadCount > 0
                                                ? const Color(0xFFFEE2E2)
                                                : const Color(0xFFDCFCE7))
                                            : const Color(0xFFF1F5F9),
                                        badgeTextColor: isEnabled
                                            ? (unreadCount > 0
                                                ? const Color(0xFFDC2626)
                                                : const Color(0xFF16A34A))
                                            : const Color(0xFF64748B),
                                        showDivider: true,
                                        onTap: () {
                                          AppNotificationService.handleBellTap(
                                            context,
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                              MenuItemRow(
                                icon: Icons.help_outline_rounded,
                                iconBgColor: const Color(0xFFF0FDF4),
                                iconColor: const Color(0xFF16A34A),
                                title: 'Bantuan & Dukungan',
                                subtitle:
                                    'Hubungi tim layanan RS PKU Gamping',
                                showDivider: true,
                                onTap: () => BantuanSheet.show(context),
                              ),
                              MenuItemRow(
                                icon: Icons.info_outline_rounded,
                                iconBgColor: const Color(0xFFFEF3C7),
                                iconColor: const Color(0xFFD97706),
                                title: 'Tentang Aplikasi',
                                subtitle: 'SIGAP Mobile v2.4.0',
                                showDivider: false,
                                onTap: () => TentangAplikasiSheet.show(context),
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
