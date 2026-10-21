import 'package:flutter/material.dart';

/// Model data antrean aktif untuk pasien.
class AntreanAktifModel {
  final String nomorAntrean; // e.g. "A-014"
  final String namaPasien; // e.g. "Dahlan Muda"
  final String noRm; // e.g. "01-88-24-90"
  final String poli; // e.g. "Poli Penyakit Dalam"
  final String gedungLokasi; // e.g. "Gedung A • Lt. 2"
  final String dokter; // e.g. "dr. Hendra Wicaksono, Sp.PD"
  final String jam; // e.g. "07:30 WIB"
  final String statusAntrean; // e.g. "Antrean Berjalan"
  final int sisaAntrean; // e.g. 3
  final String tanggal; // e.g. "Jumat, 9 Oktober 2026"
  final String jenisJaminan; // e.g. "Umum / Pribadi"

  const AntreanAktifModel({
    required this.nomorAntrean,
    required this.namaPasien,
    required this.noRm,
    required this.poli,
    this.gedungLokasi = 'Gedung A • Lt. 2',
    required this.dokter,
    required this.jam,
    this.statusAntrean = 'Antrean Berjalan',
    this.sisaAntrean = 3,
    required this.tanggal,
    this.jenisJaminan = 'Umum / Pribadi',
  });
}

/// Service terpusat pengelola status antrean pasien.
///
/// Menggunakan [ValueNotifier] bawaan Flutter sehingga ringan, reaktif,
/// dan otomatis memperbarui tampilan Beranda & Antrean tanpa reload.
class AntreanService {
  /// Nilai antrean aktif. `null` berarti pasien belum memiliki antrean.
  static final ValueNotifier<AntreanAktifModel?> antreanAktif =
      ValueNotifier<AntreanAktifModel?>(null);

  /// Cek apakah ada antrean aktif
  static bool get adaAntrean => antreanAktif.value != null;

  /// Buat / daftarkan antrean baru dari form pendaftaran
  static void buatAntrean({
    required String nomorAntrean,
    required String namaPasien,
    required String noRm,
    required String poli,
    required String dokter,
    required String jam,
    required String tanggal,
    String jenisJaminan = 'Umum / Pribadi',
    String gedungLokasi = 'Gedung A • Lt. 2',
    int sisaAntrean = 3,
  }) {
    antreanAktif.value = AntreanAktifModel(
      nomorAntrean: nomorAntrean,
      namaPasien: namaPasien,
      noRm: noRm,
      poli: poli,
      dokter: dokter,
      jam: jam,
      tanggal: tanggal,
      jenisJaminan: jenisJaminan,
      gedungLokasi: gedungLokasi,
      sisaAntrean: sisaAntrean,
    );
  }

  /// Pasang antrean dummy untuk kemudahan simulasi/testing
  static void setAntreanDummy() {
    antreanAktif.value = const AntreanAktifModel(
      nomorAntrean: 'A-014',
      namaPasien: 'Dahlan Muda',
      noRm: '01-88-24-90',
      poli: 'Poli Penyakit Dalam',
      gedungLokasi: 'Gedung A • Lt. 2',
      dokter: 'dr. Hendra Wicaksono, Sp.PD',
      jam: '07:30 WIB',
      statusAntrean: 'Antrean Berjalan',
      sisaAntrean: 3,
      tanggal: 'Jumat, 9 Oktober 2026',
      jenisJaminan: 'Umum / Pribadi',
    );
  }

  /// Kosongkan antrean (simulasi kondisi belum ada antrean)
  static void kosongkanAntrean() {
    antreanAktif.value = null;
  }
}
