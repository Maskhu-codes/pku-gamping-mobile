import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pku_gamping_app/models/antrean_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:pku_gamping_app/services/antrean_api_service.dart';
import 'package:pku_gamping_app/data/status_antrean_model.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';

export 'package:pku_gamping_app/models/antrean_model.dart';

/// Service terpusat pengelola status antrean pasien dengan persistensi lokal.
///
/// Menggunakan [ValueNotifier] bawaan Flutter yang reaktif dan terhubung
/// secara persisten ke [SharedPreferences] agar data antrean tidak hilang saat
/// aplikasi ditutup.
class AntreanService {
  static const String _keyStorage = 'pku_antrean_aktif_storage';

  /// Nilai antrean aktif. `null` berarti pasien belum memiliki antrean.
  static final ValueNotifier<AntreanAktifModel?> antreanAktif =
      ValueNotifier<AntreanAktifModel?>(null);

  /// Cek apakah ada antrean aktif
  static bool get adaAntrean => antreanAktif.value != null;

  /// Memulihkan antrean yang tersimpan di SharedPreferences
  static Future<void> initFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyStorage);
      if (raw != null && raw.isNotEmpty) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        antreanAktif.value = AntreanAktifModel.fromJson(map);
      }
    } catch (e) {
      debugPrint('[AntreanService] Gagal memuat antrean lokal: $e');
    }
  }

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
    String statusAntreanText = 'Antrean Berjalan',
    int sisaAntrean = 3,
  }) {
    final model = AntreanAktifModel(
      nomorAntrean: nomorAntrean,
      namaPasien: namaPasien,
      noRm: noRm,
      poli: poli,
      dokter: dokter,
      jam: jam,
      tanggal: tanggal,
      jenisJaminan: jenisJaminan,
      statusAntrean: statusAntreanText,
      sisaAntrean: sisaAntrean,
    );
    statusAntrean.value = null;
    antreanTerverifikasiApi.value = false;
    errorApi.value = null;

    antreanAktif.value = model;
    _saveToStorage(model);
  }

  /// Pasang antrean dummy untuk kemudahan simulasi/testing
  static void setAntreanDummy() {
    const model = AntreanAktifModel(
      nomorAntrean: 'A-014',
      namaPasien: 'Dahlan Muda',
      noRm: '01-88-24-90',
      poli: 'Poli Penyakit Dalam',
      dokter: 'dr. Hendra Wicaksono, Sp.PD',
      jam: '07:30 WIB',
      statusAntrean: 'Antrean Berjalan',
      sisaAntrean: 3,
      tanggal: 'Jumat, 9 Oktober 2026',
      jenisJaminan: 'Umum / Pribadi',
    );
    statusAntrean.value = null;
    antreanTerverifikasiApi.value = false;
    errorApi.value = null;

    antreanAktif.value = model;
    _saveToStorage(model);
  }

  /// Kosongkan antrean (simulasi kondisi belum ada antrean)
  static void kosongkanAntrean() {
    statusAntrean.value = null;
    antreanTerverifikasiApi.value = false;
    errorApi.value = null;

    antreanAktif.value = null;
    _removeFromStorage();
  }

  static Future<void> _saveToStorage(AntreanAktifModel model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyStorage, jsonEncode(model.toJson()));
    } catch (_) {}
  }

  static Future<void> _removeFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyStorage);
    } catch (_) {}
  }

  static final ValueNotifier<bool> isLoadingApi = ValueNotifier<bool>(false);

  static final ValueNotifier<String?> errorApi = ValueNotifier<String?>(null);

  
static Future<void> refreshAntreanDariApi() async {
  debugPrint('=== REFRESH ANTREAN DIPANGGIL ===');

  if (isLoadingApi.value) return;

  final token = SessionManager.token;

  debugPrint('Status login: ${SessionManager.isLoggedIn}');
  debugPrint('Token tersedia: ${token?.isNotEmpty ?? false}');


  if (!SessionManager.isLoggedIn ||
      token == null ||
      token.isEmpty) {
    errorApi.value = 'Sesi login tidak tersedia.';
    return;
  }

  isLoadingApi.value = true;
  errorApi.value = null;

  try {
    // 1. Ambil booking aktif dari backend.
    final booking = await AntreanApiService.getBookingAktifModel();

    // 2. Backend berhasil merespons, tetapi tidak ada booking.
    if (booking == null) {
      debugPrint('Tidak ada booking aktif dari API.');

      antreanAktif.value = null;
      await _removeFromStorage();

      statusAntrean.value = null;
      antreanTerverifikasiApi.value = true;

      return;
    }

    // 3. Tampilkan data booking dari backend.
    antreanAktif.value = booking;
    await _saveToStorage(booking);

    statusAntrean.value = null;
    antreanTerverifikasiApi.value = false;

    // 4. Periksa kelengkapan kode layanan dan dokter.
    final kodeLayanan = booking.kodeLayanan;
    final kodeDokter = booking.kodeDokter;

    if (kodeLayanan == null ||
        kodeLayanan.isEmpty ||
        kodeDokter == null ||
        kodeDokter.isEmpty) {
      errorApi.value =
          'Data kode layanan atau dokter belum tersedia.';

      return;
    }

    // 5. Ambil status antrean dari backend.
    final status = await AntreanApiService.getStatusAntreanModel(
      kodeLayanan: kodeLayanan,
      kodeDokter: kodeDokter,
      nomorAntrean: booking.nomorAntrean.isNotEmpty
          ? booking.nomorAntrean
          : null,
      tanggal: booking.tanggal.isNotEmpty
          ? booking.tanggal
          : null,
    );

    // 6. Simpan status antrean terbaru.
    statusAntrean.value = status;
    antreanTerverifikasiApi.value = true;

    debugPrint('Booking aktif: ${booking.nomorAntrean}');
    debugPrint('Sedang dilayani: ${status.sedangDilayani}');
    debugPrint('Status pasien: ${status.statusPasien}');
  } catch (e) {
    errorApi.value = e.toString();

    debugPrint('Gagal refresh antrean dari API: $e');
  } finally {
    isLoadingApi.value = false;
  }
}


  static final ValueNotifier<StatusAntreanModel?> statusAntrean =
      ValueNotifier<StatusAntreanModel?>(null);

  static Future<void> refreshStatusAntrean({
    required String kodeLayanan,
    required String kodeDokter,
    String? nomorAntrean,
    String? tanggal,
  }) async {
    try {
      final hasil = await AntreanApiService.getStatusAntreanModel(
        kodeLayanan: kodeLayanan,
        kodeDokter: kodeDokter,
        nomorAntrean: nomorAntrean,
        tanggal: tanggal,
      );

      statusAntrean.value = hasil;
      antreanTerverifikasiApi.value = true;
      errorApi.value = null;
    } catch (e) {
      antreanTerverifikasiApi.value = false;
      statusAntrean.value = null;
      errorApi.value = e.toString();
      debugPrint('Gagal mengambil status antrean: $e');
    }
  }

  static final ValueNotifier<bool> antreanTerverifikasiApi =
      ValueNotifier<bool>(false);
}
