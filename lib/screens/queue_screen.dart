import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/routes/app_router.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/screens/queue_widgets/queue_active_card.dart';
import 'package:pku_gamping_app/screens/queue_widgets/queue_brand_header.dart';
import 'package:pku_gamping_app/screens/queue_widgets/queue_doctor_card.dart';
import 'package:pku_gamping_app/screens/queue_widgets/queue_room_directions_card.dart';
import 'package:pku_gamping_app/screens/queue_widgets/queue_service_value_card.dart';
import 'package:pku_gamping_app/services/antrean_service.dart';
import 'package:pku_gamping_app/widgets/app_bottom_nav.dart';
import 'package:pku_gamping_app/widgets/app_empty_state.dart';

/// Layar Antrean Aktif Rawat Jalan.
///
/// Menampilkan status antrean pasien secara reaktif berdasarkan data dari
/// [AntreanService]. Seluruh informasi dokter, poli, nomor antrean, dan
/// estimasi waktu tunggu ditarik dari single source of truth yang sama
/// dengan layar Beranda dan Detail Antrean.
class QueueScreen extends StatefulWidget {
  const QueueScreen({
    super.key,
    this.embedded = false,
  });

  final bool embedded;

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  bool _soundReminderEnabled = false;
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    return Theme(
      data: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(fontFamily: 'Plus Jakarta Sans'),
      ),
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const QueueBrandHeader(),

              // ── Konten Utama Reaktif (Auto-update saat data antrean berubah) ──
              Expanded(
                child: ValueListenableBuilder<AntreanAktifModel?>(
                  valueListenable: AntreanService.antreanAktif,
                  builder: (context, antrean, _) {
                    if (antrean == null) {
                      return _buildEmptyQueue(context);
                    }

                    return ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(overscroll: false),
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 28),
                        child: Column(
                          children: [
                            // ── Kartu Ringkasan Dokter ──
                            DoctorSummaryCard(
                              dokter: antrean.dokter,
                              poli: antrean.poli,
                              tanggal: antrean.tanggal,
                              jam: antrean.jam,
                              gedungLokasi: antrean.gedungLokasi,
                            ),

                            // ── Kartu Antrean Aktif + Nomor Live ──
                            ActiveQueueCard(
                              nomorAntrean: antrean.nomorAntrean,
                              nomorDilayani: antrean.nomorSedangDilayani,
                              sisaAntrean: antrean.sisaAntrean,
                              poli: antrean.poli,
                              soundReminderEnabled: _soundReminderEnabled,
                              onSoundReminderChanged: (enabled) {
                                setState(
                                  () => _soundReminderEnabled = enabled,
                                );
                              },
                              onDetailsPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.queueDetail,
                                );
                              },
                            ),

                            // ── Petunjuk Lokasi Ruangan ──
                            RoomDirectionsCard(
                              gedungLokasi: antrean.gedungLokasi,
                            ),

                            // ── Nilai Layanan SIGAP ──
                            const QueueServiceValueCard(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (!widget.embedded)
                AppBottomNav(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) {
                    if (index == 0) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (r) => false,
                      );
                    } else if (index == 3 || index == 4) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.home,
                        (r) => false,
                        arguments: {'initialIndex': index},
                      );
                    } else {
                      setState(() => _selectedIndex = index);
                    }
                  },
                  onDaftarPressed: () {
                    Navigator.pushNamed(context, AppRoutes.pendaftaran);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyQueue(BuildContext context) {
    return ScrollConfiguration(
      behavior:
          ScrollConfiguration.of(context).copyWith(overscroll: false),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const AppEmptyState(
                    icon: Icons.calendar_today_outlined,
                    title: 'Belum Ada Antrean Aktif',
                    message:
                        'Anda belum mendaftar layanan dokter atau belum memiliki antrean aktif hari ini.',
                    circleSize: 64,
                    iconSize: 30,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.pendaftaran);
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: const Text(
                        'Buat Antrean',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.home,
                          (r) => false,
                          arguments: {'initialIndex': 3},
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFF0F2F5),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      child: const Text(
                        'Lihat Jadwal Dokter',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TIPS',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Pastikan Anda mendaftar layanan dokter terlebih dahulu melalui menu "Daftar" untuk mendapatkan nomor antrean.',
                          style: TextStyle(
                            color: Color(0xFF454B59),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const RoomDirectionsCard(
              gedungLokasi: 'Gedung Rawat Jalan Terpadu',
            ),
            const QueueServiceValueCard(),
          ],
        ),
      ),
    );
  }
}
