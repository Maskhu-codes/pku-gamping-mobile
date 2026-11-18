@Tags(['live_db'])
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/screens/login_screen.dart';
import 'package:pku_gamping_app/screens/register_screen.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _RealHttpOverrides();

  setUp(() {
    ApiClient.setBaseUrl(AppConfig.localhostUrl);
  });

  Widget createRegisterApp() {
    return MaterialApp(
      initialRoute: '/register',
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }

  testWidgets('Flow Step 1 (NIK SIMRS Pre-fill) dan Step 2 (Master Dropdowns)',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.runAsync(() async {
      await tester.pumpWidget(createRegisterApp());
      // Tunggu _loadMasterData() di initState selesai
      await Future.delayed(const Duration(milliseconds: 800));
    });

    await tester.pumpAndSettle();

    // 1. Masukkan NIK pasien nyata yang ada di SIMRS TC_MR
    final nikField = find.byType(TextFormField).first;
    await tester.enterText(nikField, '0402161711150001');
    await tester.pumpAndSettle();

    // 2. Klik tombol Cek NIK dan tunggu respons dari backend
    final cekNikBtn = find.text('Cek NIK');
    expect(cekNikBtn, findsOneWidget);

    await tester.runAsync(() async {
      await tester.tap(cekNikBtn);
      await Future.delayed(const Duration(milliseconds: 1000));
    });

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Status NIK valid
    expect(find.text('Valid'), findsOneWidget);

    // 3. Lanjutkan ke Step 2 (tutup snackbar terlebih dahulu agar tidak menutupi tombol)
    final lanjutBtn = find.text('Lanjutkan →');
    expect(lanjutBtn, findsOneWidget);

    ScaffoldMessenger.of(tester.element(lanjutBtn)).hideCurrentSnackBar();
    await tester.pumpAndSettle();

    await tester.ensureVisible(lanjutBtn);
    await tester.tap(lanjutBtn);
    await tester.pumpAndSettle();

    // 4. Verifikasi masuk ke Step 2
    expect(find.text('Langkah 2 dari 3'), findsOneWidget);

    // 5. Verifikasi nama pasien ter-prefill otomatis dari SIMRS
    final namaField = find.widgetWithText(TextFormField, 'NAJIB IBADURROHMAN');
    expect(namaField, findsOneWidget);

    // 6. Verifikasi keberadaan dropdown Master Agama, Pekerjaan, Pendidikan, dan Status Kawin
    expect(find.text('Agama *'), findsOneWidget);
    expect(find.text('Pekerjaan *'), findsOneWidget);
    expect(find.text('Pendidikan Terakhir *'), findsOneWidget);
    expect(find.text('Status Kawin *'), findsOneWidget);
  });
}
