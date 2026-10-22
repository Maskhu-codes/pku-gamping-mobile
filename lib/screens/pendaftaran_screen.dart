import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/services/antrean_service.dart';
import 'package:pku_gamping_app/services/app_feedback_service.dart';
import 'jadwal_widgets/jadwal_constants.dart' show DokterJadwal;
import 'pendaftaran_widgets/pendaftaran_confirm_button.dart';
import 'pendaftaran_widgets/pendaftaran_constants.dart';
import 'pendaftaran_widgets/pendaftaran_header.dart';
import 'pendaftaran_widgets/pendaftaran_jadwal_picker.dart';
import 'pendaftaran_widgets/pendaftaran_jaminan_selector.dart';
import 'pendaftaran_widgets/pendaftaran_pasien_card.dart';
import 'pendaftaran_widgets/pendaftaran_pasien_modal.dart';
import 'pendaftaran_widgets/pendaftaran_poli_dokter_selector.dart';
import 'pendaftaran_widgets/pendaftaran_ringkasan_card.dart';
import 'pendaftaran_widgets/pendaftaran_selection_sheets.dart';
import 'pendaftaran_widgets/pendaftaran_success_dialog.dart';

/// Screen Utama Pendaftaran Rawat Jalan RS PKU Gamping.
///
/// Mengatur seluruh alur pendaftaran berjenjang:
/// Pasien → Pilih Poli → Pilih Dokter → Pilih Jadwal → Pilih Jaminan → Konfirmasi.
/// Layar ini tidak memiliki bottom navigation bar (fokus pendaftaran terdedikasi).
class PendaftaranScreen extends StatefulWidget {
  const PendaftaranScreen({
    super.key,
    this.initialDokter,
    this.initialPoliNama,
  });

  /// Parameter opsional jika pasien masuk dari kartu dokter di [JadwalScreen].
  final DokterJadwal? initialDokter;
  final String? initialPoliNama;

  @override
  State<PendaftaranScreen> createState() => _PendaftaranScreenState();
}

class _PendaftaranScreenState extends State<PendaftaranScreen> {
  // State Form Pendaftaran
  late PasienModel _selectedPasien;
  PoliModel? _selectedPoli;
  DokterPendaftaranModel? _selectedDokter;
  JadwalSlotModel? _selectedSlot;
  JenisJaminan _selectedJaminan = JenisJaminan.umumPribadi;

  @override
  void initState() {
    super.initState();
    _selectedPasien = PasienModel(
      id: 'p-auth',
      nama: SessionManager.namaPasien,
      noRm: SessionManager.noRm,
      nik: SessionManager.nik ?? '3471041234560001',
      tanggalLahir: '24 Mei 1990',
      hubungan: 'Diri Sendiri',
    );
    _initFromInitialData();
  }

  /// Menyelaraskan data awal jika navigasi datang dari JadwalScreen
  void _initFromInitialData() {
    if (widget.initialDokter != null) {
      final doc = widget.initialDokter!;
      // Cari Poli yang cocok
      try {
        _selectedPoli = PendaftaranDummyData.listPoli.firstWhere(
          (p) =>
              p.nama.toLowerCase().contains(doc.poli.toLowerCase()) ||
              doc.poli.toLowerCase().contains(p.nama.toLowerCase()),
        );
      } catch (_) {
        _selectedPoli = PendaftaranDummyData.listPoli.first;
      }

      // Cari Dokter yang cocok
      try {
        _selectedDokter = PendaftaranDummyData.listDokter.firstWhere(
          (d) =>
              d.nama.toLowerCase().contains(doc.nama.toLowerCase()) ||
              doc.nama.toLowerCase().contains(d.nama.toLowerCase()),
        );
      } catch (_) {
        // Fallback ke dokter pertama di poli tersebut
        _selectedDokter = PendaftaranDummyData.listDokter.firstWhere(
          (d) => d.poliId == _selectedPoli?.id,
          orElse: () => PendaftaranDummyData.listDokter.first,
        );
      }

      // Pilih slot pertama yang tersedia secara otomatis
      if (_selectedDokter != null && _selectedDokter!.jadwalSlots.isNotEmpty) {
        _selectedSlot = _selectedDokter!.jadwalSlots.firstWhere(
          (s) => !s.isPenuh,
          orElse: () => _selectedDokter!.jadwalSlots.first,
        );
      }
    } else if (widget.initialPoliNama != null) {
      try {
        _selectedPoli = PendaftaranDummyData.listPoli.firstWhere(
          (p) => p.nama
              .toLowerCase()
              .contains(widget.initialPoliNama!.toLowerCase()),
        );
      } catch (_) {}
    }
  }

  /// Validasi apakah form sudah lengkap dan siap dikonfirmasi
  bool get _isFormValid {
    return _selectedPoli != null &&
        _selectedDokter != null &&
        _selectedSlot != null &&
        !_selectedSlot!.isPenuh;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPendaftaranPageBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header Navigasi Atas (Back button, Title, Subtitle, Berkas) ──
            PendaftaranHeader(
              onBack: () => Navigator.pop(context),
              onActionTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Membuka riwayat berkas pendaftaran...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

            // ── Isi Form Scrollable ──
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Kartu Pasien & Ganti Pasien
                    PendaftaranPasienCard(
                      pasien: _selectedPasien,
                      onGantiPasien: _bukaModalGantiPasien,
                    ),
                    const SizedBox(height: 20),

                    // 2. Dropdown Pemilihan Poli & Dokter
                    PendaftaranPoliDokterSelector(
                      selectedPoli: _selectedPoli,
                      selectedDokter: _selectedDokter,
                      onTapPoli: _bukaSheetPoli,
                      onTapDokter: _bukaSheetDokter,
                    ),
                    const SizedBox(height: 20),

                    // 3. Jadwal Kunjungan Dokter
                    PendaftaranJadwalPicker(
                      selectedDokter: _selectedDokter,
                      selectedSlot: _selectedSlot,
                      onSlotSelected: (slot) {
                        setState(() => _selectedSlot = slot);
                      },
                    ),
                    const SizedBox(height: 20),

                    // 4. Jaminan Pasien (Umum vs Relasi & Banner BPJS)
                    PendaftaranJaminanSelector(
                      selectedJaminan: _selectedJaminan,
                      onJaminanChanged: (jaminan) {
                        setState(() => _selectedJaminan = jaminan);
                      },
                    ),
                    const SizedBox(height: 20),

                    // 5. Ringkasan Pendaftaran
                    PendaftaranRingkasanCard(
                      pasien: _selectedPasien,
                      poli: _selectedPoli,
                      dokter: _selectedDokter,
                      slot: _selectedSlot,
                      jaminan: _selectedJaminan,
                    ),
                    const SizedBox(height: 24),

                    // 6. Tombol Konfirmasi Pendaftaran
                    PendaftaranConfirmButton(
                      isEnabled: _isFormValid,
                      onPressed: _handleKonfirmasi,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Handlers Interaksi ──

  void _bukaModalGantiPasien() {
    PendaftaranPasienModal.show(
      context: context,
      selectedPasien: _selectedPasien,
      onPasienChanged: (pasienBaru) {
        setState(() => _selectedPasien = pasienBaru);
      },
    );
  }

  void _bukaSheetPoli() {
    PoliSelectionSheet.show(
      context: context,
      selectedPoli: _selectedPoli,
      onPoliSelected: (poliBaru) {
        setState(() {
          _selectedPoli = poliBaru;
          // Reset dokter dan jadwal jika poli berubah
          _selectedDokter = null;
          _selectedSlot = null;
        });
      },
    );
  }

  void _bukaSheetDokter() {
    if (_selectedPoli == null) {
      _bukaSheetPoli();
      return;
    }

    DokterSelectionSheet.show(
      context: context,
      selectedPoli: _selectedPoli!,
      selectedDokter: _selectedDokter,
      onDokterSelected: (dokterBaru) {
        setState(() {
          _selectedDokter = dokterBaru;
          // Otomatis pilih slot pertama yang masih tersedia
          _selectedSlot = dokterBaru.jadwalSlots.firstWhere(
            (s) => !s.isPenuh,
            orElse: () => dokterBaru.jadwalSlots.first,
          );
        });
      },
    );
  }

  void _handleKonfirmasi() {
    if (!_isFormValid) {
      AppFeedback.showError(
        context,
        message: 'Lengkapi pilihan poli, dokter, dan jadwal kunjungan terlebih dahulu.',
      );
      return;
    }

    AppFeedback.showConfirmation(
      context,
      title: 'Konfirmasi',
      message: 'Apakah Anda yakin ingin melanjutkan tindakan ini?',
      confirmText: 'Lanjutkan',
      cancelText: 'Batal',
      onConfirm: () {
        // Simpan antrean aktif ke state service terpusat
        AntreanService.buatAntrean(
          nomorAntrean: 'A-014',
          namaPasien: _selectedPasien.nama,
          noRm: _selectedPasien.noRm,
          poli: _selectedPoli!.nama,
          dokter: _selectedDokter!.nama,
          jam: _selectedSlot!.jam,
          tanggal: _selectedSlot!.hariTanggal,
          jenisJaminan: _selectedJaminan.label,
        );

        // Tampilkan Modal Dialog Sukses Pendaftaran
        PendaftaranSuccessDialog.show(
          context: context,
          nomorAntrean: 'A-014',
          pasien: _selectedPasien,
          poli: _selectedPoli!,
          dokter: _selectedDokter!,
          slot: _selectedSlot!,
          jaminan: _selectedJaminan,
        );
      },
    );
  }
}
