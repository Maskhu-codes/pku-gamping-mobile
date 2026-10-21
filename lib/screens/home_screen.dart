import 'package:flutter/material.dart';
import 'package:pku_gamping_app/screens/home_widgets/home_bottom_nav.dart';
import 'package:pku_gamping_app/screens/home_widgets/home_brand_header.dart';
import 'package:pku_gamping_app/screens/home_widgets/home_constants.dart';
import 'package:pku_gamping_app/screens/home_widgets/home_emergency_contact.dart';
import 'package:pku_gamping_app/screens/home_widgets/home_news_section.dart';
import 'package:pku_gamping_app/screens/home_widgets/home_patient_header.dart';
import 'package:pku_gamping_app/screens/home_widgets/home_queue_active_card.dart';
import 'package:pku_gamping_app/screens/home_widgets/home_queue_empty_card.dart';
import 'package:pku_gamping_app/screens/home_widgets/home_quick_links.dart';
import 'package:pku_gamping_app/screens/home_widgets/home_simulation_bar.dart';
import 'package:pku_gamping_app/screens/pendaftaran_screen.dart';
import 'package:pku_gamping_app/screens/queue_detail_screen.dart';
import 'package:pku_gamping_app/services/antrean_service.dart';
import 'package:pku_gamping_app/widgets/top_notification.dart';

/// Screen Utama Beranda RS PKU Gamping (Refactored & Clean Code).
///
/// Menggunakan arsitektur modular dan reaktif:
/// - Otomatis beralih antara kondisi **Belum Ada Antrean** dan **Ada Antrean Aktif**.
/// - Terhubung secara langsung dengan alur pendaftaran rawat jalan.
/// - Dilengkapi [HomeSimulationBar] untuk kemudahan demonstrasi & testing status antrean.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.notification,
  });

  final TopNotificationType? notification;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
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
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 1. Header Brand Bar (RS PKU Gamping & Notifikasi)
              const HomeBrandHeader(),

              // 2. Konten Scrollable Beranda
              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(overscroll: false),
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
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute<void>(
                                          builder: (context) =>
                                              const PendaftaranScreen(),
                                        ),
                                      );
                                    },
                                  )
                                : HomeQueueActiveCard(
                                    antrean: antrean,
                                    onPantauPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute<void>(
                                          builder: (context) =>
                                              const QueueDetailScreen(),
                                        ),
                                      );
                                    },
                                  );

                            return HomePatientHeader(
                              queueCard: queueCard,
                              namaPasien: antrean?.namaPasien ?? 'Dahlan Muda',
                              noRm: antrean?.noRm ?? '01-88-24-90',
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

              // 3. Bottom Navigation Bar Terpadu (5 Tab)
              const HomeBottomNav(selectedIndex: 0),
            ],
          ),
        ),
      ),
    );
  }
}