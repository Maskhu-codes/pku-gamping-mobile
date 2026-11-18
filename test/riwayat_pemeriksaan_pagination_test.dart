import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/screens/riwayat_pemeriksaan_screen.dart';
import 'package:pku_gamping_app/screens/riwayat_pemeriksaan_widgets/riwayat_empty_state.dart';
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

  group('PROMPT 22 - Model Riwayat & Paginasi Unit Tests', () {
    test('RiwayatPemeriksaan.fromJson memetakan field SIMRS dan memformat tanggal', () {
      final jsonBackend = {
        'FS_KD_REG': 'RG202611010001',
        'FD_TGL_MASUK': '2026-11-01 08:30:00.000',
        'poli': 'Poli Penyakit Dalam',
        'dokter': 'dr. Hendra Wicaksono, Sp.PD',
        'FS_TERAPI': 'Paracetamol 500mg 3x1, Antasida 3x1',
      };

      final item = RiwayatPemeriksaan.fromJson(jsonBackend);

      expect(item.kdReg, 'RG202611010001');
      expect(item.tanggal, '1 November 2026');
      expect(item.poli, 'Poli Penyakit Dalam');
      expect(item.dokter, 'dr. Hendra Wicaksono, Sp.PD');
      expect(item.terapi, 'Paracetamol 500mg 3x1, Antasida 3x1');
      expect(item.namaPemeriksaan, 'Pemeriksaan Poli Penyakit Dalam');
    });

    test('RiwayatPaginationModel.fromJson memetakan 10 data dan metadata paginasi', () {
      final jsonBackend = {
        'status': true,
        'data': List.generate(
          10,
          (i) => {
            'FS_KD_REG': 'RG00$i',
            'FD_TGL_MASUK': '2026-10-${(i + 1).toString().padLeft(2, '0')}',
            'poli': 'Poli Anak',
            'dokter': 'dr. Gina Puspita, Sp.A',
            'FS_TERAPI': 'Vitamin C',
          },
        ),
        'pagination': {
          'current_page': 1,
          'total_pages': 3,
          'total_items': 25,
          'has_next': true,
        },
      };

      final model = RiwayatPaginationModel.fromJson(jsonBackend);

      expect(model.items.length, 10);
      expect(model.currentPage, 1);
      expect(model.totalPages, 3);
      expect(model.totalItems, 25);
      expect(model.hasNext, isTrue);
    });
  });

  group('PROMPT 22 - PemeriksaanPenunjangService GET /riwayat/list Tests', () {
    test('Memanggil GET /riwayat/list dengan parameter fs_mr dan page=1', () async {
      await SessionManager.saveSession(
        token: 'token-riwayat',
        fsMr: '347104100407039',
        fsNmPasien: 'Pasien Riwayat',
      );

      String? capturedPath;
      Map<String, dynamic>? capturedQuery;

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        capturedPath = options.path;
        capturedQuery = options.queryParameters;

        return ResponseBody.fromString(
          jsonEncode({
            'status': true,
            'data': [
              {
                'FS_KD_REG': 'RG20261105001',
                'FD_TGL_MASUK': '2026-11-05',
                'poli': 'Poli Penyakit Dalam',
                'dokter': 'dr. Hendra Wicaksono, Sp.PD',
                'FS_TERAPI': 'Obat Lambung',
              }
            ],
            'pagination': {
              'current_page': 1,
              'total_pages': 1,
              'total_items': 1,
              'has_next': false,
            },
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final result =
          await PemeriksaanPenunjangService.getRiwayatPemeriksaanPaged(page: 1);

      expect(capturedPath, '/riwayat/list');
      expect(capturedQuery?['fs_mr'], '347104100407039');
      expect(capturedQuery?['page'], 1);
      expect(result.items.length, 1);
      expect(result.items.first.poli, 'Poli Penyakit Dalam');
    });

    test('Memanggil page 2 saat lazy loading', () async {
      await SessionManager.saveSession(
        token: 'token-riwayat',
        fsMr: '347104100407039',
      );

      Map<String, dynamic>? capturedQuery;

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        capturedQuery = options.queryParameters;
        return ResponseBody.fromString(
          jsonEncode({
            'status': true,
            'data': [],
            'pagination': {
              'current_page': 2,
              'total_pages': 2,
              'total_items': 10,
              'has_next': false,
            },
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final result =
          await PemeriksaanPenunjangService.getRiwayatPemeriksaanPaged(page: 2);

      expect(capturedQuery?['page'], 2);
      expect(result.currentPage, 2);
      expect(result.hasNext, isFalse);
    });

    test('Melempar Exception saat server mengembalikan 400 Bad Request MR tidak valid', () async {
      await SessionManager.saveSession(
        token: 'token-riwayat',
        fsMr: 'invalid_mr',
      );

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        return ResponseBody.fromString(
          jsonEncode({'status': false, 'message': 'MR tidak valid'}),
          400,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      expect(
        () => PemeriksaanPenunjangService.getRiwayatPemeriksaanPaged(page: 1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('PROMPT 22 - Widget RiwayatPemeriksaanScreen Scroll Pagination Tests', () {
    testWidgets('Tampil daftar riwayat halaman 1 (10 data) & memuat halaman 2 (10 data) saat di-scroll', (tester) async {
      await SessionManager.saveSession(
        token: 'token-riwayat',
        fsMr: '347104100407039',
        fsNmPasien: 'Pasien Test Paginasi',
      );

      final requestedPages = <int>[];

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        final page = options.queryParameters['page'] as int? ?? 1;
        requestedPages.add(page);

        if (page == 1) {
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'data': List.generate(
                10,
                (i) => {
                  'FS_KD_REG': 'RG-HAL1-ITEM$i',
                  'FD_TGL_MASUK': '2026-11-${(i + 1).toString().padLeft(2, '0')}',
                  'poli': 'Poli Anak Hal 1',
                  'dokter': 'dr. Gina Puspita, Sp.A',
                  'FS_TERAPI': 'Terapi Halaman 1 Item $i',
                },
              ),
              'pagination': {
                'current_page': 1,
                'total_pages': 2,
                'total_items': 20,
                'has_next': true,
              },
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        } else if (page == 2) {
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'data': List.generate(
                10,
                (i) => {
                  'FS_KD_REG': 'RG-HAL2-ITEM$i',
                  'FD_TGL_MASUK': '2026-10-${(i + 1).toString().padLeft(2, '0')}',
                  'poli': 'Poli Penyakit Dalam Hal 2',
                  'dokter': 'dr. Hendra Wicaksono, Sp.PD',
                  'FS_TERAPI': 'Terapi Halaman 2 Item $i',
                },
              ),
              'pagination': {
                'current_page': 2,
                'total_pages': 2,
                'total_items': 20,
                'has_next': false,
              },
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }

        return ResponseBody.fromString('{}', 404);
      });

      // Atur ukuran viewport pengujian
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: RiwayatPemeriksaanScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verifikasi halaman 1 telah dimuat
      expect(requestedPages.contains(1), isTrue);
      expect(find.text('Poli Anak Hal 1'), findsWidgets);
      expect(find.byKey(const Key('riwayat_card_0')), findsOneWidget);

      // Data halaman 2 belum muncul
      expect(find.text('Poli Penyakit Dalam Hal 2'), findsNothing);

      // 2. Lakukan scroll ke bawah untuk memicu lazy loading halaman 2
      await tester.scrollUntilVisible(
        find.byKey(const Key('riwayat_card_19')),
        300,
        scrollable: find.byType(Scrollable),
      );
      await tester.pumpAndSettle();

      // 3. Verifikasi halaman 2 telah dimuat otomatis melalui scroll pagination
      expect(requestedPages.contains(2), isTrue);
      expect(find.text('Poli Penyakit Dalam Hal 2'), findsWidgets);
      expect(find.byKey(const Key('riwayat_card_19')), findsOneWidget);
    });

    testWidgets('Tampil RiwayatEmptyState saat data kunjungan kosong', (tester) async {
      await SessionManager.saveSession(
        token: 'token-riwayat',
        fsMr: '347104100407039',
      );

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        return ResponseBody.fromString(
          jsonEncode({
            'status': true,
            'data': [],
            'pagination': {
              'current_page': 1,
              'total_pages': 0,
              'total_items': 0,
              'has_next': false,
            },
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: RiwayatPemeriksaanScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RiwayatEmptyState), findsOneWidget);
      expect(find.text('Tidak Ada Riwayat'), findsOneWidget);
      expect(find.text('Anda belum memiliki riwayat pemeriksaan.'), findsOneWidget);
    });
  });

  group('PROMPT 22 - Integrasi Live Backend SIMRS', () {
    test(
      'Panggil /riwayat/list dengan MR real terhadap database SIMRS',
      tags: ['live_db'],
      () async {
        final result = await PemeriksaanPenunjangService.getRiwayatPemeriksaanPaged(
          fsMr: '347104100407039',
          page: 1,
        );

        expect(result.items, isNotNull);
        expect(result.currentPage, 1);
      },
    );
  });
}
