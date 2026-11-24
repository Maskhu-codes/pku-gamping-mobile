@Tags(['live_db'])
library;

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _RealHttpOverrides();

  setUpAll(() {
    ApiClient.setBaseUrl(AppConfig.localhostUrl);
  });

  test('ApiClient GET /layanan/list mengembalikan data JSON dari backend', () async {
    final response = await ApiClient.dio.get('/layanan/list');

    expect(response.statusCode, 200);
    expect(response.data, isNotNull);
    expect(response.data['status'], true);
    expect(response.data['data'], isList);
    expect((response.data['data'] as List).isNotEmpty, true);

    final firstItem = (response.data['data'] as List).first;
    expect(firstItem, contains('fs_kd_layanan'));
    expect(firstItem, contains('fs_nm_layanan'));
  });
}

