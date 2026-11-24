import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/data/wilayah_data.dart';

/// Model item wilayah (kode + nama) yang juga kompatibel sebagai `Map<String, dynamic>`
class WilayahItem extends MapView<String, dynamic> {
  final String kode;
  final String nama;

  WilayahItem({required this.kode, required this.nama})
      : super({
          'kode': kode,
          'nama': nama,
          'FS_KD_PROPINSI': kode,
          'FS_NM_PROPINSI': nama,
          'FS_KD_KABUPATEN': kode,
          'FS_NM_KABUPATEN': nama,
          'FS_KD_KECAMATAN': kode,
          'FS_NM_KECAMATAN': nama,
          'FS_KD_KELURAHAN': kode,
          'FS_NM_KELURAHAN': nama,
        });

  Map<String, dynamic> toJson() => {'kode': kode, 'nama': nama};

  factory WilayahItem.fromJson(Map<String, dynamic> json) {
    final k = (json['kode'] ??
            json['FS_KD_PROPINSI'] ??
            json['FS_KD_KABUPATEN'] ??
            json['FS_KD_KECAMATAN'] ??
            json['FS_KD_KELURAHAN'] ??
            '')
        .toString();
    final n = (json['nama'] ??
            json['FS_NM_PROPINSI'] ??
            json['FS_NM_KABUPATEN'] ??
            json['FS_NM_KECAMATAN'] ??
            json['FS_NM_KELURAHAN'] ??
            '')
        .toString();
    return WilayahItem(kode: k, nama: n);
  }

  @override
  String toString() => nama;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WilayahItem &&
          runtimeType == other.runtimeType &&
          kode == other.kode;

  @override
  int get hashCode => kode.hashCode;
}

/// Service untuk fetch data wilayah bertingkat dari backend SIMRS.
///
/// Endpoints:
/// - GET /wilayah/provinsi                        → Daftar provinsi
/// - GET /wilayah/kabupaten?fs_kd_propinsi=...     → Daftar kabupaten/kota
/// - GET /wilayah/kecamatan?fs_kd_kabupaten=...    → Daftar kecamatan
/// - GET /wilayah/kelurahan?fs_kd_kecamatan=...    → Daftar kelurahan/desa
/// - GET /wilayah/detail?fs_kd_kelurahan=...       → Detail lengkap
class WilayahService {
  WilayahService._();

  static Dio get _dio => ApiClient.dio;

  // ── Cache in-memory hanya untuk provinsi ──
  static List<WilayahItem>? _cachedProvinsi;

  /// Ambil daftar provinsi (dengan fallback offline jika backend offline)
  static Future<List<WilayahItem>> getProvinsi() async {
    if (_cachedProvinsi != null && _cachedProvinsi!.isNotEmpty) {
      return _cachedProvinsi!;
    }

    try {
      final response = await _dio.get('/wilayah/provinsi');
      final items = _parseList(response.data, 'FS_KD_PROPINSI', 'FS_NM_PROPINSI');
      if (items.isNotEmpty) {
        _cachedProvinsi = items;
        return items;
      }
    } catch (e) {
      debugPrint('[WilayahService] getProvinsi error: $e');
    }

    // Fallback data lokal jika API gagal/kosong
    final fallback = WilayahData.provinsiList
        .map((p) => WilayahItem(kode: p, nama: toTitleCase(p)))
        .toList();
    _cachedProvinsi = fallback;
    return fallback;
  }

  /// Ambil daftar kabupaten/kota berdasarkan provinsi (kode atau nama).
  /// Menampilkan data murni dari API database SIMRS.
  static Future<List<WilayahItem>> getKabupaten(String kdPropinsi, [String? nmPropinsi]) async {
    if (kdPropinsi.isEmpty && (nmPropinsi == null || nmPropinsi.isEmpty)) return [];

    try {
      final response = await _dio.get(
        '/wilayah/kabupaten',
        queryParameters: {'fs_kd_propinsi': kdPropinsi},
      );
      final apiItems = _parseList(response.data, 'FS_KD_KABUPATEN', 'FS_NM_KABUPATEN');
      if (apiItems.isNotEmpty) {
        return apiItems;
      }
    } catch (e) {
      debugPrint('[WilayahService] getKabupaten API error: $e');
    }

    // Fallback data lokal hanya jika API/database kosong atau error koneksi
    final queryName = (nmPropinsi != null && nmPropinsi.trim().isNotEmpty) ? nmPropinsi.trim() : kdPropinsi.trim();
    final localNames = WilayahData.getKabupatenByProvinsi(queryName);
    return localNames.map((k) => WilayahItem(kode: k, nama: toTitleCase(k))).toList();
  }

  /// Ambil daftar kecamatan berdasarkan kode kabupaten (murni dari API database SIMRS)
  static Future<List<WilayahItem>> getKecamatan(String kdKabupaten, [String? nmKabupaten]) async {
    if (kdKabupaten.isEmpty && (nmKabupaten == null || nmKabupaten.isEmpty)) return [];

    try {
      final response = await _dio.get(
        '/wilayah/kecamatan',
        queryParameters: {'fs_kd_kabupaten': kdKabupaten},
      );
      final apiItems = _parseList(response.data, 'FS_KD_KECAMATAN', 'FS_NM_KECAMATAN');
      if (apiItems.isNotEmpty) {
        return apiItems;
      }
    } catch (e) {
      debugPrint('[WilayahService] getKecamatan API error: $e');
    }

    // Fallback data lokal hanya jika API/database kosong atau error koneksi
    final queryName = (nmKabupaten != null && nmKabupaten.trim().isNotEmpty) ? nmKabupaten.trim() : kdKabupaten.trim();
    final localNames = WilayahData.getKecamatanByKabupaten(queryName);
    return localNames.map((k) => WilayahItem(kode: k, nama: toTitleCase(k))).toList();
  }

  /// Ambil daftar kelurahan/desa berdasarkan kode kecamatan (murni dari API database SIMRS)
  static Future<List<WilayahItem>> getKelurahan(String kdKecamatan, [String? nmKecamatan]) async {
    if (kdKecamatan.isEmpty && (nmKecamatan == null || nmKecamatan.isEmpty)) return [];

    try {
      final response = await _dio.get(
        '/wilayah/kelurahan',
        queryParameters: {'fs_kd_kecamatan': kdKecamatan},
      );
      final apiItems = _parseList(response.data, 'FS_KD_KELURAHAN', 'FS_NM_KELURAHAN');
      if (apiItems.isNotEmpty) {
        return apiItems;
      }
    } catch (e) {
      debugPrint('[WilayahService] getKelurahan API error: $e');
    }

    // Fallback data lokal hanya jika API/database kosong atau error koneksi
    final queryName = (nmKecamatan != null && nmKecamatan.trim().isNotEmpty) ? nmKecamatan.trim() : kdKecamatan.trim();
    final localNames = WilayahData.getKelurahanByKecamatan(queryName);
    return localNames.map((k) => WilayahItem(kode: k, nama: toTitleCase(k))).toList();
  }

  /// Ambil detail wilayah lengkap dari kode kelurahan
  static Future<Map<String, dynamic>?> getDetail(String kdKelurahan) async {
    if (kdKelurahan.isEmpty) return null;

    try {
      final response = await _dio.get(
        '/wilayah/detail',
        queryParameters: {'fs_kd_kelurahan': kdKelurahan},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        if (data['status'] == true && data['data'] is Map<String, dynamic>) {
          return data['data'] as Map<String, dynamic>;
        }
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('[WilayahService] getDetail error: $e');
      return null;
    }
  }

  /// Alias getDetailKelurahan untuk kompatibilitas
  static Future<Map<String, dynamic>?> getDetailKelurahan(String kdKelurahan) =>
      getDetail(kdKelurahan);

  /// Bersihkan seluruh cache
  static void clearCache() {
    _cachedProvinsi = null;
  }

  static String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      final upper = word.toUpperCase();
      if (upper == 'DI' || upper == 'DKI' || upper == 'DIY') return 'D.I.';
      if (upper == 'KAB' || upper == 'KAB.') return 'Kab.';
      if (upper == 'KODYA') return 'Kota';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // ── Helper: parse response list ──
  static List<WilayahItem> _parseList(
    dynamic responseData,
    String kodeKey,
    String namaKey,
  ) {
    List<dynamic> rawList;

    if (responseData is Map<String, dynamic>) {
      final dataField = responseData['data'];
      if (dataField is List) {
        rawList = dataField;
      } else {
        return [];
      }
    } else if (responseData is List) {
      rawList = responseData;
    } else {
      return [];
    }

    final items = <WilayahItem>[];
    final seen = <String>{};
    for (final item in rawList) {
      if (item is Map<String, dynamic>) {
        final kode = (item[kodeKey] ?? item[kodeKey.toLowerCase()] ?? '').toString().trim();
        final rawNama = (item[namaKey] ?? item[namaKey.toLowerCase()] ?? '').toString().trim();
        if (kode.isNotEmpty && rawNama.isNotEmpty && seen.add(kode)) {
          items.add(WilayahItem(kode: kode, nama: toTitleCase(rawNama)));
        }
      }
    }
    return items;
  }
}
