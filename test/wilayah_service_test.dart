@Tags(['live_db'])
library;

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/services/wilayah_service.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _RealHttpOverrides();

  setUp(() {
    ApiClient.setBaseUrl(AppConfig.localhostUrl);
  });

  test('getProvinsi() mengembalikan 34 provinsi dari SIMRS', () async {
    final list = await WilayahService.getProvinsi();

    expect(list, isA<List<Map<String, dynamic>>>());
    expect(list.length, 34);

    final first = list.first;
    expect(first.containsKey('FS_KD_PROPINSI'), isTrue);
    expect(first.containsKey('FS_NM_PROPINSI'), isTrue);

    final namaList = list.map((e) => e['FS_NM_PROPINSI'].toString().toUpperCase()).toList();
    expect(namaList, contains('JAWA TENGAH'));
    expect(namaList, contains('DI YOGYAKARTA'));
  });

  test('getKabupaten() memuat daftar kabupaten berdasarkan kode provinsi', () async {
    final list = await WilayahService.getKabupaten('33'); // Jawa Tengah

    expect(list, isA<List<Map<String, dynamic>>>());
    expect(list.isNotEmpty, isTrue);

    final first = list.first;
    expect(first.containsKey('FS_KD_KABUPATEN'), isTrue);
    expect(first.containsKey('FS_NM_KABUPATEN'), isTrue);
  });

  test('getKecamatan() memuat daftar kecamatan berdasarkan kode kabupaten', () async {
    final list = await WilayahService.getKecamatan('3304'); // Banjarnegara

    expect(list, isA<List<Map<String, dynamic>>>());
    expect(list.isNotEmpty, isTrue);

    final first = list.first;
    expect(first.containsKey('FS_KD_KECAMATAN'), isTrue);
    expect(first.containsKey('FS_NM_KECAMATAN'), isTrue);
  });

  test('getKelurahan() memuat daftar kelurahan berdasarkan kode kecamatan', () async {
    final list = await WilayahService.getKelurahan('3304001');

    expect(list, isA<List<Map<String, dynamic>>>());
    expect(list.isNotEmpty, isTrue);

    final first = list.first;
    expect(first.containsKey('FS_KD_KELURAHAN'), isTrue);
    expect(first.containsKey('FS_NM_KELURAHAN'), isTrue);
  });

  test('getDetailKelurahan() memuat detail lengkap alamat dari SIMRS', () async {
    final detail = await WilayahService.getDetailKelurahan('3304001001');

    expect(detail, isNotNull);
    expect(detail!['FS_NM_KELURAHAN'], 'BANYURIPAN');
    expect(detail['FS_NM_KECAMATAN'], 'BAYAT');
    expect(detail['FS_NM_KABUPATEN'], 'BANJARNEGARA');
    expect(detail['FS_NM_PROPINSI'], 'JAWA TENGAH');
  });
}
