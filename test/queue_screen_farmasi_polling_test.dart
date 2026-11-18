import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/screens/queue_screen.dart';
import 'package:pku_gamping_app/screens/queue_widgets/queue_farmasi_card.dart';
import 'package:pku_gamping_app/services/antrean_service.dart';
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
    AntreanService.kosongkanAntrean();
    ApiClient.setBaseUrl(AppConfig.localhostUrl);
    originalAdapter = ApiClient.dio.httpClientAdapter;
  });

  tearDown(() {
    ApiClient.dio.httpClientAdapter = originalAdapter;
    AntreanService.kosongkanAntrean();
  });

  group('PROMPT 20 - AntreanFarmasiModel Unit Tests', () {
    test('fromJson berhasil memisahkan nomor racik (B, D) dan non-racik (A, C)', () {
      final json = {
        'racik': ['B-012', 'D-005', '  B-015  '],
        'non_racik': ['A-040', 'C-011'],
      };

      final model = AntreanFarmasiModel.fromJson(json);

      expect(model.racik, ['B-012', 'D-005', 'B-015']);
      expect(model.nonRacik, ['A-040', 'C-011']);
      expect(model.isNotEmpty, isTrue);
      expect(model.isEmpty, isFalse);
    });

    test('fromJson menangani data kosong atau null dengan aman', () {
      final emptyModel = AntreanFarmasiModel.fromJson({});
      expect(emptyModel.racik, isEmpty);
      expect(emptyModel.nonRacik, isEmpty);
      expect(emptyModel.isEmpty, isTrue);
      expect(emptyModel.isNotEmpty, isFalse);

      final nullValuesModel = AntreanFarmasiModel.fromJson({
        'racik': null,
        'non_racik': null,
      });
      expect(nullValuesModel.racik, isEmpty);
      expect(nullValuesModel.nonRacik, isEmpty);
    });

    test('fromJson menangani data duplikat, null, dan kosong dengan aman', () {
      final model = AntreanFarmasiModel.fromJson({
        'racik': ['B-0', 'B-0', 'D-0', '  ', null],
        'non_racik': ['A-0', 'A-0', 'C-0', ''],
      });

      expect(model.racik, ['B-0', 'D-0']);
      expect(model.nonRacik, ['A-0', 'C-0']);
      expect(model.isNotEmpty, isTrue);
    });

    test('toJson mengembalikan struktur Map yang valid', () {
      const model = AntreanFarmasiModel(
        racik: ['B-001', 'D-002'],
        nonRacik: ['A-003', 'C-004'],
      );

      final map = model.toJson();
      expect(map['racik'], ['B-001', 'D-002']);
      expect(map['non_racik'], ['A-003', 'C-004']);
    });
  });

  group('PROMPT 20 - AntreanService.getAntreanFarmasi Tests', () {
    test('Memanggil GET /farmasi/antrean dan mengupdate notifier antreanFarmasi', () async {
      String? capturedPath;
      String? capturedMethod;

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        capturedPath = options.path;
        capturedMethod = options.method;
        return ResponseBody.fromString(
          jsonEncode({
            'status': true,
            'data': {
              'racik': ['B-020', 'D-003'],
              'non_racik': ['A-055', 'C-012'],
            },
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final result = await AntreanService.getAntreanFarmasi();

      expect(capturedPath, '/farmasi/antrean');
      expect(capturedMethod, 'GET');
      expect(result.racik, ['B-020', 'D-003']);
      expect(result.nonRacik, ['A-055', 'C-012']);

      // Verifikasi ValueNotifier terupdate
      final notifierValue = AntreanService.antreanFarmasi.value;
      expect(notifierValue, isNotNull);
      expect(notifierValue!.racik, ['B-020', 'D-003']);
      expect(notifierValue.nonRacik, ['A-055', 'C-012']);
    });

    test('Menangani error API dengan fallback model kosong tanpa throw', () async {
      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        return ResponseBody.fromString(
          jsonEncode({'status': false, 'message': 'Internal error'}),
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final result = await AntreanService.getAntreanFarmasi();
      expect(result.racik, isEmpty);
      expect(result.nonRacik, isEmpty);
      expect(AntreanService.antreanFarmasi.value?.isEmpty, isTrue);
    });
  });

  group('PROMPT 20 - QueueFarmasiCard Component Tests', () {
    testWidgets('Menampilkan label racik & non-racik beserta status kosong saat tidak ada antrean', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QueueFarmasiCard(
              farmasi: AntreanFarmasiModel(
                racik: [],
                nonRacik: [],
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('queue_farmasi_card')), findsOneWidget);
      expect(find.text('ANTREAN FARMASI / APOTEK'), findsOneWidget);
      expect(find.text('LIVE'), findsOneWidget);
      expect(find.text('Obat Racik'), findsOneWidget);
      expect(find.text('Non-Racik'), findsOneWidget);
      expect(find.text('Antrean B & D'), findsOneWidget);
      expect(find.text('Antrean A & C'), findsOneWidget);

      expect(find.byKey(const Key('farmasi_racik_empty')), findsOneWidget);
      expect(find.byKey(const Key('farmasi_non_racik_empty')), findsOneWidget);
      expect(find.text('Belum ada antrean'), findsNWidgets(2));
    });

    testWidgets('Menampilkan chips nomor antrean racik (B, D) dan non-racik (A, C)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QueueFarmasiCard(
              farmasi: AntreanFarmasiModel(
                racik: ['B-014', 'D-002'],
                nonRacik: ['A-033', 'C-009'],
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('farmasi_racik_list')), findsOneWidget);
      expect(find.byKey(const Key('farmasi_non_racik_list')), findsOneWidget);

      expect(find.text('B-014'), findsOneWidget);
      expect(find.text('D-002'), findsOneWidget);
      expect(find.text('A-033'), findsOneWidget);
      expect(find.text('C-009'), findsOneWidget);
    });

    testWidgets('Tetap merender aman tanpa Duplicate keys found saat menerima item kembar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QueueFarmasiCard(
              farmasi: AntreanFarmasiModel(
                racik: ['B-0', 'B-0', 'D-0'],
                nonRacik: ['A-0', 'A-0', 'C-0'],
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('farmasi_racik_list')), findsOneWidget);
      expect(find.byKey(const Key('farmasi_non_racik_list')), findsOneWidget);
      expect(find.text('B-0'), findsNWidgets(2));
      expect(find.text('D-0'), findsOneWidget);
      expect(find.text('A-0'), findsNWidgets(2));
      expect(find.text('C-0'), findsOneWidget);
    });
  });

  group('PROMPT 20 - Polling Antrean Farmasi di QueueScreen Tests', () {
    testWidgets('QueueScreen memanggil GET /farmasi/antrean saat dibuka dan memperbarui nomor saat polling', (tester) async {
      await SessionManager.saveSession(
        token: 'jwt-farmasi-token',
        fsMr: '347104100407039',
        fsNmPasien: 'PASIEN TEST FARMASI',
      );

      var farmasiPollCount = 0;
      var simulatedRacik = <String>['B-001'];
      var simulatedNonRacik = <String>['A-010'];

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.contains('/booking/aktif')) {
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'data': {
                'no_booking': 'BO202611130099',
                'no_antrian': 'AN202611130099',
                'no_urut': 18,
                'fd_tgl_periksa': '2026-11-13',
                'fs_jam_mulai': '08:30',
                'fs_kd_layanan': 'P003',
                'fs_kd_petugas_medis': 'S379',
                'poliName': 'Poli Anak',
                'dokterName': 'dr. Gina Puspita, Sp.A',
              },
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }

        if (options.path.contains('/antrean/status')) {
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'data': {
                'sedang_dilayani': '15',
                'status_pasien': 3,
              },
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }

        if (options.path.contains('/farmasi/antrean')) {
          farmasiPollCount++;
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'data': {
                'racik': simulatedRacik,
                'non_racik': simulatedNonRacik,
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

      // Render QueueScreen dengan polling interval pendek
      await tester.pumpWidget(
        const MaterialApp(
          home: QueueScreen(
            embedded: true,
            pollingInterval: Duration(milliseconds: 100),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verifikasi panggilan awal
      expect(farmasiPollCount, greaterThanOrEqualTo(1));
      expect(find.byKey(const Key('queue_farmasi_card')), findsOneWidget);
      expect(find.text('B-001'), findsOneWidget);
      expect(find.text('A-010'), findsOneWidget);

      // Simulasi panggilan berikutnya dari apotek: nomor antrean racik & non-racik baru masuk
      simulatedRacik = ['B-001', 'D-007'];
      simulatedNonRacik = ['A-010', 'C-025'];

      await tester.pump(const Duration(milliseconds: 120));
      await tester.pumpAndSettle();

      // Verifikasi update real-time nomor farmasi tampil
      expect(find.text('D-007'), findsOneWidget);
      expect(find.text('C-025'), findsOneWidget);
      expect(farmasiPollCount, greaterThanOrEqualTo(2));
    });

    testWidgets('QueueScreen tanpa booking aktif tetap menampilkan antrean farmasi', (tester) async {
      await SessionManager.saveSession(
        token: 'jwt-farmasi-token',
        fsMr: '347104100407039',
        fsNmPasien: 'PASIEN TEST FARMASI',
      );

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.contains('/booking/aktif')) {
          return ResponseBody.fromString(
            jsonEncode({'status': false, 'message': 'Belum ada booking'}),
            404,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }

        if (options.path.contains('/farmasi/antrean')) {
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'data': {
                'racik': ['B-099'],
                'non_racik': ['A-088'],
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

      await tester.pumpWidget(
        const MaterialApp(
          home: QueueScreen(embedded: true),
        ),
      );
      await tester.pumpAndSettle();

      // State empty queue tampil
      expect(find.text('Belum ada booking'), findsOneWidget);

      // Kartu farmasi tetap tampil di halaman antrean
      expect(find.byKey(const Key('queue_farmasi_card')), findsOneWidget);
      expect(find.text('B-099'), findsOneWidget);
      expect(find.text('A-088'), findsOneWidget);
    });
  });

  group('PROMPT 20 - Integrasi Live Backend SIMRS', () {
    test(
      'Cek endpoint real /farmasi/antrean terhadap database backend SIMRS',
      tags: ['live_db'],
      () async {
        final farmasi = await AntreanService.getAntreanFarmasi();
        expect(farmasi, isNotNull);
        // data.racik dan data.non_racik bertipe List<String>
        expect(farmasi.racik, isA<List<String>>());
        expect(farmasi.nonRacik, isA<List<String>>());
      },
    );
  });
}
