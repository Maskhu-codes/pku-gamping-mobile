@Tags(['live_db'])
library;

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/services/simrs_service.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _RealHttpOverrides();

  setUp(() {
    ApiClient.setBaseUrl(AppConfig.localhostUrl);
  });

  test('cekNik dengan NIK yang ada di SIMRS mengembalikan found: true dan nama pasien', () async {
    final result = await SimrsService.cekNik('0402161711150001');

    expect(result['status'], isTrue);
    expect(result['found'], isTrue);
    expect(result['isAlreadyRegistered'], isFalse);
    expect(result['fs_nm_pasien'], 'NAJIB IBADURROHMAN');
    expect(result['fs_mr'], '347104100105276');
    expect(result['fd_tgl_lahir'], '2016-02-11');
  });

  test('cekNik dengan NIK yang sudah terdaftar akun mengembalikan isAlreadyRegistered: true', () async {
    final result = await SimrsService.cekNik('3319021602050001');

    expect(result['status'], isFalse);
    expect(result['isAlreadyRegistered'], isTrue);
    expect(result['found'], isFalse);
    expect(result['message'], contains('sudah terdaftar sebagai akun'));

    final isReg = await SimrsService.isNikAlreadyRegistered('3319021602050001');
    expect(isReg, isTrue);
  });

  test('cekNik dengan NIK baru (belum di SIMRS) mengembalikan found: false', () async {
    final result = await SimrsService.cekNik('9999999999999999');

    expect(result['status'], isTrue);
    expect(result['found'], isFalse);
    expect(result['isAlreadyRegistered'], isFalse);
    expect(result['fs_mr'], isNull);
    expect(result['fs_nm_pasien'], isNull);

    final isReg = await SimrsService.isNikAlreadyRegistered('9999999999999999');
    expect(isReg, isFalse);
  });

  test('cekNik dengan NIK tidak 16 digit melempar Exception', () async {
    expect(() => SimrsService.cekNik('12345'), throwsA(isA<Exception>()));
  });
}

