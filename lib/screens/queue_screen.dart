import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/routes/app_router.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/core/theme/app_colors.dart';
import 'package:pku_gamping_app/screens/queue_widgets/queue_active_card.dart';
import 'package:pku_gamping_app/screens/queue_widgets/queue_brand_header.dart';
import 'package:pku_gamping_app/screens/queue_widgets/queue_doctor_card.dart';
import 'package:pku_gamping_app/screens/queue_widgets/queue_farmasi_card.dart';
import 'package:pku_gamping_app/screens/queue_widgets/queue_service_value_card.dart';
import 'package:pku_gamping_app/screens/queue_widgets/queue_status_stepper_card.dart';
import 'package:pku_gamping_app/services/antrean_service.dart';
import 'package:pku_gamping_app/widgets/app_bottom_nav.dart';
import 'package:pku_gamping_app/widgets/app_empty_state.dart';
import 'package:pku_gamping_app/widgets/guest/guest_guard.dart';
import 'package:pku_gamping_app/widgets/motion/app_motion.dart';

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
    this.pollingInterval = const Duration(seconds: 15),
  });

  final bool embedded;
  final Duration pollingInterval;

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  bool _soundReminderEnabled = false;
  int _selectedIndex = 1;
  bool _isLoading = false;
  Timer? _statusPollingTimer;
  DateTime? _lastSyncedAt;

  String? get _lastUpdatedLabel {
    final ts = _lastSyncedAt;
    if (ts == null) return null;
    final hh = ts.hour.toString().padLeft(2, '0');
    final mm = ts.minute.toString().padLeft(2, '0');
    return 'Diperbarui $hh:$mm WIB';
  }

  void _markSynced() {
    if (!mounted) return;
    final now = DateTime.now();
    if (_lastSyncedAt == null ||
        _lastSyncedAt!.minute != now.minute ||
        _lastSyncedAt!.hour != now.hour) {
      setState(() => _lastSyncedAt = now);
    }
  }

  @override
  void initState() {
    super.initState();
    _muatBookingAktif();
  }

  @override
  void dispose() {
    _stopStatusPolling();
    super.dispose();
  }

  Future<void> _muatBookingAktif() async {
    if (SessionManager.isGuestMode) {
      return;
    }
    if (mounted) {
      setState(() => _isLoading = true);
    }
    try {
      await AntreanService.getBookingAktif();
      await _pollAntreanFarmasi();
      if (mounted) {
        _startStatusPolling();
      }
    } catch (e) {
      debugPrint('[QueueScreen] Gagal memuat booking aktif: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startStatusPolling() {
    _statusPollingTimer?.cancel();
    _pollStatusAntrean();
    _pollAntreanFarmasi();
    _statusPollingTimer = Timer.periodic(
      widget.pollingInterval,
      (_) {
        _pollStatusAntrean();
        _pollAntreanFarmasi();
      },
    );
  }

  void _stopStatusPolling() {
    _statusPollingTimer?.cancel();
    _statusPollingTimer = null;
  }

  Future<void> _pollStatusAntrean() async {
    final antrean = AntreanService.antreanAktif.value;
    if (antrean == null) {
      return;
    }

    final kdLayanan = antrean.fsKdLayanan;
    final kdMedis = antrean.fsKdPetugasMedis;
    if (kdLayanan.isEmpty || kdMedis.isEmpty) return;

    final result = await AntreanService.getStatusAntrean(
      fsKdLayanan: kdLayanan,
      fsKdPetugasMedis: kdMedis,
      fsKdAntrian: antrean.fsKdAntrian.isNotEmpty ? antrean.fsKdAntrian : null,
      fsMr: antrean.noRm.isNotEmpty ? antrean.noRm : null,
      tanggal: antrean.rawTanggal.isNotEmpty ? antrean.rawTanggal : null,
    );
    if (result != null) {
      _markSynced();
    }
  }

  Future<void> _pollAntreanFarmasi() async {
    try {
      await AntreanService.getAntreanFarmasi();
      _markSynced();
    } catch (e) {
      debugPrint('[QueueScreen] Gagal polling antrean farmasi: $e');
    }
  }

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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: _isLoading && AntreanService.antreanAktif.value == null
                      ? const QueueScreenSkeleton(
                          key: ValueKey('queue_loading_skeleton'),
                        )
                      : RefreshIndicator(
                          key: const ValueKey('queue_loaded_content'),
                          onRefresh: _muatBookingAktif,
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
                              sisaAntrean: antrean.sisaAntreanLive,
                              poli: antrean.poli,
                              isUpcomingSchedule: antrean.isUpcomingSchedule,
                              tanggalJadwal: antrean.tanggal,
                              lastUpdatedLabel: _lastUpdatedLabel,
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

                            // ── Stepper Visual Status Antrean Poli (0 - 3) ──
                            QueueStatusStepperCard(
                              currentStatus: antrean.statusPasien,
                            ),

                            // ── Antrean Farmasi (Apotek) Real-time ──
                            ValueListenableBuilder<AntreanFarmasiModel?>(
                              valueListenable: AntreanService.antreanFarmasi,
                              builder: (context, farmasi, _) {
                                return QueueFarmasiCard(
                                  farmasi: farmasi,
                                  onRefresh: _pollAntreanFarmasi,
                                  lastUpdatedLabel: _lastUpdatedLabel,
                                );
                              },
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
                    if (!GuestGuard.check(
                      context,
                      featureName: 'pendaftaran layanan',
                    )) {
                      return;
                    }
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
        physics: const AlwaysScrollableScrollPhysics(),
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
                    title: 'Belum ada booking',
                    message:
                        'Belum ada booking pendaftaran aktif. Silakan pilih layanan dokter dan buat antrean terlebih dahulu.',
                    circleSize: 64,
                    iconSize: 30,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (!GuestGuard.check(context, featureName: 'Pembuatan Antrean')) {
                          return;
                        }
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
            // ── Antrean Farmasi (Apotek) Real-time ──
            ValueListenableBuilder<AntreanFarmasiModel?>(
              valueListenable: AntreanService.antreanFarmasi,
              builder: (context, farmasi, _) {
                return QueueFarmasiCard(
                  farmasi: farmasi,
                  onRefresh: _pollAntreanFarmasi,
                  lastUpdatedLabel: _lastUpdatedLabel,
                );
              },
            ),
            const QueueServiceValueCard(),
          ],
        ),
      ),
    );
  }
}
