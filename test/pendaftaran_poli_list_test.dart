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

  group('PoliModel.fromJson tests', () {
    test('parses backend format with fs_kd_layanan and fs_nm_layanan', () {
      final json = {
        'fs_kd_layanan': 'P003',
        'fs_nm_layanan': 'ANAK',
      };
      final poli = PoliModel.fromJson(json);
      expect(poli.id, 'P003');
      expect(poli.nama, 'ANAK');
      expect(poli.deskripsi, 'Layanan rawat jalan terpadu');
    });

    test('parses uppercase backend format FS_KD_LAYANAN and FS_NM_LAYANAN', () {
      final json = {
        'FS_KD_LAYANAN': 'P001',
        'FS_NM_LAYANAN': 'DALAM',
      };
      final poli = PoliModel.fromJson(json);
      expect(poli.id, 'P001');
      expect(poli.nama, 'DALAM');
    });

    test('parses legacy format id and nama', () {
      final json = {
        'id': 'P005',
        'nama': 'BEDAH UMUM',
        'deskripsi': 'Spesialis Bedah Umum',
      };
      final poli = PoliModel.fromJson(json);
      expect(poli.id, 'P005');
      expect(poli.nama, 'BEDAH UMUM');
      expect(poli.deskripsi, 'Spesialis Bedah Umum');
    });
  });

  group('PROMPT 13 - PendaftaranService.getListPoli() Real API tests', () {
    test('fetches real poli list from SIMRS backend (56 poli)', () async {
      final listPoli = await PendaftaranService.getListPoli();

      expect(listPoli, isNotEmpty);
      expect(listPoli.length, 56);

      // Verify specific known poli are present
      final namaList = listPoli.map((p) => p.nama).toList();
      expect(namaList, contains('ANAK'));
      expect(namaList, contains('BEDAH UMUM'));
      expect(namaList, contains('DALAM'));
      expect(namaList, contains('JANTUNG'));
      expect(namaList, contains('MATA'));
      expect(namaList, contains('SYARAF'));
      expect(namaList, contains('THT'));

      // Verify structure of first item
      final first = listPoli.first;
      expect(first.id, isNotEmpty);
      expect(first.nama, isNotEmpty);
    }, tags: ['live_db']);
  });

  group('PROMPT 13 - PoliSelectionSheet Widget tests', () {
    testWidgets('loads real SIMRS poli list and supports selection & search',
        (WidgetTester tester) async {
      PoliModel? selectedPoli;

      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Navigator(
              onGenerateRoute: (settings) => MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: PoliSelectionSheet(
                    selectedPoli: selectedPoli,
                    onPoliSelected: (poli) {
                      selectedPoli = poli;
                    },
                  ),
                ),
              ),
            ),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 1500));
      });

      await tester.pumpAndSettle();

      // Check header shows 56 Poliklinik Tersedia
      expect(find.text('Pilih Poli Tujuan'), findsOneWidget);
      expect(find.text('56 Poliklinik Tersedia'), findsOneWidget);

      // Check poli item appears (e.g. ANAK)
      expect(find.text('ANAK'), findsOneWidget);

      // Test search filter: type "JANTUNG"
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'JANTUNG');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InkWell, 'JANTUNG'), findsOneWidget);
      expect(find.text('1 dari 56 Poliklinik'), findsOneWidget);

      // Tap JANTUNG
      await tester.tap(find.widgetWithText(InkWell, 'JANTUNG'));
      await tester.pump();

      // Verify callback was triggered
      expect(selectedPoli, isNotNull);
      expect(selectedPoli!.nama, 'JANTUNG');
      expect(selectedPoli!.id, 'P025');
    }, tags: ['live_db']);
  });
}
