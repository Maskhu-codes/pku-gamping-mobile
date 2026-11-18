import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/config/app_config.dart';
import 'package:pku_gamping_app/core/network/api_client.dart';
import 'package:pku_gamping_app/core/routes/app_routes.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:pku_gamping_app/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RealHttpOverrides extends HttpOverrides {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _RealHttpOverrides();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionManager.init();
    ApiClient.setBaseUrl(AppConfig.localhostUrl);
  });

  Widget createLoginTestApp({required Widget home}) {
    return MaterialApp(
      routes: {
        AppRoutes.login: (ctx) => const LoginScreen(),
        AppRoutes.home: (ctx) => const Scaffold(body: Text('Home Screen Destination')),
      },
      home: home,
    );
  }

  testWidgets('Validasi form muncul jika email atau password kosong', (tester) async {
    await tester.pumpWidget(createLoginTestApp(home: const LoginScreen()));
    await tester.pumpAndSettle();

    final masukButton = find.widgetWithText(ElevatedButton, 'Masuk');
    expect(masukButton, findsOneWidget);

    await tester.tap(masukButton);
    await tester.pumpAndSettle();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi'), findsOneWidget);
    expect(find.text('Home Screen Destination'), findsNothing);
  });

  testWidgets('Validasi form muncul jika email tidak mengandung @', (tester) async {
    await tester.pumpWidget(createLoginTestApp(home: const LoginScreen()));
    await tester.pumpAndSettle();

    final emailField = find.byType(TextFormField).at(0);
    final passField = find.byType(TextFormField).at(1);
    final masukButton = find.widgetWithText(ElevatedButton, 'Masuk');

    await tester.enterText(emailField, 'bukanemail');
    await tester.enterText(passField, 'password123');
    await tester.tap(masukButton);
    await tester.pumpAndSettle();

    expect(find.text('Format email tidak valid'), findsOneWidget);
    expect(find.text('Home Screen Destination'), findsNothing);
  });

  testWidgets('Login gagal menampilkan SnackBar error dan tetap di LoginScreen', (tester) async {
    await tester.pumpWidget(createLoginTestApp(home: const LoginScreen()));
    await tester.pumpAndSettle();

    final emailField = find.byType(TextFormField).at(0);
    final passField = find.byType(TextFormField).at(1);
    final masukButton = find.widgetWithText(ElevatedButton, 'Masuk');

    await tester.enterText(emailField, 'dummy_pasien@gmail.com');
    await tester.enterText(passField, 'password_salah_total');

    await tester.runAsync(() async {
      await tester.tap(masukButton);
      for (int i = 0; i < 25; i++) {
        if (SessionManager.hasValidSession()) break;
        await Future.delayed(const Duration(milliseconds: 200));
      }
    });

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verifikasi SnackBar muncul
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Email atau password salah'), findsOneWidget);
    expect(find.text('Home Screen Destination'), findsNothing);
    expect(SessionManager.hasValidSession(), isFalse);
  }, tags: ['live_db']);

  testWidgets('Login sukses dengan akun nyata masuk ke Home Screen', (tester) async {
    await tester.pumpWidget(createLoginTestApp(home: const LoginScreen()));
    await tester.pumpAndSettle();

    final emailField = find.byType(TextFormField).at(0);
    final passField = find.byType(TextFormField).at(1);
    final masukButton = find.widgetWithText(ElevatedButton, 'Masuk');

    await tester.enterText(emailField, 'dummy_pasien@gmail.com');
    await tester.enterText(passField, 'admin123');

    await tester.runAsync(() async {
      await tester.tap(masukButton);
      for (int i = 0; i < 25; i++) {
        if (SessionManager.hasValidSession()) break;
        await Future.delayed(const Duration(milliseconds: 200));
      }
    });

    await tester.pumpAndSettle();

    expect(find.text('Home Screen Destination'), findsOneWidget);
    expect(SessionManager.hasValidSession(), isTrue);
    expect(SessionManager.fsNmPasien, 'PASIEN DUMMY ONLINE');
    expect(SessionManager.fsMr, '347104100407039');
  }, tags: ['live_db']);
}
