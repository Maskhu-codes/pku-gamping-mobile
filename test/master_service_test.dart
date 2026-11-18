@Tags(['live_db'])
library;

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/services/master_service.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _RealHttpOverrides();

  setUp(() {
    ApiClient.setBaseUrl(AppConfig.localhostUrl);
  });

  test('getAgama() mengembalikan 7 data agama dari SIMRS', () async {
    final list = await MasterService.getAgama();

    expect(list, isA<List<Map<String, dynamic>>>());
    expect(list.length, 7);

    final first = list.first;
    expect(first.containsKey('FS_KD_AGAMA'), isTrue);
    expect(first.containsKey('FS_NM_AGAMA'), isTrue);

    final namaAgama = list.map((e) => e['FS_NM_AGAMA'].toString().toUpperCase()).toList();
    expect(namaAgama, contains('ISLAM'));
    expect(namaAgama, contains('KRISTEN'));
    expect(namaAgama, contains('KATHOLIK'));
    expect(namaAgama, contains('HINDU'));
    expect(namaAgama, contains('BUDHA'));
  });

  test('getPekerjaan() mengembalikan data pekerjaan dari SIMRS', () async {
    final list = await MasterService.getPekerjaan();

    expect(list, isA<List<Map<String, dynamic>>>());
    expect(list.isNotEmpty, isTrue);

    final first = list.first;
    expect(first.containsKey('FS_KD_PEKERJAAN_DK'), isTrue);
    expect(first.containsKey('FS_NM_PEKERJAAN_DK'), isTrue);
  });

  test('getPendidikan() mengembalikan data pendidikan dari SIMRS', () async {
    final list = await MasterService.getPendidikan();

    expect(list, isA<List<Map<String, dynamic>>>());
    expect(list.isNotEmpty, isTrue);

    final first = list.first;
    expect(first.containsKey('FS_KD_PENDIDIKAN_DK'), isTrue);
    expect(first.containsKey('FS_NM_PENDIDIKAN_DK'), isTrue);
  });

  test('getStatusKawin() mengembalikan data status pernikahan dari SIMRS', () async {
    final list = await MasterService.getStatusKawin();

    expect(list, isA<List<Map<String, dynamic>>>());
    expect(list.isNotEmpty, isTrue);

    final first = list.first;
    expect(first.containsKey('FS_KD_STATUS_KAWIN_DK'), isTrue);
    expect(first.containsKey('FS_NM_STATUS_KAWIN_DK'), isTrue);
  });
}

