import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/screens/hasil_lab_screen.dart';
import 'package:pku_gamping_app/services/pemeriksaan_penunjang_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RealHttpOverrides extends HttpOverrides {}

typedef _MockHandler = ResponseBody Function(RequestOptions options);

class _MockHttpClientAdapter implements HttpClientAdapter {
  _MockHttpClientAdapter(this.handler);

  final _MockHandler handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _RealHttpOverrides();

  late HttpClientAdapter originalAdapter;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionManager.init();
    ApiClient.setBaseUrl(AppConfig.localhostUrl);
    originalAdapter = ApiClient.dio.httpClientAdapter;
  });

  tearDown(() async {
    ApiClient.dio.httpClientAdapter = originalAdapter;
    await SessionManager.clearSession();
  });

  group('PROMPT 24 - Models LabResult & LabParameterDetail Unit Tests', () {
    test('LabResult.fromJson mem-parse data transaksi lab dari SIMRS', () {
      final json = {
        'FS_KD_TRS': 'TRS-LAB-20261113-001',
        'FD_TGL_TRS': '2026-11-13',
        'FS_JAM_TRS': '09:30:00',
      };

      final result = LabResult.fromJson(json);

      expect(result.kdTrs, 'TRS-LAB-20261113-001');
      expect(result.rawDate, '2026-11-13');
      expect(result.date, '13 November 2026');
      expect(result.time, '09:30:00');
      expect(result.title, 'Pemeriksaan Lab #TRS-LAB-20261113-001');
    });

    test('LabParameterDetail.fromJson mem-parse 5 parameter (nama, hasil, satuan, nilai rujukan, flag)', () {
      final jsonNormal = {
        'pemeriksaan': 'Hemoglobin',
        'hasil': '14.2',
        'satuan': 'g/dL',
        'nilai_rujukan': '13.2 - 17.3',
        'flag': 'N',
      };
      final paramNormal = LabParameterDetail.fromJson(jsonNormal);

      expect(paramNormal.pemeriksaan, 'Hemoglobin');
      expect(paramNormal.hasil, '14.2');
      expect(paramNormal.satuan, 'g/dL');
      expect(paramNormal.nilaiRujukan, '13.2 - 17.3');
      expect(paramNormal.flag, 'N');
      expect(paramNormal.isNormal, isTrue);
      expect(paramNormal.isHigh, isFalse);
      expect(paramNormal.isLow, isFalse);

      final jsonHigh = {
        'fs_nm_jenis_pemeriksaan': 'Leukosit',
        'FS_HASIL': '12.5',
        'FS_SATUAN': '10^3/uL',
        'FS_NILAI_RUJUKAN': '3.8 - 10.6',
        'FS_FLAG_HASIL': 'H',
      };
      final paramHigh = LabParameterDetail.fromJson(jsonHigh);

      expect(paramHigh.pemeriksaan, 'Leukosit');
      expect(paramHigh.hasil, '12.5');
      expect(paramHigh.satuan, '10^3/uL');
      expect(paramHigh.nilaiRujukan, '3.8 - 10.6');
      expect(paramHigh.flag, 'H');
      expect(paramHigh.isHigh, isTrue);
      expect(paramHigh.isNormal, isFalse);
      expect(paramHigh.isLow, isFalse);

      final jsonLow = {
        'pemeriksaan': 'Trombosit',
        'hasil': '110',
        'satuan': '10^3/uL',
        'nilai_rujukan': '150 - 440',
        'flag': 'L',
      };
      final paramLow = LabParameterDetail.fromJson(jsonLow);

      expect(paramLow.pemeriksaan, 'Trombosit');
      expect(paramLow.hasil, '110');
      expect(paramLow.satuan, '10^3/uL');
      expect(paramLow.nilaiRujukan, '150 - 440');
      expect(paramLow.flag, 'L');
      expect(paramLow.isLow, isTrue);
      expect(paramLow.isNormal, isFalse);
      expect(paramLow.isHigh, isFalse);
    });
  });

  group('PROMPT 24 - PemeriksaanPenunjangService API Tests', () {
    test('getHasilLab memanggil GET /penunjang/laboratorium dengan fs_mr dari session & page', () async {
      await SessionManager.saveSession(
        token: 'token_lab_test',
        fsMr: '347104100407951',
        namaPasien: 'Budi Santoso',
      );

      String? requestedPath;
      Map<String, dynamic>? requestedParams;

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        requestedPath = options.path;
        requestedParams = options.queryParameters;

        final body = {
          'status': true,
          'message': 'Data laboratorium ditemukan',
          'data': [
            {
              'FS_KD_TRS': 'LAB-001',
              'FD_TGL_TRS': '2026-11-10',
              'FS_JAM_TRS': '08:00:00',
            },
            {
              'FS_KD_TRS': 'LAB-002',
              'FD_TGL_TRS': '2026-11-05',
              'FS_JAM_TRS': '14:20:00',
            },
          ],
        };

        return ResponseBody.fromString(
          jsonEncode(body),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final results = await PemeriksaanPenunjangService.getHasilLab(page: 1);

      expect(requestedPath, '/penunjang/laboratorium');
      expect(requestedParams?['fs_mr'], '347104100407951');
      expect(requestedParams?['page'], 1);
      expect(results.length, 2);
      expect(results[0].kdTrs, 'LAB-001');
      expect(results[1].kdTrs, 'LAB-002');
    });

    test('getLaboratoriumDetail memanggil GET /penunjang/laboratorium_detail dengan fs_kd_trs', () async {
      String? requestedPath;
      Map<String, dynamic>? requestedParams;

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        requestedPath = options.path;
        requestedParams = options.queryParameters;

        final body = {
          'status': true,
          'message': 'Detail laboratorium ditemukan',
          'data': [
            {
              'pemeriksaan': 'Hemoglobin',
              'hasil': '14.5',
              'satuan': 'g/dL',
              'nilai_rujukan': '13.2 - 17.3',
              'flag': 'N',
            },
            {
              'pemeriksaan': 'Glukosa Sewaktu',
              'hasil': '210',
              'satuan': 'mg/dL',
              'nilai_rujukan': '< 200',
              'flag': 'H',
            },
          ],
        };

        return ResponseBody.fromString(
          jsonEncode(body),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final details = await PemeriksaanPenunjangService.getLaboratoriumDetail('LAB-001');

      expect(requestedPath, '/penunjang/laboratorium_detail');
      expect(requestedParams?['fs_kd_trs'], 'LAB-001');
      expect(details.length, 2);
      expect(details[0].pemeriksaan, 'Hemoglobin');
      expect(details[0].hasil, '14.5');
      expect(details[1].pemeriksaan, 'Glukosa Sewaktu');
      expect(details[1].isHigh, isTrue);
    });
  });

  group('PROMPT 24 - HasilLabScreen & LabDetailModal Widget Tests', () {
    testWidgets('Daftar lab tampil -> klik -> detail 5 parameter laboratorium tampil di modal', (tester) async {
      await SessionManager.saveSession(
        token: 'token_widget_lab',
        fsMr: '01-88-24-90',
        namaPasien: 'Budi Santoso',
      );

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path == '/penunjang/laboratorium') {
          final body = {
            'status': true,
            'message': 'OK',
            'data': [
              {
                'FS_KD_TRS': 'TRS-LAB-999',
                'FD_TGL_TRS': '2026-11-13',
                'FS_JAM_TRS': '09:15:00',
              },
            ],
          };
          return ResponseBody.fromString(
            jsonEncode(body),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }

        if (options.path == '/penunjang/laboratorium_detail') {
          final body = {
            'status': true,
            'message': 'OK',
            'data': [
              {
                'pemeriksaan': 'Hemoglobin',
                'hasil': '14.2',
                'satuan': 'g/dL',
                'nilai_rujukan': '13.2 - 17.3',
                'flag': 'N',
              },
              {
                'pemeriksaan': 'Leukosit',
                'hasil': '11.5',
                'satuan': '10^3/uL',
                'nilai_rujukan': '3.8 - 10.6',
                'flag': 'H',
              },
              {
                'pemeriksaan': 'Trombosit',
                'hasil': '120',
                'satuan': '10^3/uL',
                'nilai_rujukan': '150 - 440',
                'flag': 'L',
              },
            ],
          };
          return ResponseBody.fromString(
            jsonEncode(body),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }

        return ResponseBody.fromString(
          jsonEncode({'status': false, 'message': 'Not found'}),
          404,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HasilLabScreen(),
          ),
        ),
      );

      // Loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Selesai memuat daftar lab
      await tester.pumpAndSettle();

      // Memastikan kartu laboratorium pertama muncul
      expect(find.byKey(const Key('lab_card_0')), findsOneWidget);
      expect(find.text('Pemeriksaan Lab #TRS-LAB-999'), findsOneWidget);
      expect(find.text('13 November 2026'), findsOneWidget);
      expect(find.text('09:15:00'), findsOneWidget);

      // Klik kartu lab
      await tester.tap(find.byKey(const Key('lab_card_0')));
      await tester.pump(); // trigger bottom sheet animation & loading
      await tester.pumpAndSettle(); // selesai memuat detail

      // Modal detail muncul
      expect(find.byKey(const Key('lab_detail_modal')), findsOneWidget);
      expect(find.text('Detail Hasil Laboratorium'), findsOneWidget);

      // Verifikasi 3 parameter lab tampil dengan 5 atribut lengkap:
      // Parameter 0: Hemoglobin (Normal)
      expect(find.byKey(const Key('param_pemeriksaan_0')), findsOneWidget);
      expect(find.text('Hemoglobin'), findsOneWidget);
      expect(find.text('14.2'), findsOneWidget);
      expect(find.text('g/dL'), findsOneWidget);
      expect(find.text('13.2 - 17.3'), findsOneWidget);
      expect(find.text('(Normal)'), findsOneWidget);

      // Parameter 1: Leukosit (Tinggi / H)
      expect(find.byKey(const Key('param_pemeriksaan_1')), findsOneWidget);
      expect(find.text('Leukosit'), findsOneWidget);
      expect(find.text('11.5'), findsOneWidget);
      expect(find.text('3.8 - 10.6'), findsOneWidget);
      expect(find.text('(Tinggi)'), findsOneWidget);

      // Parameter 2: Trombosit (Rendah / L)
      expect(find.byKey(const Key('param_pemeriksaan_2')), findsOneWidget);
      expect(find.text('Trombosit'), findsOneWidget);
      expect(find.text('120'), findsOneWidget);
      expect(find.text('150 - 440'), findsOneWidget);
      expect(find.text('(Rendah)'), findsOneWidget);
    });

    testWidgets('Tampil empty state jika pasien belum memiliki hasil lab', (tester) async {
      await SessionManager.saveSession(
        token: 'token_widget_empty',
        fsMr: '01-88-24-90',
        namaPasien: 'Budi Santoso',
      );

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        return ResponseBody.fromString(
          jsonEncode({
            'status': true,
            'message': 'Belum ada data',
            'data': [],
          }),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HasilLabScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Belum Ada Hasil Laboratorium'), findsOneWidget);
      expect(find.text('Hasil pemeriksaan laboratorium Anda belum tersedia.'), findsOneWidget);
    });
  });
}
