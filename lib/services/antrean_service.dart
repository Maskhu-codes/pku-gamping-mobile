import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pku_gamping_app/models/antrean_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      gedungLokasi: gedungLokasi,
      sisaAntrean: sisaAntrean,
    );
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
      gedungLokasi: 'Gedung A • Lt. 2',
      dokter: 'dr. Hendra Wicaksono, Sp.PD',
      jam: '07:30 WIB',
      statusAntrean: 'Antrean Berjalan',
      sisaAntrean: 3,
      tanggal: 'Jumat, 9 Oktober 2026',
      jenisJaminan: 'Umum / Pribadi',
    );
    antreanAktif.value = model;
    _saveToStorage(model);
  }

  /// Kosongkan antrean (simulasi kondisi belum ada antrean)
  static void kosongkanAntrean() {
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
}
