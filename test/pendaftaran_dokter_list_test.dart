import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/models/pendaftaran_model.dart';
import 'package:pku_gamping_app/screens/pendaftaran_widgets/pendaftaran_selection_sheets.dart';
import 'package:pku_gamping_app/services/pendaftaran_service.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _RealHttpOverrides();

  setUpAll(() {
    ApiClient.setBaseUrl(AppConfig.localhostUrl);
  });

  group('DokterPendaftaranModel.fromJson tests', () {
    test('parses backend format with fs_kd_peg, fs_nm_peg, and fs_kd_layanan', () {
      final json = {
        'fs_kd_peg': 'S379',
        'fs_nm_alias': 'GINA PUSPITA',
        'fs_nm_peg': 'dr. Gina Puspita, Sp.A',
        'fs_kd_layanan': 'P003',
        'fs_nm_layanan': 'ANAK',
      };
      final dokter = DokterPendaftaranModel.fromJson(json);
      expect(dokter.id, 'S379');
      expect(dokter.nama, 'dr. Gina Puspita, Sp.A');
      expect(dokter.poliId, 'P003');
      expect(dokter.spesialisasi, 'ANAK');
    });

    test('parses uppercase backend format FS_KD_PEG, FS_NM_PEG, and FS_KD_LAYANAN', () {
      final json = {
        'FS_KD_PEG': 'S011',
        'FS_NM_PEG': 'dr. M.Bambang Edi Susyanto Sp.A.,M.Kes',
        'FS_KD_LAYANAN': 'P003',
        'FS_NM_LAYANAN': 'ANAK',
      };
      final dokter = DokterPendaftaranModel.fromJson(json);
      expect(dokter.id, 'S011');
      expect(dokter.nama, 'dr. M.Bambang Edi Susyanto Sp.A.,M.Kes');
      expect(dokter.poliId, 'P003');
    });

    test('parses legacy format id, nama, poliId, spesialisasi', () {
      final json = {
        'id': 'd-1',
        'nama': 'dr. Bambang',
        'poliId': 'p-1',
        'spesialisasi': 'Spesialis Anak',
      };
      final dokter = DokterPendaftaranModel.fromJson(json);
      expect(dokter.id, 'd-1');
      expect(dokter.nama, 'dr. Bambang');
      expect(dokter.poliId, 'p-1');
      expect(dokter.spesialisasi, 'Spesialis Anak');
    });
  });

  group('PROMPT 14 - PendaftaranService.getListDokter() Real API tests', () {
    test('returns empty list if poliId is null or empty', () async {
      final listNull = await PendaftaranService.getListDokter(poliId: null);
      expect(listNull, isEmpty);

      final listEmpty = await PendaftaranService.getListDokter(poliId: '');
      expect(listEmpty, isEmpty);
    });

    test('fetches exactly 5 doctors for Poli Anak (P003) from SIMRS backend', () async {
      final listDokter = await PendaftaranService.getListDokter(poliId: 'P003');

      expect(listDokter, isNotEmpty);
      expect(listDokter.length, 5);

      final names = listDokter.map((d) => d.nama).toList();
      expect(names, contains('dr. Gina Puspita, Sp.A'));
      expect(names, contains('dr. M.Bambang Edi Susyanto Sp.A.,M.Kes'));
      expect(names, contains('dr. Mohammad Komarudin Sp.A'));
      expect(names, contains('dr. Muriana Noviarini, Sp.A.,.M.Kes'));
      expect(names, contains('dr. Rossy Winata, M.Med.Sc.,Sp.A'));

      final ids = listDokter.map((d) => d.id).toList();
      expect(ids, contains('S379'));
      expect(ids, contains('S011'));
      expect(ids, contains('S192'));
      expect(ids, contains('S251'));
      expect(ids, contains('S437'));
    }, tags: ['live_db']);
  });

  group('PROMPT 14 - DokterSelectionSheet Widget tests', () {
    testWidgets('Pilih Poli Anak -> 5 dokter tampil, filter pencarian & pemilihan',
        (WidgetTester tester) async {
      const poliAnak = PoliModel(
        id: 'P003',
        nama: 'ANAK',
        icon: Icons.child_care_rounded,
      );

      DokterPendaftaranModel? selectedDokter;

      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Navigator(
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: DokterSelectionSheet(
                    selectedPoli: poliAnak,
                    selectedDokter: selectedDokter,
                    onDokterSelected: (dokter) {
                      selectedDokter = dokter;
                    },
                  ),
                ),
              ),
            ),
          ),
        );
        // Wait for real HTTP request from initState
        await Future.delayed(const Duration(milliseconds: 1500));
      });

      await tester.pumpAndSettle();

      // Check header shows "ANAK (5 Dokter)"
      expect(find.text('Pilih Dokter Tujuan'), findsOneWidget);
      expect(find.text('ANAK (5 Dokter)'), findsOneWidget);

      // Check doctors appear
      expect(find.text('dr. Gina Puspita, Sp.A'), findsOneWidget);
      expect(find.text('dr. M.Bambang Edi Susyanto Sp.A.,M.Kes'), findsOneWidget);
      expect(find.text('dr. Mohammad Komarudin Sp.A'), findsOneWidget);

      // Test search filter: type "Gina"
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'Gina');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InkWell, 'dr. Gina Puspita, Sp.A'), findsOneWidget);
      expect(find.text('1 dari 5 Dokter'), findsOneWidget);

      // Tap dokter Gina
      await tester.tap(find.widgetWithText(InkWell, 'dr. Gina Puspita, Sp.A'));
      await tester.pump();

      // Verify callback was triggered with the doctor from SIMRS
      expect(selectedDokter, isNotNull);
      expect(selectedDokter!.id, 'S379');
      expect(selectedDokter!.nama, 'dr. Gina Puspita, Sp.A');
      expect(selectedDokter!.poliId, 'P003');
    }, tags: ['live_db']);
  });
}

