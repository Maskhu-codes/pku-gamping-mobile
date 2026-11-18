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
import 'package:pku_gamping_app/services/antrean_service.dart';
import 'package:pku_gamping_app/services/pendaftaran_service.dart';
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

  group('PROMPT 18 - Model & Service GET /booking/aktif Tests', () {
    test('AntreanAktifModel.fromBookingJson memetakan respons JSON dari backend SIMRS', () {
      final jsonBackend = {
        'no_booking': 'BO202611130001',
        'no_antrian': 'AN202611130001',
        'no_urut': '18',
        'fd_tgl_periksa': '2026-11-13',
        'fs_jam_mulai': '08:30',
        'fs_kd_layanan': 'P003',
        'fs_kd_petugas_medis': 'S379',
        'poliName': 'Poli Anak',
        'dokterName': 'dr. Gina Puspita, Sp.A',
        'namaPasien': 'Pasien Test SIMRS',
        'fs_mr': '347104100407039',
      };

      final model = AntreanAktifModel.fromBookingJson(jsonBackend);
      expect(model.nomorAntrean, '18');
      expect(model.poli, 'Poli Anak');
      expect(model.dokter, 'dr. Gina Puspita, Sp.A');
      expect(model.tanggal, '13 November 2026');
      expect(model.jam, '08:30 WIB');
      expect(model.namaPasien, 'Pasien Test SIMRS');
      expect(model.noRm, '347104100407039');
    });

    test('AntreanService.getBookingAktif() saat ada antrean: mengembalikan model & update antreanAktif', () async {
      await SessionManager.saveSession(
        token: 'jwt-valid-token',
        fsMr: '347104100407039',
        fsNmPasien: 'PASIEN BOOKING AKTIF',
      );

      String? requestedPath;
      String? authHeader;

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        requestedPath = options.path;
        authHeader = options.headers['Authorization'] as String?;
        return ResponseBody.fromString(
          jsonEncode({
            'status': true,
            'data': {
              'no_booking': 'BO202611130099',
              'no_antrian': 'AN202611130099',
              'no_urut': 7,
              'fd_tgl_periksa': '2026-11-20',
              'fs_jam_mulai': '09:00',
              'fs_kd_layanan': 'P001',
              'fs_kd_petugas_medis': 'D001',
              'poliName': 'Poli Penyakit Dalam',
              'dokterName': 'dr. Hendra Wicaksono, Sp.PD',
            },
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final model = await AntreanService.getBookingAktif();

      expect(requestedPath, '/booking/aktif');
      expect(authHeader, 'Bearer jwt-valid-token');
      expect(model, isNotNull);
      expect(model!.nomorAntrean, '7');
      expect(model.poli, 'Poli Penyakit Dalam');
      expect(model.dokter, 'dr. Hendra Wicaksono, Sp.PD');
      expect(model.tanggal, '20 November 2026');
      expect(AntreanService.antreanAktif.value, isNotNull);
      expect(AntreanService.antreanAktif.value?.nomorAntrean, '7');

      // Forwarder di PendaftaranService juga harus mengembalikan nilai yang sama
      final forwarded = await PendaftaranService.getBookingAktif();
      expect(forwarded?.nomorAntrean, '7');
    });

    test('AntreanService.getBookingAktif() saat HTTP 404: mengosongkan antrean & return null', () async {
      await SessionManager.saveSession(
        token: 'jwt-valid-token',
        fsMr: '347104100407039',
      );
      // Sebelumnya ada antrean lokal
      AntreanService.setAntreanDummy();
      expect(AntreanService.adaAntrean, isTrue);

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((_) {
        return ResponseBody.fromString(
          jsonEncode({
            'status': false,
            'message': 'Tidak ada pendaftaran aktif',
          }),
          404,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final model = await AntreanService.getBookingAktif();

      expect(model, isNull);
      expect(AntreanService.adaAntrean, isFalse);
      expect(AntreanService.antreanAktif.value, isNull);
    });
  });

  group('PROMPT 18 - Widget QueueScreen Booking Aktif Tests', () {
    testWidgets('Screen dibuka & ada booking aktif -> menampilkan poli, dokter, tanggal, nomor antrean', (tester) async {
      await SessionManager.saveSession(
        token: 'jwt-valid-token',
        fsMr: '347104100407039',
        fsNmPasien: 'PASIEN TEST',
      );

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.contains('/booking/aktif')) {
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'data': {
                'no_booking': 'BO202611130005',
                'no_antrian': 'AN202611130005',
                'no_urut': 24,
                'fd_tgl_periksa': '2026-11-25',
                'fs_jam_mulai': '10:00',
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
        return ResponseBody.fromString('{}', 404);
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: QueueScreen(embedded: true),
        ),
      );
      await tester.pumpAndSettle();

      // Verifikasi 4 elemen utama tampil
      expect(find.text('Poli Anak'), findsWidgets); // poli
      expect(find.text('dr. Gina Puspita, Sp.A'), findsOneWidget); // dokter
      expect(find.text('25 November 2026'), findsOneWidget); // tanggal
      expect(find.text('24'), findsOneWidget); // nomor antrean

      // Pastikan tampilan kosong tidak muncul
      expect(find.text('Belum ada booking'), findsNothing);
    });

    testWidgets('Screen dibuka & tidak ada booking aktif (404) -> menampilkan "Belum ada booking"', (tester) async {
      await SessionManager.saveSession(
        token: 'jwt-valid-token',
        fsMr: '347104100407039',
        fsNmPasien: 'PASIEN TEST',
      );

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.contains('/booking/aktif')) {
          return ResponseBody.fromString(
            jsonEncode({
              'status': false,
              'message': 'Tidak ada pendaftaran aktif',
            }),
            404,
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

      // Verifikasi tampilan kosong dengan teks "Belum ada booking"
      expect(find.text('Belum ada booking'), findsOneWidget);
      expect(
        find.textContaining('Belum ada booking pendaftaran aktif'),
        findsOneWidget,
      );

      // Tombol Buat Antrean harus tersedia
      expect(find.text('Buat Antrean'), findsOneWidget);
    });

    testWidgets('Booking tanggal mendatang menampilkan status Jadwal Kunjungan Mendatang', (tester) async {
      await SessionManager.saveSession(
        token: 'jwt-valid-token',
        fsMr: '347104100407039',
        fsNmPasien: 'PASIEN TEST UPCOMING',
      );

      final futureDate = DateTime.now().add(const Duration(days: 5));
      final futureIso =
          '${futureDate.year}-${futureDate.month.toString().padLeft(2, '0')}-${futureDate.day.toString().padLeft(2, '0')}';

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.contains('/booking/aktif')) {
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'data': {
                'no_booking': 'BO9990001',
                'no_antrian': 'AN9990001',
                'no_urut': 6,
                'fd_tgl_periksa': futureIso,
                'fs_jam_mulai': '15:30',
                'fs_kd_layanan': 'P047',
                'fs_kd_petugas_medis': 'S434',
                'poliName': 'ANDROLOGI',
                'dokterName': 'Prof. Dr, dr. Dicky',
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

      final upcomingCard = find.byKey(const Key('queue_wait_status_upcoming'));
      expect(upcomingCard, findsOneWidget);
      expect(find.text('Jadwal Kunjungan Mendatang'), findsOneWidget);
      expect(
        find.descendant(of: upcomingCard, matching: find.text('Terjadwal')),
        findsOneWidget,
      );
      expect(find.textContaining('Pasien Lagi di Depan Anda'), findsNothing);
    });
  });

  group('PROMPT 18 - Integrasi Live Backend SIMRS', () {
    test(
      'Login pasien real lalu panggil GET /booking/aktif',
      tags: ['live_db'],
      () async {
        await SimrsService.login(
          email: 'dummy_pasien@gmail.com',
          password: 'admin123',
        );

        expect(SessionManager.hasValidSession(), isTrue);
        final booking = await AntreanService.getBookingAktif();
        // Tergantung apakah pasien memiliki antrean hari ini atau tidak
        if (booking != null) {
          expect(booking.nomorAntrean, isNotEmpty);
          expect(booking.poli, isNotEmpty);
        } else {
          expect(AntreanService.antreanAktif.value, isNull);
        }
      },
    );
  });
}
