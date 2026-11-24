@Tags(['live_db'])
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/screens/register_screen.dart';
import 'package:pku_gamping_app/screens/login_screen.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _RealHttpOverrides();

  setUpAll(() {
    ApiClient.setBaseUrl(AppConfig.localhostUrl);
  });

  Widget createRegisterTestWidget() {
    return MaterialApp(
      initialRoute: '/register',
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }

  testWidgets('Register Flow: Header, form inputs, steps, and submit',
      (WidgetTester tester) async {
    // Set realistic mobile phone viewport
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.runAsync(() async {
      await tester.pumpWidget(createRegisterTestWidget());
      await Future.delayed(const Duration(milliseconds: 1000));
    });
    await tester.pumpAndSettle();

    // 1. Verifikasi Header Halaman Daftar Pasien Baru
    expect(find.text('Daftar Pasien Baru'), findsOneWidget);
    expect(find.text('Lengkapi data diri Anda untuk mendaftar akun baru'),
        findsOneWidget);

    // 2. Verifikasi NIK Input & Cek NIK
    final nikField = find.byType(TextFormField).first;
    await tester.enterText(nikField, '0402161711150001');
    await tester.pumpAndSettle();

    // Tap Cek NIK button inside runAsync
    await tester.runAsync(() async {
      await tester.tap(find.text('Cek NIK'));
      await Future.delayed(const Duration(milliseconds: 1000));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Valid'), findsOneWidget);

    // Lanjut ke Langkah 2
    final lanjutButton = find.text('Lanjutkan →');
    expect(lanjutButton, findsOneWidget);
    ScaffoldMessenger.of(tester.element(lanjutButton)).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.ensureVisible(lanjutButton);
    await tester.tap(lanjutButton);
    await tester.pumpAndSettle();

    // 3. Verifikasi Langkah 2 aktif
    expect(find.text('Langkah 2 dari 3'), findsOneWidget);
    expect(find.text('Data Pasien'), findsWidgets);
  });

  testWidgets('Navigation "Sudah punya akun? Masuk" leads to LoginScreen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.runAsync(() async {
      await tester.pumpWidget(createRegisterTestWidget());
      await Future.delayed(const Duration(milliseconds: 1000));
    });
    await tester.pumpAndSettle();

    // Tap "Sudah punya akun? Masuk"
    final masukFinder = find.text('Masuk');
    expect(masukFinder, findsWidgets);
    await tester.tap(masukFinder.first);
    await tester.pumpAndSettle();

    // Verifikasi navigasi ke LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
