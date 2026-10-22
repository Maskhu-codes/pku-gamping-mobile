import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/routes/app_router.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/screens/home_widgets/home_brand_header.dart';
import 'package:pku_gamping_app/screens/home_widgets/home_constants.dart';
import 'package:pku_gamping_app/screens/home_widgets/home_emergency_contact.dart';
import 'package:pku_gamping_app/screens/home_widgets/home_news_section.dart';
import 'package:pku_gamping_app/screens/home_widgets/home_patient_header.dart';
import 'package:pku_gamping_app/screens/home_widgets/home_queue_active_card.dart';
import 'package:pku_gamping_app/screens/home_widgets/home_queue_empty_card.dart';
import 'package:pku_gamping_app/screens/home_widgets/home_quick_links.dart';
import 'package:pku_gamping_app/screens/home_widgets/home_simulation_bar.dart';
import 'package:pku_gamping_app/screens/jadwal_screen.dart';
import 'package:pku_gamping_app/screens/profile_screen.dart';
import 'package:pku_gamping_app/screens/queue_screen.dart';
import 'package:pku_gamping_app/services/antrean_service.dart';
import 'package:pku_gamping_app/widgets/app_bottom_nav.dart';
import 'package:pku_gamping_app/widgets/top_notification.dart';

/// Screen Utama & Single Shell Navigation Hub RS PKU Gamping.
///
/// Menggunakan arsitektur modular dan reaktif dengan [IndexedStack]:
/// - Tab 0: Beranda (Patient Header, Menu Cepat, Berita, IGD, Simulasi).
/// - Tab 1: Antrean (Reaktif: [QueueScreen] saat ada antrean aktif, [QueueBlank] jika kosong).
/// - Tab 2: Tombol (+) Daftar (Membuka [PendaftaranScreen]).
/// - Tab 3: Jadwal Dokter ([JadwalScreen]).
/// - Tab 4: Profil Pasien ([ProfileScreen]).
///
/// Navigasi antar tab instan tanpa lag dan tanpa penumpukan memori rute.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.initialIndex = 0,
    this.notification,
  });

  final int initialIndex;
  final TopNotificationType? notification;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.notification == null) return;
      TopNotification.show(context, type: widget.notification!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);

    return Theme(
      data: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(fontFamily: kHomeFontFamily),
      ),
      child: Scaffold(
        backgroundColor: kHomePageBg,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            // Tab 0: Beranda (const terisolasi)
            const HomeTabContent(),

            // Tab 1: Antrean (Reaktif internal)
            const QueueScreen(embedded: true),

            // Tab 2: Slot FAB (+) Daftar (dummy placeholder)
            const SizedBox.shrink(),

            // Tab 3: Jadwal Dokter
            const JadwalScreen(embedded: true),

            // Tab 4: Profil Pasien
            const ProfileScreen(embedded: true),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          selectedIndex: _currentIndex,
          onItemSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          onDaftarPressed: () {
            Navigator.pushNamed(context, AppRoutes.pendaftaran);
          },
        ),
      ),
    );
  }
}

/// Konten Utama Halaman Beranda (Scrollable) yang terisolasi sebagai const widget
class HomeTabContent extends StatelessWidget {
  const HomeTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // 1. Header Brand Bar (RS PKU Gamping & Notifikasi)
          const HomeBrandHeader(),

          // 2. Konten Scrollable Beranda
          Expanded(
            child: ScrollConfiguration(
              behavior:
                  ScrollConfiguration.of(context).copyWith(overscroll: false),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Banner Biru + Kartu Antrean Reaktif ──
                    ValueListenableBuilder<AntreanAktifModel?>(
                      valueListenable: AntreanService.antreanAktif,
                      builder: (context, antrean, _) {
                        final queueCard = antrean == null
                            ? HomeQueueEmptyCard(
                                onDaftarPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.pendaftaran,
                                  );
                                },
                              )
                            : HomeQueueActiveCard(
                                antrean: antrean,
                                onPantauPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.queueDetail,
                                  );
                                },
                              );

                        return HomePatientHeader(
                          queueCard: queueCard,
                          namaPasien: antrean?.namaPasien ?? SessionManager.namaPasien,
                          noRm: antrean?.noRm ?? SessionManager.noRm,
                        );
                      },
                    ),

                    // ── Menu Cepat (Hasil Lab, Riwayat, Ambil Obat) ──
                    const HomeQuickLinks(),

                    // ── Section Informasi & Berita ──
                    const HomeNewsSection(),
                    const SizedBox(height: 24),

                    // ── Layanan Gawat Darurat (IGD 24 Jam) ──
                    const HomeEmergencyContact(),
                    const SizedBox(height: 18),

                    // ── Panel Simulasi Testing Antrean ──
                    const HomeSimulationBar(),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}