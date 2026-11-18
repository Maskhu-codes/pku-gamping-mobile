import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/services/simrs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockLoginInterceptor extends Interceptor {
  Map<String, dynamic>? lastRequestBody;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.path.contains('/auth/login')) {
      lastRequestBody = options.data is Map<String, dynamic>
          ? options.data as Map<String, dynamic>
          : null;

      final email = lastRequestBody?['fs_email'];
      final password = lastRequestBody?['fs_password'];

      if (email == 'pasien@pku.com' && password == 'password123') {
        return handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'status': true,
              'message': 'Login berhasil',
              'token': 'mock-jwt-token-xyz',
              'user': {
                'fs_id': 'uuid-1234',
                'fs_mr': '34-71-04-10-04-07-951', // Simulating legacy/unclean RM from DB
                'fs_email': 'pasien@pku.com',
                'fs_nik': '3471040001990001',
                'fs_nm_pasien': 'PASIEN NON BPJS',
              },
            },
          ),
        );
      } else {
        return handler.reject(
          DioException(
            requestOptions: options,
            response: Response(
              requestOptions: options,
              statusCode: 401,
              data: {'status': false, 'message': 'Email atau password salah'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );
      }
    }
    super.onRequest(options, handler);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _MockLoginInterceptor mockInterceptor;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionManager.init();

    mockInterceptor = _MockLoginInterceptor();
    ApiClient.dio.interceptors.insert(0, mockInterceptor);
  });

  tearDown(() {
    ApiClient.dio.interceptors.remove(mockInterceptor);
  });

  group('PROMPT 04 - Login Murni Email & Sanitasi Session No. RM Tests', () {
    test('SimrsService.login mengirim fs_email & fs_password dan sanitasi No. RM 15-digit', () async {
      final res = await SimrsService.login(
        email: 'pasien@pku.com',
        password: 'password123',
      );

      // Verifikasi payload request
      expect(mockInterceptor.lastRequestBody, isNotNull);
      expect(mockInterceptor.lastRequestBody?['fs_email'], 'pasien@pku.com');
      expect(mockInterceptor.lastRequestBody?['fs_password'], 'password123');

      // Verifikasi respons
      expect(res['status'], isTrue);
      expect(res['token'], 'mock-jwt-token-xyz');

      // Verifikasi No. RM 15-digit bersih dari strip '-' dan spasi di SessionManager
      expect(SessionManager.fsMr, '347104100407951');
      expect(SessionManager.noRm, '347104100407951');
      expect(SessionManager.fsNmPasien, 'PASIEN NON BPJS');
      expect(SessionManager.fsEmail, 'pasien@pku.com');
      expect(SessionManager.hasValidSession(), isTrue);
    });

    test('SimrsService.login melempar exception saat kredensial salah', () async {
      expect(
        () => SimrsService.login(
          email: 'pasien@pku.com',
          password: 'wrong_password',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}

