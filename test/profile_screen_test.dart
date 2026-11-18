import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/screens/profile_screen.dart';
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
    ApiClient.setBaseUrl(AppConfig.localhostUrl);
    originalAdapter = ApiClient.dio.httpClientAdapter;
  });

  tearDown(() async {
    ApiClient.dio.httpClientAdapter = originalAdapter;
    await SessionManager.clearSession();
  });

  group('PROMPT 21 - SessionManager.updateFromMe Unit Tests', () {
    test('Memperbarui seluruh data profil dari payload GET /auth/me', () async {
      final jsonBackend = {
        'fs_id': 'uuid-user-001',
        'fs_mr': '347104100407039',
        'fs_email': 'pasien.pku@gmail.com',
        'fs_nik': '347104100407039',
        'simrs': {
          'FS_MR': '347104100407951',
          'FS_NM_PASIEN': 'Dahlan Muhammadiyah',
          'FD_TGL_LAHIR': '1998-10-27',
          'FS_TLP_PASIEN': '081234567890',
          'FS_KD_IDENTITAS': '347104100407039',
        },
      };

      await SessionManager.updateFromMe(jsonBackend);

      expect(SessionManager.namaPasien, 'Dahlan Muhammadiyah');
      expect(SessionManager.noRm, '347104100407951');
      expect(SessionManager.nik, '347104100407039');
      expect(SessionManager.email, 'pasien.pku@gmail.com');
      expect(SessionManager.noHp, '081234567890');
      expect(SessionManager.fdTglLahir, '1998-10-27');
    });
  });

  group('PROMPT 21 - SimrsService.getMeProfile Service Tests', () {
    test('Memanggil GET /auth/me dengan token dan menyinkronkan data ke SessionManager', () async {
      await SessionManager.saveSession(
        token: 'valid-jwt-token',
        fsMr: '347104100407951',
        fsNmPasien: 'Initial Name',
      );

      String? capturedPath;
      String? capturedMethod;
      String? capturedAuthHeader;

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        capturedPath = options.path;
        capturedMethod = options.method;
        capturedAuthHeader = options.headers['Authorization']?.toString();

        return ResponseBody.fromString(
          jsonEncode({
            'status': true,
            'data': {
              'fs_id': 'uuid-1234',
              'fs_mr': '347104100407951',
              'fs_email': 'ahmad.dahlan@muhammadiyah.id',
              'fs_nik': '347104100407039',
              'simrs': {
                'FS_MR': '347104100407951',
                'FS_NM_PASIEN': 'KH. Ahmad Dahlan',
                'FD_TGL_LAHIR': '1995-08-01',
                'FS_TLP_PASIEN': '081987654321',
                'FS_KD_IDENTITAS': '347104100407039',
              },
            },
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final result = await SimrsService.getMeProfile();

      expect(capturedPath, '/auth/me');
      expect(capturedMethod, 'GET');
      expect(capturedAuthHeader, contains('Bearer valid-jwt-token'));
      expect(result['fs_email'], 'ahmad.dahlan@muhammadiyah.id');

      // Verifikasi SessionManager terupdate
      expect(SessionManager.namaPasien, 'KH. Ahmad Dahlan');
      expect(SessionManager.nik, '347104100407039');
      expect(SessionManager.email, 'ahmad.dahlan@muhammadiyah.id');
      expect(SessionManager.noHp, '081987654321');
      expect(SessionManager.fdTglLahir, '1995-08-01');
    });

    test('Melempar Exception saat server mengembalikan 401 Unauthorized', () async {
      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        return ResponseBody.fromString(
          jsonEncode({
            'status': false,
            'message': 'Unauthorized Access',
          }),
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      expect(
        () => SimrsService.getMeProfile(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('PROMPT 21 - Widget ProfileScreen Tampilkan Identitas Tests', () {
    testWidgets('Screen dibuka -> panggil GET /auth/me & tampilkan nama, NIK, MR, email, HP, tanggal lahir', (tester) async {
      // Setup sesi awal login
      await SessionManager.saveSession(
        token: 'jwt-auth-me-token',
        fsMr: '347104100407951',
        fsNmPasien: 'Pasien Test SIMRS',
        email: 'pasien.lama@gmail.com',
      );

      var getMeCalledCount = 0;

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.contains('/auth/me')) {
          getMeCalledCount++;
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'data': {
                'fs_id': 'user-uuid-99',
                'fs_mr': '347104100407951',
                'fs_email': 'pasien.real@gmail.com',
                'fs_nik': '347104100407039',
                'simrs': {
                  'FS_MR': '347104100407951',
                  'FS_NM_PASIEN': 'Dahlan Muda Perkasa',
                  'FD_TGL_LAHIR': '1998-10-27',
                  'FS_TLP_PASIEN': '081234567890',
                  'FS_KD_IDENTITAS': '347104100407039',
                },
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
          home: ProfileScreen(embedded: true),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verifikasi endpoint /auth/me terpanggil saat screen dibuka
      expect(getMeCalledCount, greaterThanOrEqualTo(1));

      // 2. Verifikasi Nama Pasien tampil
      expect(find.byKey(const Key('profile_nama')), findsOneWidget);
      expect(find.text('Dahlan Muda Perkasa'), findsOneWidget);

      // 3. Verifikasi No. Rekam Medis (MR) tampil
      expect(find.byKey(const Key('profile_mr')), findsOneWidget);
      expect(find.text('347104100407951'), findsWidgets);

      // 4. Verifikasi NIK tampil
      expect(find.byKey(const Key('profile_nik')), findsOneWidget);
      expect(find.text('347104100407039'), findsOneWidget);

      // 5. Verifikasi Email tampil
      expect(find.byKey(const Key('profile_email')), findsOneWidget);
      expect(find.text('pasien.real@gmail.com'), findsOneWidget);

      // 6. Verifikasi No. HP tampil
      expect(find.byKey(const Key('profile_hp')), findsOneWidget);
      expect(find.text('081234567890'), findsOneWidget);

      // 7. Verifikasi Tanggal Lahir tampil terformat rapi
      expect(find.byKey(const Key('profile_tgl_lahir')), findsOneWidget);
      expect(find.text('27 Oktober 1998'), findsOneWidget);
    });

    testWidgets('Pull to refresh pada ProfileScreen memperbarui profil pasien secara reaktif', (tester) async {
      await SessionManager.saveSession(
        token: 'jwt-auth-me-token',
        fsMr: '347104100407951',
        fsNmPasien: 'Nama Awal',
        email: 'awal@gmail.com',
      );

      var currentNama = 'Nama Awal';
      var currentEmail = 'awal@gmail.com';

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        if (options.path.contains('/auth/me')) {
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'data': {
                'fs_id': 'user-uuid-99',
                'fs_mr': '347104100407951',
                'fs_email': currentEmail,
                'fs_nik': '347104100407039',
                'simrs': {
                  'FS_MR': '347104100407951',
                  'FS_NM_PASIEN': currentNama,
                  'FD_TGL_LAHIR': '1998-10-27',
                  'FS_TLP_PASIEN': '081234567890',
                  'FS_KD_IDENTITAS': '347104100407039',
                },
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
          home: ProfileScreen(embedded: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nama Awal'), findsOneWidget);
      expect(find.text('awal@gmail.com'), findsOneWidget);

      // Simulasi update data di server
      currentNama = 'Nama Diperbarui';
      currentEmail = 'diperbarui@gmail.com';

      // Pull to refresh
      await tester.fling(find.byType(SingleChildScrollView), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      expect(find.text('Nama Diperbarui'), findsOneWidget);
      expect(find.text('diperbarui@gmail.com'), findsOneWidget);
    });

    testWidgets('Fallback data lokal tetap tampil saat terjadi kegagalan jaringan', (tester) async {
      await SessionManager.saveSession(
        token: 'jwt-auth-me-token',
        fsMr: '347104100407951',
        fsNmPasien: 'Pasien Offline',
        fsNik: '347104100407039',
        email: 'offline@gmail.com',
      );
      await SessionManager.setNoHp('089988776655');
      await SessionManager.setTglLahir('2000-01-15');

      ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
        return ResponseBody.fromString(
          jsonEncode({'status': false, 'message': 'Koneksi gagal'}),
          500,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ProfileScreen(embedded: true),
        ),
      );
      await tester.pumpAndSettle();

      // Data dari cache lokal tetap tampil tanpa crash
      expect(find.text('Pasien Offline'), findsOneWidget);
      expect(find.text('347104100407951'), findsWidgets);
      expect(find.text('347104100407039'), findsOneWidget);
      expect(find.text('offline@gmail.com'), findsOneWidget);
      expect(find.text('089988776655'), findsOneWidget);
      expect(find.text('15 Januari 2000'), findsOneWidget);

      // Pesan error ramah ditampilkan
      expect(find.text('Koneksi gagal'), findsOneWidget);
    });
  });

  group('PROMPT 21 - Integrasi Live Backend SIMRS', () {
    test(
      'Login pasien real dan panggil /auth/me',
      tags: ['live_db'],
      () async {
        await SimrsService.login(
          email: 'dummy_pasien@gmail.com',
          password: 'admin123',
        );

        final profile = await SimrsService.getMeProfile();
        expect(profile.containsKey('fs_email'), isTrue);
        expect(SessionManager.namaPasien.isNotEmpty, isTrue);
      },
    );
  });
}

