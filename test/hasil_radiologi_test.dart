import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/screens/hasil_radiologi_screen.dart';
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

  group('PROMPT 23 — Model RadiologyResult Unit Tests', () {
    test('RadiologyResult.fromJson mem-parse tanggal, nama tindakan, keterangan, dan link foto', () {
      final json = {
        'fs_kd_trs': 'RAD-20261108-001',
        'fd_tgl_trs': '2026-11-08',
        'fs_jam_keterangan': '10:30:00',
        'FS_NM_TARIF': 'RONTGEN THORAX AP/PA',
        'fs_keterangan': 'Cor dan pulmo dalam batas normal, tidak tampak kardiomegali.',
        'urllink1': 'https://pacs.pkugamping.com/view?id=RAD001',
      };

      final result = RadiologyResult.fromJson(json);

      expect(result.kdTrs, 'RAD-20261108-001');
      expect(result.rawDate, '2026-11-08');
      expect(result.date, '8 November 2026');
      expect(result.time, '10:30:00');
      expect(result.title, 'RONTGEN THORAX AP/PA');
      expect(result.namaTindakan, 'RONTGEN THORAX AP/PA');
      expect(result.keterangan, 'Cor dan pulmo dalam batas normal, tidak tampak kardiomegali.');
      expect(result.urlFoto, 'https://pacs.pkugamping.com/view?id=RAD001');
      expect(result.linkFoto, 'https://pacs.pkugamping.com/view?id=RAD001');
      expect(result.hasFoto, isTrue);
    });
  });

  group('PROMPT 23 — PemeriksaanPenunjangService API Tests', () {
    test('getHasilRadiologi memanggil GET /penunjang/radiologi?fs_mr=<dari_session>', () async {
      await SessionManager.saveSession(
        token: 'token_rad_test',
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
          'data': [
            {
              'fs_kd_trs': 'RAD-001',
              'fd_tgl_trs': '2026-11-08',
              'fs_jam_keterangan': '11:00:00',
              'FS_NM_TARIF': 'RONTGEN THORAX AP/PA',
              'fs_keterangan': 'Cor dan pulmo normal.',
              'urllink1': 'https://pacs.pkugamping.com/view?id=RAD001',
            },
            {
              'fs_kd_trs': 'RAD-002',
              'fd_tgl_trs': '2026-10-15',
              'fs_jam_keterangan': '09:15:00',
              'FS_NM_TARIF': 'USG ABDOMEN',
              'fs_keterangan': 'Hepar dan lien normal.',
              'urllink1': '',
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

      final results = await PemeriksaanPenunjangService.getHasilRadiologi();

      expect(requestedPath, '/penunjang/radiologi');
      expect(requestedParams?['fs_mr'], '347104100407951');
      expect(results.length, 2);
      expect(results[0].title, 'RONTGEN THORAX AP/PA');
      expect(results[0].date, '8 November 2026');
      expect(results[0].keterangan, 'Cor dan pulmo normal.');
      expect(results[0].urlFoto, 'https://pacs.pkugamping.com/view?id=RAD001');
      expect(results[1].title, 'USG ABDOMEN');
      expect(results[1].hasFoto, isFalse);
    });

    test('getHasilRadiologi melempar Exception jika MR tidak ditemukan', () async {
      expect(
        PemeriksaanPenunjangService.getHasilRadiologi(fsMr: ''),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('PROMPT 23 — HasilRadiologiScreen Widget Tests', () {
    testWidgets('Tampil daftar radiologi dengan 4 elemen: tanggal, tindakan, keterangan, dan link foto', (tester) async {
      await SessionManager.saveSession(
        token: 'token_widget_rad',
        fsMr: '01-88-24-90',
        namaPasien: 'Budi Santoso',
      );

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path == '/penunjang/radiologi') {
          final body = {
            'status': true,
            'data': [
              {
                'fs_kd_trs': 'RAD-001',
                'fd_tgl_trs': '2026-11-08',
                'fs_jam_keterangan': '11:00:00',
                'FS_NM_TARIF': 'RONTGEN THORAX AP/PA',
                'fs_keterangan': 'Cor dan pulmo dalam batas normal.',
                'urllink1': 'https://pacs.pkugamping.com/view?id=RAD001',
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
            body: HasilRadiologiScreen(),
          ),
        ),
      );

      // Loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Selesai memuat
      await tester.pumpAndSettle();

      // Memastikan kartu pertama muncul
      expect(find.byKey(const Key('radiologi_card_0')), findsOneWidget);

      // 1. Tanggal tampil
      expect(find.byKey(const Key('radiologi_date_0')), findsOneWidget);
      expect(find.text('8 November 2026'), findsOneWidget);
      expect(find.text('11:00:00'), findsOneWidget);

      // 2. Nama Tindakan tampil
      expect(find.byKey(const Key('radiologi_title_0')), findsOneWidget);
      expect(find.text('RONTGEN THORAX AP/PA'), findsOneWidget);

      // 3. Keterangan ekspertise dokter tampil
      expect(find.byKey(const Key('radiologi_keterangan_0')), findsOneWidget);
      expect(find.text('Cor dan pulmo dalam batas normal.'), findsOneWidget);

      // 4. Link foto hasil tampil
      expect(find.byKey(const Key('radiologi_link_foto_0')), findsOneWidget);
      expect(find.text('https://pacs.pkugamping.com/view?id=RAD001'), findsOneWidget);

      // Klik kartu membuka modal detail
      await tester.tap(find.byKey(const Key('radiologi_card_0')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('radiologi_detail_modal')), findsOneWidget);
      expect(find.text('Hasil Pemeriksaan / Ekspertise Dokter:'), findsOneWidget);
      expect(find.text('Tautan Citra Medis (PACS):'), findsOneWidget);
    });

    testWidgets('Tampil empty state jika data radiologi kosong', (tester) async {
      await SessionManager.saveSession(
        token: 'token_widget_rad_empty',
        fsMr: '01-88-24-90',
        namaPasien: 'Budi Santoso',
      );

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        return ResponseBody.fromString(
          jsonEncode({
            'status': true,
            'data': [],
          }),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HasilRadiologiScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Belum Ada Hasil Radiologi'), findsOneWidget);
      expect(find.text('Hasil pemeriksaan radiologi Anda belum tersedia.'), findsOneWidget);
    });
  });
}

