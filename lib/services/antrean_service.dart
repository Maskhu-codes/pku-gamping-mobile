import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/models/antrean_model.dart';
import 'package:pku_gamping_app/models/farmasi_antrean_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:pku_gamping_app/models/antrean_model.dart';
export 'package:pku_gamping_app/models/farmasi_antrean_model.dart';

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

  /// Nilai antrean farmasi/apotek real-time.
  static final ValueNotifier<AntreanFarmasiModel?> antreanFarmasi =
      ValueNotifier<AntreanFarmasiModel?>(null);

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
    int sisaAntrean = 0,
    String fsKdLayanan = '',
    String fsKdPetugasMedis = '',
    String fsKdAntrian = '',
    String noBooking = '',
    String rawTanggal = '',
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
      fsKdLayanan: fsKdLayanan,
      fsKdPetugasMedis: fsKdPetugasMedis,
      fsKdAntrian: fsKdAntrian,
      noBooking: noBooking,
      rawTanggal: rawTanggal,
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
    antreanFarmasi.value = null;
    _removeFromStorage();
  }

  /// Mengambil booking aktif dari backend SIMRS (`GET /booking/aktif`).
  ///
  /// Jika pasien memiliki antrean aktif pada hari ini/ke depan, mengembalikan
  /// [AntreanAktifModel] dan memperbarui state reaktif [antreanAktif].
  /// Jika tidak ada pendaftaran aktif (404 Not Found), mengosongkan antrean
  /// dan mengembalikan `null`.
  static Future<AntreanAktifModel?> getBookingAktif() async {
    if (!SessionManager.hasValidSession()) {
      kosongkanAntrean();
      return null;
    }

    try {
      final response = await ApiClient.dio.get('/booking/aktif');
      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        final rawData = body['data'];
        if (body['status'] == true && rawData is Map<String, dynamic>) {
          final data = Map<String, dynamic>.from(rawData);
          if ((data['namaPasien'] == null || data['namaPasien'].toString().isEmpty) &&
              SessionManager.namaPasien.isNotEmpty) {
            data['namaPasien'] = SessionManager.namaPasien;
          }
          if ((data['fs_mr'] == null || data['fs_mr'].toString().isEmpty) &&
              SessionManager.fsMr.isNotEmpty) {
            data['fs_mr'] = SessionManager.fsMr;
          }

          final model = AntreanAktifModel.fromBookingJson(data);
          antreanAktif.value = model;
          await _saveToStorage(model);
          return model;
        }
      }
      kosongkanAntrean();
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404 ||
          e.response?.statusCode == 400 ||
          e.response?.data?['status'] == false) {
        kosongkanAntrean();
        return null;
      }
      rethrow;
    } catch (_) {
      kosongkanAntrean();
      return null;
    }
  }

  static Future<void> _saveToStorage(AntreanAktifModel model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyStorage, jsonEncode(model.toJson()));
    } catch (_) {}
  }

  /// Mengambil status alur pelayanan dan nomor yang sedang dilayani dari backend SIMRS (`GET /antrean/status`).
  ///
  /// Parameter:
  /// - [fsKdLayanan]: kode poli (e.g. `P003`)
  /// - [fsKdPetugasMedis]: kode dokter (e.g. `S379`)
  /// - [fsKdAntrian]: nomor/kode antrean pasien (e.g. `AN202611130001`)
  /// - [fsMr]: nomor rekam medis pasien
  /// - [tanggal]: tanggal periksa format YYYY-MM-DD
  ///
  /// Memperbarui [statusPasien] (0: Booking, 1: Triage, 2: Poli, 3: Selesai)
  /// dan [sedangDilayaniLive] pada [antreanAktif].
  static Future<Map<String, dynamic>?> getStatusAntrean({
    required String fsKdLayanan,
    required String fsKdPetugasMedis,
    String? fsKdAntrian,
    String? fsMr,
    String? tanggal,
  }) async {
    final query = <String, dynamic>{
      'fs_kd_layanan': fsKdLayanan.trim(),
      'fs_kd_petugas_medis': fsKdPetugasMedis.trim(),
    };
    if (fsKdAntrian != null && fsKdAntrian.trim().isNotEmpty) {
      query['fs_kd_antrian'] = fsKdAntrian.trim();
    }
    if (fsMr != null && fsMr.trim().isNotEmpty) {
      query['fs_mr'] = fsMr.trim();
    }
    if (tanggal != null && tanggal.trim().isNotEmpty) {
      query['tanggal'] = tanggal.trim();
    }

    try {
      final response = await ApiClient.dio.get(
        '/antrean/status',
        queryParameters: query,
      );

      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        final rawData = body['data'];
        if (body['status'] == true && rawData is Map<String, dynamic>) {
          final statusPasien =
              int.tryParse(rawData['status_pasien']?.toString() ?? '0') ?? 0;
          final sedangDilayani = rawData['sedang_dilayani']?.toString();

          final current = antreanAktif.value;
          if (current != null) {
            final updatedSisaAntrean = AntreanAktifModel.hitungSisaAntrean(
              nomorAntrean: current.nomorAntrean,
              sedangDilayani: sedangDilayani,
              fallback: current.sisaAntrean,
            );
            final updated = current.copyWith(
              statusPasien: statusPasien,
              sedangDilayaniLive: sedangDilayani,
              sisaAntrean: updatedSisaAntrean,
            );
            antreanAktif.value = updated;
            await _saveToStorage(updated);
          }

          return {
            'status_pasien': statusPasien,
            'sedang_dilayani': sedangDilayani,
          };
        }
      }
      return null;
    } on DioException catch (e) {
      debugPrint('[AntreanService] Gagal memuat status antrean: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('[AntreanService] Error getStatusAntrean: $e');
      return null;
    }
  }

  /// Mengambil data nomor antrean farmasi/apotek dari backend SIMRS (`GET /farmasi/antrean`).
  ///
  /// Response backend membagi antrean ke dalam dua kelompok:
  /// - `racik`: antrean obat racik (kode antrean B & D)
  /// - `non_racik`: antrean obat non-racik (kode antrean A & C)
  ///
  /// Mengembalikan [AntreanFarmasiModel] dan memperbarui state reaktif [antreanFarmasi].
  static Future<AntreanFarmasiModel> getAntreanFarmasi() async {
    try {
      final response = await ApiClient.dio.get('/farmasi/antrean');
      if (response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        final rawData = body['data'];
        if (body['status'] == true && rawData is Map<String, dynamic>) {
          final model = AntreanFarmasiModel.fromJson(
            Map<String, dynamic>.from(rawData),
          );
          antreanFarmasi.value = model;
          return model;
        }
      }
      const fallback = AntreanFarmasiModel();
      antreanFarmasi.value = fallback;
      return fallback;
    } on DioException catch (e) {
      debugPrint('[AntreanService] Gagal memuat antrean farmasi: ${e.message}');
      const fallback = AntreanFarmasiModel();
      antreanFarmasi.value = fallback;
      return fallback;
    } catch (e) {
      debugPrint('[AntreanService] Error getAntreanFarmasi: $e');
      const fallback = AntreanFarmasiModel();
      antreanFarmasi.value = fallback;
      return fallback;
    }
  }

  static Future<void> _removeFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyStorage);
    } catch (_) {}
  }
}
