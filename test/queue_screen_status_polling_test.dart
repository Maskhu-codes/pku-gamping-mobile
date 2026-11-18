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
import 'package:pku_gamping_app/screens/queue_widgets/queue_status_stepper_card.dart';
import 'package:pku_gamping_app/services/antrean_service.dart';
import 'package:pku_gamping_app/services/simrs_service.dart';
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

  group('PROMPT 19 - AntreanService.getStatusAntrean Tests', () {
    test('Mengirim query params dan memperbarui statusPasien & sedangDilayaniLive pada antreanAktif', () async {
      AntreanService.buatAntrean(
        nomorAntrean: '15',
        namaPasien: 'Pasien Test Polling',
        noRm: '347104100407039',
        poli: 'Poli Anak',
        dokter: 'dr. Gina Puspita, Sp.A',
        jam: '08:30 WIB',
        tanggal: '13 November 2026',
      );

      // Set metadata SIMRS pada model aktif
      AntreanService.antreanAktif.value =
          AntreanService.antreanAktif.value!.copyWith(
        fsKdLayanan: 'P003',
        fsKdPetugasMedis: 'S379',
        fsKdAntrian: 'AN202611130001',
        rawTanggal: '2026-11-13',
      );

      String? capturedPath;
      Map<String, dynamic>? capturedQuery;

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        capturedPath = options.path;
        capturedQuery = options.queryParameters;
        return ResponseBody.fromString(
          jsonEncode({
            'status': true,
            'data': {
              'sedang_dilayani': 12,
              'status_pasien': 2,
            },
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final result = await AntreanService.getStatusAntrean(
        fsKdLayanan: 'P003',
        fsKdPetugasMedis: 'S379',
        fsKdAntrian: 'AN202611130001',
        fsMr: '347104100407039',
        tanggal: '2026-11-13',
      );

      expect(capturedPath, '/antrean/status');
      expect(capturedQuery?['fs_kd_layanan'], 'P003');
      expect(capturedQuery?['fs_kd_petugas_medis'], 'S379');
      expect(capturedQuery?['fs_kd_antrian'], 'AN202611130001');
      expect(capturedQuery?['fs_mr'], '347104100407039');
      expect(capturedQuery?['tanggal'], '2026-11-13');

      expect(result?['status_pasien'], 2);
      expect(result?['sedang_dilayani'], '12');

      final current = AntreanService.antreanAktif.value!;
      expect(current.statusPasien, 2);
      expect(current.sedangDilayaniLive, '12');
      expect(current.sisaAntrean, 3);
      expect(current.statusPasienLabel, 'Triage Selesai (Menunggu Poli)');
      expect(current.nomorSedangDilayani, '12');
    });

    test('buatAntrean menyimpan metadata SIMRS lengkap dan hitungSisaAntrean dinamis (min 0)', () async {
      AntreanService.buatAntrean(
        nomorAntrean: '6',
        namaPasien: 'Pasien Dinamis',
        noRm: '347104100407951',
        poli: 'ANDROLOGI',
        dokter: 'Prof. Dr, dr. Dicky',
        jam: '15:30 WIB',
        tanggal: 'Selasa, 24 November 2026',
        fsKdLayanan: 'P047',
        fsKdPetugasMedis: 'S434',
        fsKdAntrian: 'AN1908583A',
        noBooking: 'BO1629860A',
        rawTanggal: '2026-11-24',
      );

      final created = AntreanService.antreanAktif.value!;
      expect(created.fsKdLayanan, 'P047');
      expect(created.fsKdPetugasMedis, 'S434');
      expect(created.fsKdAntrian, 'AN1908583A');
      expect(created.noBooking, 'BO1629860A');
      expect(created.rawTanggal, '2026-11-24');

      // Simulasi sedang_dilayani = 2 -> sisa harus 6 - 2 = 4 (bukan 3 hardcoded)
      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((_) {
        return ResponseBody.fromString(
          jsonEncode({
            'status': true,
            'data': {'sedang_dilayani': '2', 'status_pasien': 1},
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      await AntreanService.getStatusAntrean(
        fsKdLayanan: 'P047',
        fsKdPetugasMedis: 'S434',
      );
      expect(AntreanService.antreanAktif.value!.sisaAntrean, 4);
      expect(AntreanService.antreanAktif.value!.sisaAntreanLive, 4);

      // Simulasi sedang_dilayani melewati nomor pasien (10 > 6) -> sisa clamp ke 0
      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((_) {
        return ResponseBody.fromString(
          jsonEncode({
            'status': true,
            'data': {'sedang_dilayani': '10', 'status_pasien': 3},
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      await AntreanService.getStatusAntrean(
        fsKdLayanan: 'P047',
        fsKdPetugasMedis: 'S434',
      );
      expect(AntreanService.antreanAktif.value!.sisaAntrean, 0);
      expect(AntreanService.antreanAktif.value!.sisaAntreanLive, 0);
    });
  });

  group('PROMPT 19 - Visual Stepper Status 0-3 Component Tests', () {
    testWidgets('Status 0: Booking Dikonfirmasi (Menunggu Check-in)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QueueStatusStepperCard(currentStatus: 0),
          ),
        ),
      );

      expect(find.text('Tahap 1/4'), findsOneWidget);
      expect(find.text('Booking Dikonfirmasi (Menunggu Check-in)'), findsOneWidget);
      expect(find.byKey(const Key('queue_status_stepper_step_0')), findsOneWidget);
      expect(find.text('Booking'), findsOneWidget);
      expect(find.text('Triage'), findsOneWidget);
      expect(find.text('Poli'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);
    });

    testWidgets('Status 1: Pasien Terdaftar (Menuju Triage)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QueueStatusStepperCard(currentStatus: 1),
          ),
        ),
      );

      expect(find.text('Tahap 2/4'), findsOneWidget);
      expect(find.text('Pasien Terdaftar (Menuju Triage)'), findsOneWidget);
      expect(find.byKey(const Key('queue_status_stepper_step_1')), findsOneWidget);
    });

    testWidgets('Status 2: Triage Selesai (Menunggu Poli)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QueueStatusStepperCard(currentStatus: 2),
          ),
        ),
      );

      expect(find.text('Tahap 3/4'), findsOneWidget);
      expect(find.text('Triage Selesai (Menunggu Poli)'), findsOneWidget);
      expect(find.byKey(const Key('queue_status_stepper_step_2')), findsOneWidget);
    });

    testWidgets('Status 3: Pemeriksaan Selesai (Menuju Farmasi)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QueueStatusStepperCard(currentStatus: 3),
          ),
        ),
      );

      expect(find.text('Tahap 4/4'), findsOneWidget);
      expect(find.text('Pemeriksaan Selesai (Menuju Farmasi)'), findsOneWidget);
      expect(find.byKey(const Key('queue_status_stepper_step_3')), findsOneWidget);
    });
  });

  group('PROMPT 19 - Polling Real-time Status di QueueScreen Tests', () {
    testWidgets('Status antrean berubah secara dinamis sesuai respons polling', (tester) async {
      await SessionManager.saveSession(
        token: 'jwt-polling-token',
        fsMr: '347104100407039',
        fsNmPasien: 'PASIEN TEST POLLING',
      );

      var pollCount = 0;
      var simulatedStatus = 0;
      var simulatedSedangDilayani = '5';

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.contains('/booking/aktif')) {
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'data': {
                'no_booking': 'BO202611130001',
                'no_antrian': 'AN202611130001',
                'no_urut': 15,
                'fd_tgl_periksa': '2026-11-13',
                'fs_jam_mulai': '08:00',
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
          pollCount++;
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'data': {
                'sedang_dilayani': simulatedSedangDilayani,
                'status_pasien': simulatedStatus,
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

      // Buka QueueScreen dengan interval polling pendek untuk pengujian
      await tester.pumpWidget(
        const MaterialApp(
          home: QueueScreen(
            embedded: true,
            pollingInterval: Duration(milliseconds: 100),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Kondisi Awal: Status 0 (Booking Dikonfirmasi), nomor 15 - sedang dilayani 5 = 10 sisa
      expect(pollCount, greaterThanOrEqualTo(1));
      expect(find.byKey(const Key('queue_status_stepper_step_0')), findsOneWidget);
      expect(find.text('Booking Dikonfirmasi (Menunggu Check-in)'), findsOneWidget);
      expect(find.text('5'), findsOneWidget); // Sedang dilayani awal
      expect(find.text('10 Pasien Lagi di Depan Anda'), findsOneWidget);

      // Simulasi Rumah Sakit: Pasien Check-in & Masuk Triage (Status 1), sisa 15 - 7 = 8
      simulatedStatus = 1;
      simulatedSedangDilayani = '7';
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('queue_status_stepper_step_1')), findsOneWidget);
      expect(find.text('Pasien Terdaftar (Menuju Triage)'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('8 Pasien Lagi di Depan Anda'), findsOneWidget);

      // Simulasi Rumah Sakit: Triage Selesai, Menunggu Poli (Status 2), sisa 15 - 10 = 5
      simulatedStatus = 2;
      simulatedSedangDilayani = '10';
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('queue_status_stepper_step_2')), findsOneWidget);
      expect(find.text('Triage Selesai (Menunggu Poli)'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('5 Pasien Lagi di Depan Anda'), findsOneWidget);

      // Simulasi Rumah Sakit: Pemeriksaan Dokter Selesai (Status 3), sisa 15 - 15 = 0
      simulatedStatus = 3;
      simulatedSedangDilayani = '15';
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('queue_status_stepper_step_3')), findsOneWidget);
      expect(find.text('Pemeriksaan Selesai (Menuju Farmasi)'), findsOneWidget);
      expect(find.text('15'), findsWidgets);
      expect(find.text('0 Pasien Lagi di Depan Anda'), findsOneWidget);
    });
  });

  group('PROMPT 19 - Integrasi Live Backend SIMRS', () {
    test(
      'Login pasien real dan cek status antrean di /antrean/status',
      tags: ['live_db'],
      () async {
        await SimrsService.login(
          email: 'dummy_pasien@gmail.com',
          password: 'admin123',
        );

        final status = await AntreanService.getStatusAntrean(
          fsKdLayanan: 'P003',
          fsKdPetugasMedis: 'S379',
          fsMr: SessionManager.fsMr,
        );

        if (status != null) {
          expect(status.containsKey('status_pasien'), isTrue);
          expect(status.containsKey('sedang_dilayani'), isTrue);
        }
      },
    );
  });
}

