import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/services/antrean_service.dart';
import 'package:pku_gamping_app/services/app_feedback_service.dart';
import 'package:pku_gamping_app/services/simrs_service.dart';
import 'jadwal_widgets/jadwal_constants.dart' show DokterJadwal;
import 'pendaftaran_widgets/pendaftaran_confirm_button.dart';
import 'pendaftaran_widgets/pendaftaran_constants.dart';
import 'pendaftaran_widgets/pendaftaran_header.dart';
import 'pendaftaran_widgets/pendaftaran_jadwal_picker.dart';
import 'pendaftaran_widgets/pendaftaran_pasien_card.dart';
import 'pendaftaran_widgets/pendaftaran_pasien_modal.dart';
import 'pendaftaran_widgets/pendaftaran_poli_dokter_selector.dart';
import 'pendaftaran_widgets/pendaftaran_ringkasan_card.dart';
import 'pendaftaran_widgets/pendaftaran_selection_sheets.dart';
import 'pendaftaran_widgets/pendaftaran_success_dialog.dart';

/// Screen Utama Pendaftaran Rawat Jalan RS PKU Gamping (Pasien Mandiri).
///
/// Mengatur seluruh alur pendaftaran mandiri berjenjang:
/// Pasien → Pilih Poli → Pilih Dokter → Pilih Jadwal → Konfirmasi.
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
  bool _isLoadingInitialData = false;
  bool _isLoadingJadwal = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedPasien = _buildSessionPasienModel();
    _muatProfilPasienSesi();
    _initFromInitialData();
  }

  String _resolveRawTglLahirFromSession() {
    final fromSession = SessionManager.fdTglLahir?.trim() ?? '';
    if (fromSession.isNotEmpty) return fromSession;
    final fromPatient = (SessionManager.patientData?['FD_TGL_LAHIR'] ??
            SessionManager.patientData?['fd_tgl_lahir'])
        ?.toString()
        .trim();
    return fromPatient ?? '';
  }

  String _formatTglLahirDisplay(String rawTglLahir) {
    final clean = rawTglLahir.trim();
    if (clean.isEmpty) return '-';
    final formatted = JadwalSlotModel.formatTanggalIndo(clean);
    return formatted.isNotEmpty ? formatted : clean;
  }

  PasienModel _buildSessionPasienModel() {
    final rawNik = (SessionManager.nik ??
            SessionManager.patientData?['FS_KD_IDENTITAS']?.toString() ??
            SessionManager.patientData?['fs_nik']?.toString() ??
            '')
        .trim();
    final rawTglLahir = _resolveRawTglLahirFromSession();
    return PasienModel(
      id: 'p-auth',
      nama: SessionManager.namaPasien,
      noRm: SessionManager.noRm,
      nik: rawNik.isNotEmpty ? rawNik : '-',
      tanggalLahir: _formatTglLahirDisplay(rawTglLahir),
      hubungan: 'Diri Sendiri',
    );
  }

  /// Jika tanggal lahir atau NIK belum tersimpan di sesi lokal, muat otomatis dari `/auth/me`
  Future<void> _muatProfilPasienSesi() async {
    final missingTglLahir = _resolveRawTglLahirFromSession().isEmpty;
    final missingNik = (SessionManager.nik ?? '').trim().isEmpty;
    if ((!missingTglLahir && !missingNik) || !SessionManager.hasValidSession()) {
      return;
    }

    try {
      await SimrsService.getMeProfile();
      if (!mounted || _selectedPasien.id != 'p-auth') return;
      setState(() {
        _selectedPasien = _buildSessionPasienModel();
      });
    } catch (e) {
      debugPrint('[PendaftaranScreen] Gagal menyegarkan profil sesi pasien: $e');
    }
  }

  String _normalizePoliName(String raw) {
    return raw
        .toLowerCase()
        .replaceFirst(RegExp(r'^poli\s+'), '')
        .replaceFirst(RegExp(r'^penyakit\s+'), '')
        .trim();
  }

  PoliModel? _matchPoliByName(List<PoliModel> listPoli, String targetName) {
    final normalizedTarget = _normalizePoliName(targetName);
    if (normalizedTarget.isEmpty) return null;

    // 1. Prioritaskan kecocokan persis setelah normalisasi
    for (final p in listPoli) {
      if (_normalizePoliName(p.nama) == normalizedTarget) {
        return p;
      }
    }
    // 2. Fallback kecocokan substring
    for (final p in listPoli) {
      final normalizedPoli = _normalizePoliName(p.nama);
      if (normalizedPoli.contains(normalizedTarget) ||
          normalizedTarget.contains(normalizedPoli)) {
        return p;
      }
    }
    return null;
  }

  DokterPendaftaranModel? _matchDokterByName(
    List<DokterPendaftaranModel> listDokter,
    String targetName,
  ) {
    final normalizedTarget = targetName.toLowerCase().trim();
    if (normalizedTarget.isEmpty) return null;

    for (final d in listDokter) {
      final normalizedDoc = d.nama.toLowerCase().trim();
      if (normalizedDoc == normalizedTarget ||
          normalizedDoc.contains(normalizedTarget) ||
          normalizedTarget.contains(normalizedDoc)) {
        return d;
      }
    }
    return null;
  }

  /// Menyelaraskan data awal dari API SIMRS asli jika navigasi datang dari JadwalScreen atau shortcut poli
  Future<void> _initFromInitialData() async {
    if (widget.initialDokter == null &&
        (widget.initialPoliNama == null || widget.initialPoliNama!.trim().isEmpty)) {
      return;
    }

    if (mounted) {
      setState(() => _isLoadingInitialData = true);
    }

    try {
      if (widget.initialDokter != null) {
        final doc = widget.initialDokter!;
        final kdLayanan = doc.fsKdLayanan?.trim() ?? '';
        final kdMedis = doc.fsKdPetugasMedis?.trim() ?? '';

        // Jalur 1: initialDokter sudah membawa kode SIMRS asli
        if (kdLayanan.isNotEmpty && kdMedis.isNotEmpty) {
          final poli = PoliModel(
            id: kdLayanan,
            nama: doc.poli,
            icon: Icons.local_hospital_outlined,
          );
          final dokter = DokterPendaftaranModel(
            id: kdMedis,
            nama: doc.nama,
            poliId: kdLayanan,
            spesialisasi: doc.poli,
            fotoUrl: doc.fotoUrl,
            jadwalSlots: const [],
          );
          if (!mounted) return;
          setState(() {
            _selectedPoli = poli;
            _selectedDokter = dokter;
            _isLoadingInitialData = false;
          });
          await _muatJadwalDokter(dokter);
          return;
        }

        // Jalur 2: Fallback pencocokan nama ke API SIMRS (/layanan/list & /dokter/list)
        final listPoli = await PendaftaranService.getListPoli();
        if (!mounted) return;

        final matchedPoli = _matchPoliByName(listPoli, doc.poli);
        if (matchedPoli == null) {
          setState(() => _isLoadingInitialData = false);
          return;
        }

        setState(() => _selectedPoli = matchedPoli);

        final listDokter =
            await PendaftaranService.getListDokter(poliId: matchedPoli.id);
        if (!mounted) return;

        final matchedDokter = _matchDokterByName(listDokter, doc.nama);
        setState(() => _isLoadingInitialData = false);

        if (matchedDokter != null) {
          await _muatJadwalDokter(matchedDokter);
        }
      } else if (widget.initialPoliNama != null &&
          widget.initialPoliNama!.trim().isNotEmpty) {
        final listPoli = await PendaftaranService.getListPoli();
        if (!mounted) return;

        final matchedPoli = _matchPoliByName(listPoli, widget.initialPoliNama!);
        setState(() {
          _selectedPoli = matchedPoli;
          _isLoadingInitialData = false;
        });
      }
    } catch (e) {
      debugPrint('[PendaftaranScreen] Gagal memuat data awal dari SIMRS: $e');
      if (mounted) {
        setState(() => _isLoadingInitialData = false);
      }
    }
  }

  /// Validasi apakah form dasar (poli, dokter, jadwal asli SIMRS) sudah lengkap
  bool get _isBaseFormValid {
    return !_isLoadingInitialData &&
        !_isLoadingJadwal &&
        _selectedPoli != null &&
        _selectedPoli!.id.trim().isNotEmpty &&
        _selectedDokter != null &&
        _selectedDokter!.id.trim().isNotEmpty &&
        _selectedSlot != null &&
        _selectedSlot!.tanggal.trim().isNotEmpty &&
        _selectedSlot!.fnHari.trim().isNotEmpty &&
        _selectedSlot!.canBook &&
        !_selectedSlot!.isPenuh &&
        !_selectedSlot!.isClosed;
  }

  /// Validasi apakah form sudah lengkap dan siap dikonfirmasi
  bool get _isFormValid => _isBaseFormValid;

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
                      isLoadingInitial: _isLoadingInitialData,
                      onTapPoli: _bukaSheetPoli,
                      onTapDokter: _bukaSheetDokter,
                    ),
                    const SizedBox(height: 20),

                    // 3. Jadwal Kunjungan Dokter
                    PendaftaranJadwalPicker(
                      selectedDokter: _selectedDokter,
                      selectedSlot: _selectedSlot,
                      isLoading: _isLoadingJadwal,
                      onSlotSelected: (slot) {
                        setState(() => _selectedSlot = slot);
                      },
                    ),
                    const SizedBox(height: 20),

                    // 4. Ringkasan Pendaftaran
                    PendaftaranRingkasanCard(
                      pasien: _selectedPasien,
                      poli: _selectedPoli,
                      dokter: _selectedDokter,
                      slot: _selectedSlot,
                    ),
                    const SizedBox(height: 24),

                    // 5. Tombol Konfirmasi Pendaftaran
                    PendaftaranConfirmButton(
                      isEnabled: _isFormValid,
                      isLoading: _isSubmitting,
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
        if (dokterBaru.jadwalSlots.isNotEmpty) {
          final availableSlot = dokterBaru.jadwalSlots.where(
            (s) => s.canBook && !s.isPenuh && !s.isClosed,
          );
          setState(() {
            _selectedDokter = dokterBaru;
            _selectedSlot =
                availableSlot.isNotEmpty ? availableSlot.first : null;
            _isLoadingJadwal = false;
          });
          return;
        }
        _muatJadwalDokter(dokterBaru);
      },
    );
  }

  Future<void> _muatJadwalDokter(DokterPendaftaranModel dokterBaru) async {
    final poliId = _selectedPoli?.id ?? dokterBaru.poliId;
    setState(() {
      _selectedDokter = dokterBaru;
      _selectedSlot = null;
      _isLoadingJadwal = true;
    });

    try {
      final slots = await PendaftaranService.getJadwalDokter(
        poliId: poliId,
        dokterId: dokterBaru.id,
      );
      if (!mounted) return;
      final availableSlots = slots.where(
        (s) => s.canBook && !s.isPenuh && !s.isClosed,
      );
      setState(() {
        _selectedDokter = dokterBaru.copyWith(jadwalSlots: slots);
        _selectedSlot = availableSlots.isNotEmpty ? availableSlots.first : null;
        _isLoadingJadwal = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingJadwal = false;
      });
      AppFeedback.showError(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void _handleKonfirmasi() {
    if (_isSubmitting) return;
    if (!_isBaseFormValid) {
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
      onConfirm: _submitBooking,
    );
  }

  Future<void> _submitBooking() async {
    final poli = _selectedPoli;
    final dokter = _selectedDokter;
    final slot = _selectedSlot;
    if (poli == null || dokter == null || slot == null) return;

    setState(() => _isSubmitting = true);
    try {
      final fsMr = SessionManager.fsMr.isNotEmpty
          ? SessionManager.fsMr
          : _selectedPasien.noRm;
      if (fsMr.trim().isEmpty) {
        throw Exception('Nomor Rekam Medis (fs_mr) tidak ditemukan pada sesi.');
      }

      var fdTglLahir = SessionManager.fdTglLahir ??
          (SessionManager.patientData?['FD_TGL_LAHIR'] ??
                  SessionManager.patientData?['fd_tgl_lahir'])
              ?.toString()
              .trim() ??
          '';
      if (fdTglLahir.isEmpty) {
        await SimrsService.getMeProfile();
        fdTglLahir = SessionManager.fdTglLahir ?? '';
      }
      if (fdTglLahir.isEmpty) {
        throw Exception(
          'Tanggal lahir pasien tidak ditemukan. Silakan login ulang.',
        );
      }

      final extractedJam = RegExp(r'\d{2}[:.]\d{2}').firstMatch(slot.jam)?.group(0);
      final jamMulai = slot.jamMulai.isNotEmpty
          ? slot.jamMulai
          : (extractedJam?.replaceAll('.', ':') ??
              slot.jam.split('-').first.replaceAll('WIB', '').trim());
      final sesionPoli = slot.kdSesionPoli.isNotEmpty ? slot.kdSesionPoli : '1';

      if (poli.id.trim().isEmpty) {
        throw Exception('Kode poliklinik tidak valid. Silakan pilih ulang poli tujuan.');
      }
      if (dokter.id.trim().isEmpty) {
        throw Exception('Kode dokter tidak valid. Silakan pilih ulang dokter tujuan.');
      }
      if (slot.tanggal.trim().isEmpty) {
        throw Exception('Tanggal kunjungan tidak valid. Silakan pilih ulang jadwal dokter.');
      }
      if (slot.fnHari.trim().isEmpty) {
        throw Exception('Kode hari jadwal tidak valid. Silakan pilih ulang jadwal dokter.');
      }
      if (jamMulai.trim().isEmpty) {
        throw Exception('Jam praktik tidak valid. Silakan pilih ulang jadwal dokter.');
      }

      final bookingResult = await PendaftaranService.simpanBooking(
        fsMr: fsMr,
        fdTglLahir: fdTglLahir,
        fsKdLayanan: poli.id,
        fsKdPetugasMedis: dokter.id,
        fnHari: slot.fnHari,
        fdTglAntrian: slot.tanggal,
        fsKdSesionPoli: sesionPoli,
        fsJamMulai: jamMulai,
      );

      final nomorAntrean =
          (bookingResult['fn_no_urut'] ?? bookingResult['no_urut'] ?? '')
              .toString()
              .trim();
      if (nomorAntrean.isEmpty) {
        throw Exception('Nomor antrean tidak ditemukan pada respons server.');
      }

      if (!mounted) return;

      // Simpan antrean aktif ke state service terpusat beserta metadata SIMRS
      AntreanService.buatAntrean(
        nomorAntrean: nomorAntrean,
        namaPasien: _selectedPasien.nama,
        noRm: fsMr,
        poli: poli.nama,
        dokter: dokter.nama,
        jam: slot.jam,
        tanggal: slot.hariTanggal,
        jenisJaminan: 'Umum / Pribadi',
        fsKdLayanan: poli.id,
        fsKdPetugasMedis: dokter.id,
        fsKdAntrian: (bookingResult['fs_kd_antrian'] ?? '').toString().trim(),
        noBooking: (bookingResult['no_booking'] ?? '').toString().trim(),
        rawTanggal: slot.tanggal,
      );

      // Tampilkan Modal Dialog Sukses Pendaftaran
      PendaftaranSuccessDialog.show(
        context: context,
        nomorAntrean: nomorAntrean,
        pasien: _selectedPasien,
        poli: poli,
        dokter: dokter,
        slot: slot,
      );
    } catch (e) {
      if (!mounted) return;
      AppFeedback.showError(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
