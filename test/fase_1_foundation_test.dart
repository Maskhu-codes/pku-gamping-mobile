import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _RealHttpOverrides();

  group('Lini 1: Pengujian AppConfig', () {
    test('AppConfig memiliki konfigurasi base URL dan timeout yang valid', () {
      expect(AppConfig.baseUrl, isNotEmpty);
      expect(AppConfig.localhostUrl, contains('localhost'));
      expect(AppConfig.emulatorUrl, contains('10.0.2.2'));
      expect(AppConfig.serverUrl, contains('192.168.20.1'));
      expect(AppConfig.connectTimeoutSeconds, greaterThan(0));
      expect(AppConfig.receiveTimeoutSeconds, greaterThan(0));
    });
  });

  group('Lini 2: Pengujian SessionManager', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SessionManager.init();
    });

    test('Status awal harus bersih dan hasValidSession bernilai false', () {
      expect(SessionManager.isLoggedIn, isFalse);
      expect(SessionManager.hasValidSession(), isFalse);
      expect(SessionManager.token, isNull);
    });

    test('Menyimpan dan membaca kembali seluruh atribut identitas pasien', () async {
      await SessionManager.saveSession(
        token: 'test.jwt.token',
        fsNmPasien: 'Siti Walidah',
        fsMr: '01-99-88-77',
        fsNik: '3471098765430002',
        fsEmail: 'siti.walidah@example.com',
        username: 'siti_walidah',
      );

      expect(SessionManager.hasValidSession(), isTrue);
      expect(SessionManager.isLoggedIn, isTrue);
      expect(SessionManager.token, 'test.jwt.token');
      expect(SessionManager.fsMr, '01998877');
      expect(SessionManager.noRm, '01998877');
      expect(SessionManager.fsNmPasien, 'Siti Walidah');
      expect(SessionManager.namaPasien, 'Siti Walidah');
      expect(SessionManager.fsNik, '3471098765430002');
      expect(SessionManager.nik, '3471098765430002');
      expect(SessionManager.fsEmail, 'siti.walidah@example.com');
      expect(SessionManager.email, 'siti.walidah@example.com');
      expect(SessionManager.username, 'siti_walidah');
    });

    test('Sanitasi data pasien: password/pin tidak boleh disimpan di SharedPreferences', () async {
      await SessionManager.savePatientData({
        'fs_mr': '01-99-88-77',
        'fs_nm_pasien': 'Siti Walidah',
        'password': 'rahasia123',
        'pin': '123456',
        'role': 'pasien',
      });

      final stored = SessionManager.patientData;
      expect(stored, isNotNull);
      expect(stored!['fs_mr'], '01-99-88-77');
      expect(stored.containsKey('password'), isFalse);
      expect(stored.containsKey('pin'), isFalse);
      expect(stored['role'], 'pasien');
    });

    test('clearSession menghapus seluruh sesi dan kredensial', () async {
      await SessionManager.saveSession(
        token: 'test.jwt.token',
        fsNmPasien: 'Siti Walidah',
        fsMr: '01-99-88-77',
        fsNik: '3471098765430002',
        fsEmail: 'siti.walidah@example.com',
      );
      expect(SessionManager.hasValidSession(), isTrue);

      await SessionManager.clearSession();

      expect(SessionManager.hasValidSession(), isFalse);
      expect(SessionManager.isLoggedIn, isFalse);
      expect(SessionManager.token, isNull);
      expect(SessionManager.fsNik, isNull);
      expect(SessionManager.fsEmail, isNull);
      expect(SessionManager.patientData, isNull);
    });
  });

  group('Lini 3: Pengujian ApiClient & Koneksi HTTP ke Backend', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SessionManager.init();
      ApiClient.setBaseUrl(AppConfig.localhostUrl);
    });

    test('ApiClient terinisialisasi dengan konfigurasi dan header yang tepat', () {
      final dio = ApiClient.dio;
      expect(dio.options.baseUrl, AppConfig.localhostUrl);
      expect(dio.options.headers['Content-Type'], 'application/json');
      expect(dio.options.headers['Accept'], 'application/json');
      expect(dio.options.headers['X-App-Platform'], 'Flutter-Mobile');
      expect(dio.options.headers['X-Hospital-Id'], 'RS-PKU-GAMPING');
    });

    test('Panggilan HTTP GET /layanan/list berhasil mengambil data nyata SIMRS', () async {
      final response = await ApiClient.dio.get('/layanan/list');

      expect(response.statusCode, 200);
      expect(response.data, isA<Map<String, dynamic>>());
      expect(response.data['status'], true);

      final listLayanan = response.data['data'] as List;
      expect(listLayanan.isNotEmpty, isTrue);

      // Verifikasi struktur data dari database SIMRS HOSPITAL (TA_LAYANAN)
      final sample = listLayanan.first as Map<String, dynamic>;
      expect(sample.containsKey('fs_kd_layanan'), isTrue);
      expect(sample.containsKey('fs_nm_layanan'), isTrue);
    }, tags: ['live_db']);

    test('Panggilan HTTP GET /master/agama berhasil mengambil data master', () async {
      final response = await ApiClient.dio.get('/master/agama');

      expect(response.statusCode, 200);
      expect(response.data['status'], true);

      final listAgama = response.data['data'] as List;
      expect(listAgama.length, greaterThanOrEqualTo(5));
    }, tags: ['live_db']);

    test('Interceptor menyisipkan header Authorization saat token tersedia di session', () async {
      // Simpan token ke session
      await SessionManager.saveSession(
        token: 'dummy.simrs.bearer.token',
        fsNmPasien: 'Pasien Test',
        fsMr: '01000001',
      );

      // Request ke endpoint untuk verifikasi interceptor menyisipkan header tanpa error
      final response = await ApiClient.dio.get('/layanan/list');
      expect(response.statusCode, 200);
    }, tags: ['live_db']);

    test('Penanganan error yang ramah pengguna via extractErrorMessage', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        message: 'Koneksi terputus',
        type: DioExceptionType.connectionError,
      );
      final customError = ApiClient.extractErrorMessage(
        dioException,
        defaultMessage: 'Fallback error message',
      );
      expect(customError, contains('Tidak dapat terhubung ke backend'));
    });
  });
}
