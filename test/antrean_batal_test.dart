import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/services/antrean_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RealHttpOverrides extends HttpOverrides {}

class _MockHttpClientAdapter implements HttpClientAdapter {
  _MockHttpClientAdapter(this.handler);

  final ResponseBody Function(RequestOptions options) handler;

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

  group('AntreanService POST /booking/batal', () {
    test(
      'mengirim nomor booking dan mengosongkan state setelah sukses',
      () async {
        await SessionManager.saveSession(
          token: 'jwt-valid-token',
          fsMr: '347104100407039',
        );
        AntreanService.buatAntrean(
          nomorAntrean: '18',
          namaPasien: 'Pasien Test',
          noRm: '347104100407039',
          poli: 'Poli Anak',
          dokter: 'dr. Gina Puspita, Sp.A',
          jam: '08:30 WIB',
          tanggal: '13 November 2026',
          noBooking: 'BO202611130099',
        );

        String? requestedPath;
        String? requestMethod;
        String? authHeader;
        Map<String, dynamic>? requestBody;
        ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((options) {
          requestedPath = options.path;
          requestMethod = options.method;
          authHeader = options.headers['Authorization'] as String?;
          requestBody = Map<String, dynamic>.from(options.data as Map);
          return ResponseBody.fromString(
            jsonEncode({
              'status': true,
              'message': 'Booking berhasil dibatalkan',
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

        await AntreanService.batalkanBooking(fsKdTrs: ' BO202611130099 ');

        expect(requestedPath, '/booking/batal');
        expect(requestMethod, 'POST');
        expect(authHeader, 'Bearer jwt-valid-token');
        expect(requestBody, {'fs_kd_trs': 'BO202611130099'});
        expect(AntreanService.antreanAktif.value, isNull);
      },
    );

    test(
      'mempertahankan state antrean jika backend menolak pembatalan',
      () async {
        await SessionManager.saveSession(
          token: 'jwt-valid-token',
          fsMr: '347104100407039',
        );
        AntreanService.buatAntrean(
          nomorAntrean: '18',
          namaPasien: 'Pasien Test',
          noRm: '347104100407039',
          poli: 'Poli Anak',
          dokter: 'dr. Gina Puspita, Sp.A',
          jam: '08:30 WIB',
          tanggal: '13 November 2026',
          noBooking: 'BO202611130099',
        );
        ApiClient.dio.httpClientAdapter = _MockHttpClientAdapter((_) {
          return ResponseBody.fromString(
            jsonEncode({
              'status': false,
              'message': 'Booking tidak dapat dibatalkan',
            }),
            400,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

        await expectLater(
          AntreanService.batalkanBooking(fsKdTrs: 'BO202611130099'),
          throwsA(isA<Exception>()),
        );

        expect(AntreanService.antreanAktif.value?.noBooking, 'BO202611130099');
      },
    );
  });
}
